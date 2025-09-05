#!/bin/bash

echo "🚀 Deploying Frontend to Vercel"
echo "==============================="

# Check if we're in the correct directory
if [ ! -d "frontend" ]; then
    echo "❌ Please run this script from the root directory of RealTimeChat"
    exit 1
fi

# Navigate to frontend directory
cd frontend

echo "📦 Building Flutter web app..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Flutter build failed"
    exit 1
fi

echo "🌐 Deploying to Vercel..."
vercel --cwd build/web --prod

if [ $? -eq 0 ]; then
    echo "✅ Frontend deployed successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Note your frontend URL from the deployment output"
    echo "2. Go to your backend Vercel project settings"
    echo "3. Update the FRONTEND_URL environment variable"
    echo "4. Redeploy your backend"
    echo ""
    echo "🎉 Your chat app should be fully functional!"
else
    echo "❌ Deployment failed"
    exit 1
fi
