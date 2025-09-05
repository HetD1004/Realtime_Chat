# Deployment Guide

This guide will walk you through deploying the Real-Time Chat application to Vercel.

## Prerequisites

- [Vercel Account](https://vercel.com/signup)
- [MongoDB Atlas Account](https://www.mongodb.com/cloud/atlas)
- [Node.js 18+](https://nodejs.org/)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Git](https://git-scm.com/)

## Step 1: Set up MongoDB Atlas

1. Create a MongoDB Atlas account
2. Create a new cluster
3. Create a database user with read/write permissions
4. Whitelist your IP address (or use 0.0.0.0/0 for all IPs)
5. Get your connection string

## Step 2: Prepare Your Code

1. Clone/download your repository
2. Run the setup script:
   ```bash
   # On macOS/Linux
   chmod +x setup.sh && ./setup.sh
   
   # On Windows (PowerShell)
   .\setup.ps1
   ```

## Step 3: Deploy Backend to Vercel

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Install Vercel CLI:
   ```bash
   npm i -g vercel
   ```

3. Deploy to Vercel:
   ```bash
   vercel
   ```

4. Follow the prompts:
   - Set up and deploy? `Y`
   - Which scope? Choose your account
   - Link to existing project? `N`
   - Project name? `realtime-chat-backend`
   - Directory? `./` (current directory)

5. Set environment variables in Vercel dashboard:
   - Go to your project in Vercel dashboard
   - Go to Settings → Environment Variables
   - Add the following variables:
     ```
     MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/realtime-chat
     JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
     NODE_ENV=production
     FRONTEND_URL=https://your-frontend-domain.vercel.app (will be set after frontend deployment)
     ```

6. Redeploy after setting environment variables:
   ```bash
   vercel --prod
   ```

7. Note your backend URL (e.g., `https://realtime-chat-backend.vercel.app`)

## Step 4: Update Frontend Configuration

1. Navigate to frontend directory:
   ```bash
   cd ../frontend
   ```

2. Open `lib/config/config.dart` and update the URLs:
   ```dart
   class Config {
     static const String _devBaseUrl = 'http://localhost:3000/api';
     static const String _prodBaseUrl = 'https://YOUR-BACKEND-URL.vercel.app/api';
     
     static const bool _isProduction = bool.fromEnvironment('dart.vm.product');
     
     static String get baseUrl => _isProduction ? _prodBaseUrl : _devBaseUrl;
     static String get socketUrl => _isProduction 
       ? 'https://YOUR-BACKEND-URL.vercel.app' 
       : 'http://localhost:3000';
   }
   ```

## Step 5: Deploy Frontend to Vercel

1. Build the Flutter web app:
   ```bash
   flutter build web --release
   ```

2. Deploy the build folder:
   ```bash
   vercel --cwd build/web
   ```

3. Follow the prompts:
   - Set up and deploy? `Y`
   - Which scope? Choose your account
   - Link to existing project? `N`
   - Project name? `realtime-chat-frontend`

4. Note your frontend URL (e.g., `https://realtime-chat-frontend.vercel.app`)

## Step 6: Update Backend CORS

1. Go back to your backend Vercel project
2. Update the `FRONTEND_URL` environment variable with your actual frontend URL
3. Redeploy the backend:
   ```bash
   cd ../backend
   vercel --prod
   ```

## Step 7: Test Your Deployment

1. Open your frontend URL
2. Create a new account
3. Try sending messages
4. Open another browser/incognito window to test real-time messaging

## Automated Deployment with GitHub Actions

1. Push your code to GitHub
2. Set up the following secrets in your GitHub repository:
   - `VERCEL_TOKEN`: Get from Vercel account settings
   - `ORG_ID`: Get from Vercel team settings
   - `PROJECT_ID`: Get from backend project settings in Vercel
   - `PROJECT_ID_FRONTEND`: Get from frontend project settings in Vercel

3. Push to main branch to trigger automatic deployment

## Troubleshooting

### CORS Issues
- Ensure `FRONTEND_URL` is set correctly in backend environment variables
- Check that your frontend URL matches exactly (no trailing slash)

### Socket Connection Issues
- Verify your backend URL is correct in frontend config
- Check browser developer tools for WebSocket connection errors

### Database Connection Issues
- Verify MongoDB Atlas connection string
- Check IP whitelist in MongoDB Atlas
- Ensure database user has proper permissions

### Build Issues
- Ensure all dependencies are installed
- Check that TypeScript compiles without errors
- Verify Flutter web build completes successfully

## Environment Variables Reference

### Backend
```
PORT=3000
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/realtime-chat
JWT_SECRET=minimum-32-character-secret-key-for-production
FRONTEND_URL=https://your-frontend-domain.vercel.app
NODE_ENV=production
```

### Frontend
Update `frontend/lib/config/config.dart` with your actual Vercel URLs.

## Support

If you encounter issues:
1. Check Vercel deployment logs
2. Review browser console for errors
3. Verify all environment variables are set correctly
4. Test locally first before deploying

---

Happy deploying! 🚀
