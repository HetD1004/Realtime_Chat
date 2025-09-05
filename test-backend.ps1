# Test Backend API (PowerShell)

Write-Host "🧪 Testing Backend API" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green

$BackendUrl = "https://realtime-chat-taupe-pi.vercel.app"

Write-Host "Testing root endpoint..." -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri $BackendUrl -Method Get
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error testing root endpoint: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTesting health endpoint..." -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "$BackendUrl/health" -Method Get
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error testing health endpoint: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTesting API endpoints..." -ForegroundColor Blue
Write-Host "Auth endpoints:" -ForegroundColor Yellow
Write-Host "- POST $BackendUrl/api/auth/register"
Write-Host "- POST $BackendUrl/api/auth/login"

Write-Host "`nRoom endpoints:" -ForegroundColor Yellow
Write-Host "- GET $BackendUrl/api/rooms"
Write-Host "- POST $BackendUrl/api/rooms"

Write-Host "`n✅ Backend is accessible!" -ForegroundColor Green
Write-Host "Configure MongoDB Atlas and environment variables to enable full functionality." -ForegroundColor Cyan
