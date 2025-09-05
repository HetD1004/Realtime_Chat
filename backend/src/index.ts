import express from 'express';
import { createServer } from 'http';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';

// Import routes
import authRoutes from './routes/auth';
import roomRoutes from './routes/rooms';

// Import services
import { SocketService } from './services/socketService';

// Load environment variables
dotenv.config();

const app = express();
const server = createServer(app);
const PORT = process.env.PORT || 3000;

// Middleware - Complete CORS fix
app.use((req, res, next) => {
  const origin = req.headers.origin;
  console.log('🌐 Request from origin:', origin);
  
  // Allow all origins for now (debugging)
  res.header('Access-Control-Allow-Origin', origin || '*');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, Cache-Control');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    console.log('✅ Preflight request handled');
    return res.status(200).end();
  }
  
  next();
});

// Enhanced JSON parsing with error handling
app.use((req, res, next) => {
  if (req.headers['content-type']?.includes('application/json')) {
    console.log('📥 Raw body for JSON request:', {
      contentType: req.headers['content-type'],
      contentLength: req.headers['content-length'],
      body: typeof req.body === 'string' ? req.body.substring(0, 200) : 'Not string'
    });
  }
  next();
});

app.use(express.json({ 
  limit: '10mb',
  strict: true, // Only parse objects and arrays
  type: ['application/json', 'text/json'], // Be explicit about content types
  verify: (req, res, buf, encoding) => {
    try {
      if (buf && buf.length) {
        const rawBody = buf.toString('utf8');
        console.log('🔍 Raw JSON body:', rawBody.substring(0, 200));
        
        // Check for common malformed JSON issues
        if (rawBody.includes('\\"') && !rawBody.includes('"')) {
          console.warn('⚠️ Detected escaped quotes in JSON body');
        }
        
        // Try to parse the JSON to validate it
        JSON.parse(rawBody);
        console.log('✅ JSON validation passed');
      }
    } catch (e: any) {
      console.error('❌ JSON parsing error in verify:', e.message);
      console.error('🔴 Problematic body:', buf.toString('utf8'));
    }
  }
}));

app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path} - Origin: ${req.headers.origin}`);
  console.log('📦 Request body:', req.body);
  console.log('🔗 Content-Type:', req.headers['content-type']);
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/rooms', roomRoutes);

// JSON parsing error handler
app.use((error: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  if (error instanceof SyntaxError && 'body' in error) {
    console.error('🚨 JSON Syntax Error:', {
      message: error.message,
      body: error.body,
      rawBody: req.body,
      contentType: req.headers['content-type'],
      userAgent: req.headers['user-agent']
    });
    
    return res.status(400).json({
      message: 'Invalid JSON format in request body',
      error: 'INVALID_JSON',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
  next(error);
});

// Root endpoint - API information
app.get('/', (req, res) => {
  res.json({
    message: 'Real-Time Chat API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      auth: {
        login: 'POST /api/auth/login',
        register: 'POST /api/auth/register'
      },
      rooms: {
        list: 'GET /api/rooms',
        create: 'POST /api/rooms',
        messages: 'GET /api/rooms/:id/messages'
      }
    },
    documentation: 'https://github.com/HetD1004/Realtime_Chat#readme',
    timestamp: new Date().toISOString()
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Real-time Chat API is running',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// Error handling middleware
app.use((error: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Unhandled error:', error);
  res.status(500).json({ 
    message: 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { error: error.message })
  });
});

// Database connection
const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/realtime-chat';
    
    await mongoose.connect(mongoURI);
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

// Initialize Socket.io
const socketService = new SocketService(server);

// Start server
const startServer = async () => {
  try {
    // Connect to database
    await connectDB();
    
    // Start listening
    server.listen(PORT, () => {
      console.log(`🚀 Server is running on http://localhost:${PORT}`);
      console.log(`📱 Socket.io server is ready for connections`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    mongoose.connection.close();
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    mongoose.connection.close();
    process.exit(0);
  });
});

// Start the application
startServer();