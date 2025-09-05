# Test Backend Connection
Write-Host "🔍 Testing Backend Connection..." -ForegroundColor Yellow

# Test backend root endpoint
Write-Host "`n1. Testing Root Endpoint:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app/" -Method GET
    Write-Host "✅ Root endpoint working" -ForegroundColor Green
    Write-Host "Message: $($response.message)" -ForegroundColor White
} catch {
    Write-Host "❌ Root endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test health endpoint
Write-Host "`n2. Testing Health Endpoint:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app/health" -Method GET
    Write-Host "✅ Health endpoint working" -ForegroundColor Green
    Write-Host "Status: $($response.status)" -ForegroundColor White
} catch {
    Write-Host "❌ Health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test registration endpoint with dummy data
Write-Host "`n3. Testing Registration Endpoint:" -ForegroundColor Cyan
$testUser = @{
    username = "testuser$(Get-Random -Maximum 1000)"
    email = "test$(Get-Random -Maximum 1000)@test.com"
    password = "testpassword123"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app/api/auth/register" -Method POST -Body $testUser -ContentType "application/json"
    Write-Host "✅ Registration endpoint working" -ForegroundColor Green
    Write-Host "Message: $($response.message)" -ForegroundColor White
} catch {
    $errorBody = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($errorBody) {
        Write-Host "⚠️  Registration endpoint response: $($errorBody.message)" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Registration endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🏁 Backend connection test completed!" -ForegroundColor Yellow
