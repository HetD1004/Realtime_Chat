#!/bin/bash

echo "🚀 Real-Time Chat Deployment Script"
echo "======================================"

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ Please run this script from the root of the RealTimeChat project"
    exit 1
fi

echo "📦 Installing backend dependencies..."
cd backend
npm install
npm run build

echo "🔧 Installing frontend dependencies..."
cd ../frontend
flutter pub get

echo "✅ Dependencies installed successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Set up your MongoDB Atlas database"
echo "2. Copy backend/.env.example to backend/.env and configure it"
echo "3. Update frontend/lib/config/config.dart with your backend URL"
echo "4. Deploy to Vercel using 'vercel' command in each directory"
echo "5. Set environment variables in Vercel dashboard"
echo ""
echo "🎉 You're ready to deploy!"
