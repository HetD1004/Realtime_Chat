# Deploy Frontend to Vercel (PowerShell)

Write-Host "🚀 Deploying Frontend to Vercel" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Check if we're in the correct directory
if (!(Test-Path "frontend")) {
    Write-Host "❌ Please run this script from the root directory of RealTimeChat" -ForegroundColor Red
    exit 1
}

# Navigate to frontend directory
Set-Location frontend

Write-Host "📦 Building Flutter web app..." -ForegroundColor Blue
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter build failed" -ForegroundColor Red
    exit 1
}

Write-Host "🌐 Deploying to Vercel..." -ForegroundColor Blue
vercel --cwd build/web --prod

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Frontend deployed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next steps:" -ForegroundColor Yellow
    Write-Host "1. Note your frontend URL from the deployment output"
    Write-Host "2. Go to your backend Vercel project settings"
    Write-Host "3. Update the FRONTEND_URL environment variable"
    Write-Host "4. Redeploy your backend"
    Write-Host ""
    Write-Host "🎉 Your chat app should be fully functional!" -ForegroundColor Green
} else {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
    exit 1
}
