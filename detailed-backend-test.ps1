# Detailed Backend Test
Write-Host "🔍 Detailed Backend Analysis..." -ForegroundColor Yellow

$backendUrl = "https://realtime-chat-7xszyq30u-hetd1004s-projects.vercel.app"

# Test 1: Basic connectivity
Write-Host "`n1. Testing Basic Connectivity:" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri $backendUrl -Method GET -UseBasicParsing
    Write-Host "✅ Backend is reachable" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor White
    Write-Host "Content Preview: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))" -ForegroundColor White
} catch {
    Write-Host "❌ Backend not reachable: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
}

# Test 2: Health endpoint with detailed error handling
Write-Host "`n2. Testing Health Endpoint:" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "$backendUrl/health" -Method GET -UseBasicParsing
    Write-Host "✅ Health endpoint working" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "❌ Health endpoint failed" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Error Response: $responseBody" -ForegroundColor Yellow
    }
}

# Test 3: Registration endpoint
Write-Host "`n3. Testing Registration with detailed logging:" -ForegroundColor Cyan
$testData = @{
    username = "testuser$(Get-Random -Maximum 10000)"
    email = "test$(Get-Random -Maximum 10000)@example.com"
    password = "TestPassword123!"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$backendUrl/api/auth/register" -Method POST -Body $testData -ContentType "application/json" -UseBasicParsing
    Write-Host "✅ Registration working" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "❌ Registration failed" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Error Details: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host "`n🏁 Detailed test completed!" -ForegroundColor Yellow
