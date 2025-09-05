# 🚀 Quick Deployment Checklist

## ✅ Completed
- [x] Backend deployed to Vercel: `https://realtime-chat-taupe-pi.vercel.app`
- [x] Frontend configuration updated with backend URL
- [x] Repository pushed to GitHub
- [x] Deployment scripts created

## 📋 Next Steps

### 1. Set up MongoDB Atlas (Required)
```bash
# Go to https://www.mongodb.com/cloud/atlas
# Create a free cluster
# Get your connection string
```

### 2. Configure Backend Environment Variables
Go to [Vercel Dashboard](https://vercel.com/dashboard) → Your Backend Project → Settings → Environment Variables

Add these variables:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/realtime-chat
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
NODE_ENV=production
FRONTEND_URL=https://your-frontend-domain.vercel.app
```

### 3. Deploy Frontend
Run the deployment script:
```bash
# Windows (PowerShell)
.\deploy-frontend.ps1

# macOS/Linux
chmod +x deploy-frontend.sh && ./deploy-frontend.sh
```

### 4. Update Backend CORS
After frontend deployment:
1. Note your frontend URL
2. Update `FRONTEND_URL` environment variable in backend
3. Redeploy backend (or wait for auto-deployment)

### 5. Test Your Application
- Visit your frontend URL
- Create an account
- Try sending messages
- Test real-time functionality

## 🔧 Troubleshooting

### Backend Issues
- Check Vercel function logs for errors
- Verify MongoDB connection string
- Ensure all environment variables are set

### Frontend Issues
- Check browser console for errors
- Verify backend URL in config.dart
- Test API endpoints directly

### CORS Issues
- Ensure FRONTEND_URL matches exactly
- No trailing slashes in URLs
- Check browser network tab for CORS errors

## 📞 Support
- Check deployment logs in Vercel dashboard
- Review browser developer tools
- Test API endpoints: `https://realtime-chat-taupe-pi.vercel.app/health`

---

**Your backend is ready! Complete steps 1-4 to have a fully functional chat application.** 🎉
