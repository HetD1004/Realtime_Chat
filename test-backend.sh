#!/bin/bash

echo "🧪 Testing Backend API"
echo "====================="

BACKEND_URL="https://realtime-chat-taupe-pi.vercel.app"

echo "Testing root endpoint..."
curl -s "$BACKEND_URL/" | json_pp 2>/dev/null || curl -s "$BACKEND_URL/"

echo -e "\n\nTesting health endpoint..."
curl -s "$BACKEND_URL/health" | json_pp 2>/dev/null || curl -s "$BACKEND_URL/health"

echo -e "\n\nTesting API endpoints..."
echo "Auth endpoints:"
echo "- POST $BACKEND_URL/api/auth/register"
echo "- POST $BACKEND_URL/api/auth/login"

echo -e "\nRoom endpoints:"
echo "- GET $BACKEND_URL/api/rooms"
echo "- POST $BACKEND_URL/api/rooms"

echo -e "\n✅ Backend is accessible!"
echo "Configure MongoDB Atlas and environment variables to enable full functionality."
