# Real-Time Chat Deployment Script for Windows
Write-Host "🚀 Real-Time Chat Deployment Script" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Check if we're in the right directory
if (!(Test-Path "README.md") -or !(Test-Path "backend") -or !(Test-Path "frontend")) {
    Write-Host "❌ Please run this script from the root of the RealTimeChat project" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing backend dependencies..." -ForegroundColor Blue
Set-Location backend
npm install
npm run build

Write-Host "🔧 Installing frontend dependencies..." -ForegroundColor Blue
Set-Location ../frontend
flutter pub get

Write-Host "✅ Dependencies installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Yellow
Write-Host "1. Set up your MongoDB Atlas database"
Write-Host "2. Copy backend/.env.example to backend/.env and configure it"
Write-Host "3. Update frontend/lib/config/config.dart with your backend URL"
Write-Host "4. Deploy to Vercel using 'vercel' command in each directory"
Write-Host "5. Set environment variables in Vercel dashboard"
Write-Host ""
Write-Host "🎉 You're ready to deploy!" -ForegroundColor Green
