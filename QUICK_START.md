# Quick Start Guide

## Prerequisites

Before running the Real-Time Chat application, make sure you have the following installed:

- **Flutter SDK** (version 3.9.0 or higher)
- **Dart SDK** (comes with Flutter)
- **Node.js** (version 18 or higher)
- **npm** or **yarn**
- **MongoDB** (local installation or cloud service like MongoDB Atlas)

## Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure environment variables**:
   - Copy `.env.example` to `.env`
   - Update the environment variables:
   ```
   PORT=3000
   MONGODB_URI=mongodb://localhost:27017/realtime-chat
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   CORS_ORIGIN=http://localhost:3000
   ```

4. **Start MongoDB**:
   - **Local MongoDB**: Start your local MongoDB service
   - **MongoDB Atlas**: Use your cloud connection string

5. **Start the backend server**:
   ```bash
   # Development mode with hot reload
   npm run dev
   
   # Production mode
   npm run build
   npm start
   ```

The backend server will start on `http://localhost:3000`

### Available API Endpoints

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login  
- `GET /api/auth/verify` - Verify JWT token
- `GET /api/rooms` - Get all chat rooms
- `POST /api/rooms` - Create new chat room
- `POST /api/rooms/:id/join` - Join chat room
- `POST /api/rooms/:id/leave` - Leave chat room
- `GET /api/rooms/:id/messages` - Get room messages
- `GET /health` - Health check endpoint

## Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Update API endpoints** (if needed):
   - Check `lib/services/auth_service.dart` and `lib/services/api_service.dart`
   - Update `baseUrl` if your backend runs on different host/port

4. **Run the Flutter app**:
   ```bash
   # Web
   flutter run -d chrome
   
   # Desktop (Windows)
   flutter run -d windows
   
   # Mobile (requires emulator/device)
   flutter run
   ```

## Testing the Application

### 1. Register/Login Flow
1. Open the Flutter app
2. Click "Sign Up" to create a new account
3. Fill in username, email, and password
4. After successful registration, you'll be redirected to the room selection

### 2. Chat Room Features
1. **Create Room**: Click the "+" button to create a new chat room
2. **Join Room**: Tap on any room card to join
3. **Real-time Chat**: Send messages and see them appear instantly
4. **Leave Room**: Use the menu in chat screen to leave room

### 3. Multiple Users Testing
1. Open multiple browser tabs or devices
2. Register different users
3. Join the same chat room
4. Test real-time messaging between users

## Troubleshooting

### Backend Issues

**Port already in use**:
```bash
# Kill process on port 3000
npx kill-port 3000
```

**MongoDB connection issues**:
- Check if MongoDB is running: `mongod --version`
- Verify connection string in `.env`
- For MongoDB Atlas, ensure IP whitelist includes your IP

**JWT token issues**:
- Make sure `JWT_SECRET` is set in `.env`
- Clear browser storage if tokens are corrupted

### Frontend Issues

**Package conflicts**:
```bash
flutter clean
flutter pub get
```

**Socket connection issues**:
- Verify backend is running on correct port
- Check CORS settings in backend
- Ensure firewall allows connections

**Build issues**:
```bash
# Analyze issues
flutter analyze

# Check outdated packages
flutter pub outdated
```

## Development Tips

### Backend Development
- Use `npm run dev` for hot reload during development
- Add `console.log` statements for debugging
- Use MongoDB Compass for database visualization
- Test API endpoints with Postman or curl

### Frontend Development
- Use Flutter DevTools for debugging
- Hot reload: `r` in terminal or save files in IDE
- Check Flutter Inspector for UI debugging
- Use `print()` statements for debugging (though avoid in production)

### Database Management
- View collections: Users, ChatRooms, Messages
- Clear test data: `db.dropDatabase()` in MongoDB shell
- Backup important data before testing

## Production Deployment

### Backend
1. Build the TypeScript project: `npm run build`
2. Set production environment variables
3. Use PM2 or similar for process management
4. Set up reverse proxy (Nginx/Apache)
5. Enable HTTPS
6. Use MongoDB Atlas for production database

### Frontend
1. Build for web: `flutter build web`
2. Deploy built files to web server
3. Update API endpoints to production URLs
4. Configure HTTPS and proper CORS settings

## Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Flutter App   │────▶│   Express API   │────▶│    MongoDB      │
│                 │     │                 │     │                 │
│ • Authentication│     │ • JWT Auth      │     │ • Users         │
│ • Chat Rooms    │     │ • Room Mgmt     │     │ • Chat Rooms    │
│ • Real-time UI  │     │ • Message API   │     │ • Messages      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                        │
         └────────────────────────┘
              Socket.io Connection
              (Real-time messaging)
```

The application uses JWT for authentication, REST APIs for data operations, and Socket.io for real-time messaging.

## Security Considerations

- Change default JWT secret in production
- Use HTTPS in production
- Validate all user inputs
- Implement rate limiting
- Use environment variables for sensitive data
- Regular security audits and updates

## Support

For issues or questions:
1. Check this documentation first
2. Review error logs in terminal/console
3. Check network connectivity and ports
4. Verify all services are running
5. Test with simple scenarios first