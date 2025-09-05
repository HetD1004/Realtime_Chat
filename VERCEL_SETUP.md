# Vercel Environment Variables Setup

## Backend Environment Variables

Set these in your Vercel dashboard for the backend project:

```bash
# Database
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/realtime-chat?retryWrites=true&w=majority

# Authentication
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters

# Environment
NODE_ENV=production

# CORS - Update this with your frontend Vercel URL
FRONTEND_URL=https://your-frontend-domain.vercel.app
```

## How to Set Environment Variables in Vercel:

1. Go to your Vercel dashboard
2. Select your backend project: `realtime-chat-taupe-pi`
3. Go to Settings → Environment Variables
4. Add each variable above
5. Redeploy your backend

## Your Current Backend URL:
`https://realtime-chat-taupe-pi.vercel.app`

## Next Steps:

1. Set up MongoDB Atlas and get your connection string
2. Add environment variables to Vercel dashboard
3. Deploy your frontend
4. Update FRONTEND_URL in backend environment variables
5. Test the full application

## Frontend Deployment:

```bash
cd frontend
flutter build web --release
vercel --cwd build/web
```

After frontend deployment, update the `FRONTEND_URL` environment variable in your backend project.
