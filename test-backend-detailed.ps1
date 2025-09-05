# Test if backend is working properly

Write-Host "🧪 Testing Backend API Endpoints" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$BackendUrl = "https://realtime-chat-taupe-pi.vercel.app"

Write-Host "Testing root endpoint..." -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri $BackendUrl -Method Get
    Write-Host "✅ Root endpoint working!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Root endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTesting health endpoint..." -ForegroundColor Blue  
try {
    $response = Invoke-RestMethod -Uri "$BackendUrl/health" -Method Get
    Write-Host "✅ Health endpoint working!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTesting API structure..." -ForegroundColor Blue
Write-Host "Available endpoints should be:" -ForegroundColor Yellow
Write-Host "- POST $BackendUrl/api/auth/register"
Write-Host "- POST $BackendUrl/api/auth/login"  
Write-Host "- GET $BackendUrl/api/rooms"
Write-Host "- POST $BackendUrl/api/rooms"

Write-Host "`n📝 Next steps:" -ForegroundColor Cyan
Write-Host "1. If endpoints are working, your backend is ready!"
Write-Host "2. Set up environment variables in Vercel dashboard"
Write-Host "3. Deploy your frontend"
Write-Host "4. Test the complete application"
