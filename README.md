Real-Time Chat Website

A full-stack real-time chat application built with Flutter frontend and TypeScript Socket.io backend, deployed on Vercel.

**Live Demo**: 
- Frontend: `https://your-frontend-domain.vercel.app`
- Backend API: `https://your-backend-domain.vercel.app`

## Features

- **Real-time Messaging**: Instant message delivery using WebSocket connections
- **User Authentication**: Secure JWT-based authentication system
- **Chat Rooms**: Create and join multiple chat rooms
- **Persistent Storage**: Message history stored in MongoDB
- **Responsive UI**: Lightweight and responsive design for all devices
- **Multi-platform Support**: Flutter app works on web, mobile, and desktop
- **Production Ready**: Deployed on Vercel with CI/CD pipeline

## Tech Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language for Flutter
- **Socket.io Client**: Real-time communication
- **HTTP Package**: REST API communication
- **Vercel**: Hosting platform for frontend

### Backend
- **Express.js**: Node.js web framework with TypeScript
- **Socket.io**: Real-time bidirectional communication
- **MongoDB Atlas**: Cloud NoSQL database
- **JWT**: JSON Web Tokens for authentication
- **Bcrypt**: Password hashing
- **Vercel**: Serverless hosting for backend API

## Project Structure

```
RealTimeChat/
├── frontend/           # Flutter application
│   ├── lib/
│   │   ├── config/     # Environment configuration
│   │   ├── models/     # Data models
│   │   ├── screens/    # UI screens
│   │   ├── services/   # API and Socket services
│   │   └── widgets/    # Reusable UI components
│   ├── vercel.json     # Vercel deployment config
│   └── pubspec.yaml
├── backend/            # TypeScript Express server
│   ├── src/
│   │   ├── controllers/# Route handlers
│   │   ├── models/     # MongoDB schemas
│   │   ├── middleware/ # Authentication middleware
│   │   ├── routes/     # API routes
│   │   └── services/   # Business logic
│   ├── vercel.json     # Vercel deployment config
│   ├── .env.example    # Environment variables template
│   └── package.json
├── .github/
│   └── workflows/      # GitHub Actions CI/CD
├── .gitignore
└── README.md
```

## Getting Started

### Prerequisites
- Flutter SDK (3.9.0+)
- Node.js (18+) and npm
- MongoDB Atlas account (for production) or MongoDB local (for development)
- Vercel account (for deployment)

### Local Development

#### Backend Setup
1. Navigate to backend directory: `cd backend`
2. Install dependencies: `npm install`
3. Copy environment variables: `cp .env.example .env`
4. Update `.env` with your MongoDB connection string and JWT secret
5. Build TypeScript: `npm run build`
6. Start development server: `npm run dev`

#### Frontend Setup
1. Navigate to frontend directory: `cd frontend`
2. Install dependencies: `flutter pub get`
3. Run the web app: `flutter run -d web-server --web-port 3001`

### Production Deployment

#### Deploy to Vercel

1. **Backend Deployment:**
   ```bash
   # Install Vercel CLI
   npm i -g vercel
   
   # Navigate to backend directory
   cd backend
   
   # Deploy to Vercel
   vercel
   
   # Set environment variables in Vercel dashboard
   # - MONGODB_URI: Your MongoDB Atlas connection string
   # - JWT_SECRET: A secure random string
   # - NODE_ENV: production
   # - FRONTEND_URL: Your frontend Vercel URL
   ```

2. **Frontend Deployment:**
   ```bash
   # Navigate to frontend directory
   cd frontend
   
   # Update frontend/lib/config/config.dart with your backend URL
   # Replace 'your-backend-domain.vercel.app' with actual domain
   
   # Build for web
   flutter build web --release
   
   # Deploy to Vercel
   vercel --cwd build/web
   ```

3. **Update Configuration:**
   - Update `frontend/lib/config/config.dart` with your actual Vercel URLs
   - Update backend CORS settings with your frontend domain
   - Set all required environment variables in Vercel dashboard

#### Using GitHub Actions (Recommended)

1. Fork this repository
2. Set up the following secrets in GitHub repository settings:
   - `VERCEL_TOKEN`: Your Vercel token
   - `ORG_ID`: Your Vercel organization ID
   - `PROJECT_ID`: Your backend Vercel project ID
   - `PROJECT_ID_FRONTEND`: Your frontend Vercel project ID
3. Push to main branch to trigger deployment

### Environment Configuration

#### Backend Environment Variables (.env)
```bash
PORT=3000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/realtime-chat
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
FRONTEND_URL=https://your-frontend-domain.vercel.app
NODE_ENV=production
```

#### Frontend Configuration
Update `frontend/lib/config/config.dart`:
```dart
static const String _prodBaseUrl = 'https://your-backend-domain.vercel.app/api';
static String get socketUrl => _isProduction 
  ? 'https://your-backend-domain.vercel.app' 
  : 'http://localhost:3000';
```

## API Endpoints

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/rooms` - Get available chat rooms
- `POST /api/rooms` - Create new chat room
- `GET /api/rooms/:id/messages` - Get room message history

## Socket Events

- `join_room` - Join a chat room
- `leave_room` - Leave a chat room
- `send_message` - Send message to room
- `receive_message` - Receive message from room
- `user_joined` - User joined room notification
- `user_left` - User left room notification

## Deployment Checklist

- [ ] Set up MongoDB Atlas database
- [ ] Deploy backend to Vercel
- [ ] Set backend environment variables in Vercel
- [ ] Update frontend configuration with backend URL
- [ ] Deploy frontend to Vercel
- [ ] Update backend CORS settings with frontend URL
- [ ] Test real-time messaging functionality
- [ ] Set up GitHub Actions for CI/CD (optional)

## Troubleshooting

### Common Issues

1. **CORS Errors**: Update backend CORS configuration with your frontend domain
2. **Socket Connection Fails**: Ensure backend URL is correctly set in frontend config
3. **Database Connection**: Check MongoDB Atlas connection string and IP whitelist
4. **Build Errors**: Ensure all dependencies are installed and TypeScript compiles successfully

### Performance Tips

- Use MongoDB Atlas for better performance and reliability
- Enable Vercel Analytics for monitoring
- Implement proper error handling and logging
- Consider implementing rate limiting for production

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions:
1. Check the troubleshooting section above
2. Open an issue on GitHub
3. Review Vercel deployment logs for debugging

---

**Happy Chatting!**