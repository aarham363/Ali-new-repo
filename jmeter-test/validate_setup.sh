#!/bin/bash

# Setup Validation Script for Melpot API Load Test
# This script validates the API connectivity and authentication before running load tests

set -e

echo "🔍 Validating Melpot API Load Test Setup"
echo "========================================"

# Load configuration
CONFIG_FILE="config/melpot_test.properties"
if [ -f "$CONFIG_FILE" ]; then
    echo "📋 Loading configuration from $CONFIG_FILE"
    source <(grep = "$CONFIG_FILE" | sed 's/[[:space:]]*=[[:space:]]*/=/g')
else
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo ""
echo "🔧 Test Configuration:"
echo "  - Domain: $domain"
echo "  - API Key: ${api_key:0:8}...${api_key: -8}"
echo "  - Username: $username"

# Test 1: Basic connectivity
echo ""
echo "🌐 Testing API Connectivity..."
echo "=============================="

if curl -s --max-time 10 "$domain" > /dev/null 2>&1; then
    echo "✅ API domain is reachable: $domain"
else
    echo "❌ API domain is not reachable: $domain"
    echo "Please check your internet connection and domain URL"
    exit 1
fi

# Test 2: Authentication test
echo ""
echo "🔐 Testing Authentication..."
echo "============================"

# Create login payload
login_payload=$(cat <<EOF
{
  "loginId": "$username",
  "password": "$password",
  "location": "New York, USA",
  "latitude": "40.712776",
  "longitude": "-74.005974",
  "udid": "validation-test-${RANDOM}",
  "deviceName": "Validation Device",
  "deviceType": "iOS",
  "deviceToken": "validation-token-${RANDOM}",
  "fcmToken": "validation-fcm-${RANDOM}",
  "osVersion": "iOS 15.4"
}
EOF
)

# Test login endpoint
echo "Attempting login to: $domain/auth/login/"
response=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -H "api-key: $api_key" \
    -d "$login_payload" \
    "$domain/auth/login/" 2>/dev/null || echo -e "\n000")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    echo "✅ Authentication successful (HTTP $http_code)"
    
    # Extract token for further testing
    access_token=$(echo "$response_body" | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)
    user_id=$(echo "$response_body" | grep -o '"user_id":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$access_token" ] && [ "$access_token" != "null" ]; then
        echo "✅ Access token extracted: ${access_token:0:20}..."
    else
        echo "⚠️ Could not extract access token from response"
        echo "Response: $response_body"
    fi
    
    if [ -n "$user_id" ] && [ "$user_id" != "null" ]; then
        echo "✅ User ID extracted: $user_id"
    else
        echo "⚠️ Could not extract user ID from response"
    fi
else
    echo "❌ Authentication failed (HTTP $http_code)"
    echo "Response: $response_body"
    echo ""
    echo "Please check:"
    echo "1. Username and password are correct"
    echo "2. API key is valid"
    echo "3. API endpoint is accessible"
    exit 1
fi

# Test 3: API endpoint test
if [ -n "$access_token" ]; then
    echo ""
    echo "🔗 Testing API Endpoints..."
    echo "==========================="
    
    # Test home feed endpoint
    echo "Testing home feed endpoint..."
    feed_response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "api-key: $api_key" \
        -H "access_token: $access_token" \
        -d '{"page": 1, "limit": 5}' \
        "$domain/api/v2/feed/home_post_list" 2>/dev/null || echo -e "\n000")
    
    feed_http_code=$(echo "$feed_response" | tail -n1)
    
    if [ "$feed_http_code" = "200" ]; then
        echo "✅ Home feed endpoint working (HTTP $feed_http_code)"
    else
        echo "⚠️ Home feed endpoint returned HTTP $feed_http_code"
        feed_body=$(echo "$feed_response" | head -n -1)
        echo "Response: ${feed_body:0:200}..."
    fi
fi

# Test 4: JMeter setup validation
echo ""
echo "⚙️ Validating JMeter Setup..."
echo "============================="

JMETER_HOME="/workspace/jmeter"
if [ ! -f "$JMETER_HOME/bin/jmeter" ]; then
    echo "❌ JMeter not found at $JMETER_HOME"
    exit 1
else
    echo "✅ JMeter found at $JMETER_HOME"
fi

# Test JMeter version
jmeter_version=$("$JMETER_HOME/bin/jmeter" --version 2>/dev/null | grep "Apache JMeter" | head -n1)
if [ -n "$jmeter_version" ]; then
    echo "✅ JMeter version: $jmeter_version"
else
    echo "⚠️ Could not determine JMeter version"
fi

# Test 5: Java setup
echo ""
echo "☕ Validating Java Setup..."
echo "=========================="

java_version=$(java -version 2>&1 | head -n1)
echo "✅ Java version: $java_version"

# Check heap settings
if [ -n "$HEAP" ]; then
    echo "✅ Custom heap settings: $HEAP"
else
    echo "ℹ️ Using default heap settings"
fi

# Test 6: File permissions and directories
echo ""
echo "📁 Validating File System..."
echo "============================"

# Check test plan file
if [ -f "melpot_api_test.jmx" ]; then
    echo "✅ Test plan file found: melpot_api_test.jmx"
else
    echo "❌ Test plan file not found: melpot_api_test.jmx"
    exit 1
fi

# Check execution script
if [ -x "run_load_test.sh" ]; then
    echo "✅ Execution script is executable: run_load_test.sh"
else
    echo "❌ Execution script is not executable: run_load_test.sh"
    exit 1
fi

# Check directories
for dir in results reports logs config; do
    if [ -d "$dir" ]; then
        echo "✅ Directory exists: $dir"
    else
        echo "⚠️ Creating directory: $dir"
        mkdir -p "$dir"
    fi
done

# Test 7: Dependencies check
echo ""
echo "📦 Checking Dependencies..."
echo "=========================="

# Check for required tools
for cmd in curl grep awk sed bc; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ $cmd available"
    else
        echo "⚠️ $cmd not found (some features may not work)"
    fi
done

echo ""
echo "🎯 Validation Summary"
echo "===================="
echo "✅ API connectivity: PASSED"
echo "✅ Authentication: PASSED"
echo "✅ JMeter setup: PASSED"
echo "✅ File system: PASSED"
echo ""
echo "🚀 Ready to run load tests!"
echo ""
echo "Next steps:"
echo "1. Run a quick test: ./run_load_test.sh -t 2 -r 10 -d 30"
echo "2. Run full test: ./run_load_test.sh"
echo "3. Check results in: results/{timestamp}/"
echo ""
echo "For help: ./run_load_test.sh --help"