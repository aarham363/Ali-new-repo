#!/bin/bash

echo "🚀 Starting Simplified Melpot API Load Test"
echo "==========================================="

JMETER_HOME="/workspace/jmeter"
TEST_PLAN="melpot_simple.jmx"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

domain="${1:-https://dev.melpotapp.de}"
username="${2:-odin}"
password="${3:-1234}"
threads="${4:-2}"
duration="${5:-30}"

RESULTS_DIR="results/${TIMESTAMP}"
mkdir -p "$RESULTS_DIR"

echo "�� Test Configuration:"
echo "  - Domain: $domain"
echo "  - Username: $username"  
echo "  - Threads: $threads"
echo "  - Duration: ${duration}s"

RESULTS_FILE="$RESULTS_DIR/results.jtl"

echo ""
echo "🏃 Executing Load Test..."

"$JMETER_HOME/bin/jmeter" \
    -n \
    -t "$TEST_PLAN" \
    -Jdomain="$domain" \
    -Jusername="$username" \
    -Jpassword="$password" \
    -Jthreads="$threads" \
    -Jduration="$duration" \
    -l "$RESULTS_FILE"

echo ""
echo "📊 Test Results:"

if [ -f "$RESULTS_FILE" ]; then
    TOTAL_SAMPLES=$(tail -n +2 "$RESULTS_FILE" | wc -l)
    echo "Total Samples: $TOTAL_SAMPLES"
    
    if [ "$TOTAL_SAMPLES" -gt 0 ]; then
        echo "Sample Results:"
        tail -n +2 "$RESULTS_FILE" | head -3
    fi
else
    echo "❌ Results file not found"
fi

echo "✅ Test completed!"
