import { Server as SocketIOServer } from 'socket.io';
import { Server as HTTPServer } from 'http';
import jwt from 'jsonwebtoken';
import User from '../models/User';
import Message from '../models/Message';
import ChatRoom from '../models/ChatRoom';

interface AuthenticatedSocket extends SocketIOServer {
  userId?: string;
  username?: string;
}

interface JwtPayload {
  userId: string;
}

export class SocketService {
  private io: SocketIOServer;

  constructor(server: HTTPServer) {
    this.io = new SocketIOServer(server, {
      cors: {
        origin: [
          "http://localhost:3000",
          "http://localhost:8080", 
          "https://realtime-chat-vcbo.vercel.app",
          "https://realtime-chat-two-sable.vercel.app",
          process.env.FRONTEND_URL || "*"
        ],
        methods: ["GET", "POST"],
        credentials: true
      },
      transports: ['websocket', 'polling']
    });

    this.initializeHandlers();
  }

  private initializeHandlers(): void {
    // Authentication middleware
    this.io.use(async (socket: any, next) => {
      try {
        console.log('🔐 Socket authentication attempt');
        const token = socket.handshake.auth.token;
        
        if (!token) {
          console.log('❌ No token provided for socket connection');
          return next(new Error('Authentication error: No token provided'));
        }

        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
          console.log('❌ JWT_SECRET not configured');
          return next(new Error('Server configuration error'));
        }

        console.log('🔍 Verifying JWT token...');
        const decoded = jwt.verify(token, jwtSecret) as JwtPayload;
        const user = await User.findById(decoded.userId);

        if (!user) {
          console.log('❌ User not found for token');
          return next(new Error('Authentication error: User not found'));
        }

        socket.userId = (user._id as string).toString();
        socket.username = user.username;
        
        console.log(`✅ Socket authenticated for user: ${user.username}`);
        next();
      } catch (error: any) {
        console.log('❌ Socket authentication error:', error.message);
        next(new Error('Authentication error: Invalid token'));
      }
    });

    this.io.on('connection', (socket: any) => {
      console.log(`User ${socket.username} connected with socket ID: ${socket.id}`);

      // Join room handler
      socket.on('join_room', async (data: { roomId: string; userId: string; username: string }) => {
        try {
          const { roomId, userId, username } = data;

          // Verify user is a member of the room
          const room = await ChatRoom.findById(roomId);
          if (!room || !room.members.includes(userId as any)) {
            socket.emit('error', { message: 'Access denied - not a member of this room' });
            return;
          }

          // Join the room
          socket.join(roomId);
          
          // Notify other users in the room
          socket.to(roomId).emit('user_joined', {
            username,
            message: `${username} joined the room`,
            timestamp: new Date().toISOString()
          });

          socket.emit('joined_room', { 
            roomId, 
            message: 'Successfully joined the room' 
          });

          console.log(`${username} joined room: ${roomId}`);
        } catch (error) {
          console.error('Join room error:', error);
          socket.emit('error', { message: 'Failed to join room' });
        }
      });

      // Leave room handler
      socket.on('leave_room', async (data: { roomId: string; userId: string; username: string }) => {
        try {
          const { roomId, username } = data;

          socket.leave(roomId);
          
          // Notify other users in the room
          socket.to(roomId).emit('user_left', {
            username,
            message: `${username} left the room`,
            timestamp: new Date().toISOString()
          });

          console.log(`${username} left room: ${roomId}`);
        } catch (error) {
          console.error('Leave room error:', error);
        }
      });

      // Send message handler
      socket.on('send_message', async (data: { 
        content: string; 
        roomId: string; 
        senderId: string; 
        senderUsername: string; 
        timestamp: string 
      }) => {
        try {
          const { content, roomId, senderId, senderUsername } = data;
          
          console.log(`Received message data:`, {
            content,
            roomId,
            senderId,
            senderUsername,
            socketUserId: socket.userId,
            socketUsername: socket.username
          });

          // Verify the sender matches the authenticated socket user
          if (socket.userId !== senderId) {
            console.log(`Authentication mismatch: socket user ${socket.userId} trying to send as ${senderId}`);
            socket.emit('error', { message: 'Authentication error: Cannot send message as different user' });
            return;
          }

          // Verify user is a member of the room
          const room = await ChatRoom.findById(roomId);
          if (!room || !room.members.includes(senderId as any)) {
            console.log(`Access denied - user ${senderId} not a member of room ${roomId}`);
            socket.emit('error', { message: 'Access denied - not a member of this room' });
            return;
          }

          console.log(`User verified as member of room ${roomId}`);

          // Save message to database
          const message = new Message({
            content,
            senderId,
            senderUsername,
            roomId,
            timestamp: new Date()
          });

          console.log(`Attempting to save message to database:`, {
            content: message.content,
            senderId: message.senderId,
            senderUsername: message.senderUsername,
            roomId: message.roomId,
            timestamp: message.timestamp
          });

          await message.save();
          
          console.log(`Message saved successfully with ID: ${message._id}`);

          // Broadcast message to all users in the room
          this.io.to(roomId).emit('receive_message', {
            id: message._id,
            content: message.content,
            senderId: message.senderId,
            senderUsername: message.senderUsername,
            roomId: message.roomId,
            timestamp: message.timestamp
          });

          console.log(`Message broadcast to room ${roomId}`);
          console.log(`Message sent by ${senderUsername} in room ${roomId}`);
        } catch (error) {
          console.error('Send message error:', error);
          socket.emit('error', { message: 'Failed to send message' });
        }
      });

      // Disconnect handler
      socket.on('disconnect', () => {
        console.log(`User ${socket.username} disconnected`);
      });

      // Error handler
      socket.on('error', (error: any) => {
        console.error(`Socket error for user ${socket.username}:`, error);
      });
    });
  }

  public getIO(): SocketIOServer {
    return this.io;
  }
}