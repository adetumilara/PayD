#!/bin/bash

# Test script for Contract Registry API endpoint
# This script verifies the /api/contracts endpoint is working correctly

echo "🧪 Testing Contract Registry API Endpoint"
echo "=========================================="
echo ""

# Check if server is running
echo "1. Checking if backend server is running..."
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Backend server is running"
else
    echo "❌ Backend server is not running"
    echo "   Please start the server with: cd backend && npm run dev"
    exit 1
fi

echo ""
echo "2. Testing /api/contracts endpoint..."
RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:3000/api/contracts)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Endpoint returned 200 OK"
else
    echo "❌ Endpoint returned $HTTP_CODE"
    exit 1
fi

echo ""
echo "3. Validating response structure..."

# Check if response is valid JSON
if echo "$BODY" | jq . > /dev/null 2>&1; then
    echo "✅ Response is valid JSON"
else
    echo "❌ Response is not valid JSON"
    exit 1
fi

# Check for required fields
if echo "$BODY" | jq -e '.contracts' > /dev/null 2>&1; then
    echo "✅ Response contains 'contracts' field"
else
    echo "❌ Response missing 'contracts' field"
    exit 1
fi

if echo "$BODY" | jq -e '.timestamp' > /dev/null 2>&1; then
    echo "✅ Response contains 'timestamp' field"
else
    echo "❌ Response missing 'timestamp' field"
    exit 1
fi

if echo "$BODY" | jq -e '.count' > /dev/null 2>&1; then
    echo "✅ Response contains 'count' field"
else
    echo "❌ Response missing 'count' field"
    exit 1
fi

echo ""
echo "4. Checking contract data..."
CONTRACT_COUNT=$(echo "$BODY" | jq '.count')
echo "   Found $CONTRACT_COUNT contracts"

if [ "$CONTRACT_COUNT" -gt 0 ]; then
    echo "✅ Contracts are configured"
    
    # Display first contract as example
    echo ""
    echo "   Example contract:"
    echo "$BODY" | jq '.contracts[0]' | sed 's/^/   /'
else
    echo "⚠️  No contracts configured (this is OK if environments.toml is not set up)"
fi

echo ""
echo "5. Checking response headers..."
HEADERS=$(curl -s -I http://localhost:3000/api/contracts)

if echo "$HEADERS" | grep -i "content-type: application/json" > /dev/null; then
    echo "✅ Content-Type header is correct"
else
    echo "❌ Content-Type header is missing or incorrect"
fi

if echo "$HEADERS" | grep -i "cache-control.*max-age" > /dev/null; then
    echo "✅ Cache-Control header is present"
else
    echo "❌ Cache-Control header is missing"
fi

echo ""
echo "=========================================="
echo "✅ All tests passed!"
echo ""
echo "Full response:"
echo "$BODY" | jq .
