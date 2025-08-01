#!/bin/bash

# Melpot API Load Test Execution Script
# This script runs the JMeter load test with proper configuration and generates reports

set -e  # Exit on any error

echo "🚀 Starting Melpot API Load Test"
echo "=================================="

# Configuration
JMETER_HOME="/workspace/jmeter"
TEST_PLAN="melpot_api_test.jmx"
CONFIG_FILE="config/melpot_test.properties"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create timestamped results directory
RESULTS_DIR="results/${TIMESTAMP}"
REPORT_DIR="reports/${TIMESTAMP}"
mkdir -p "$RESULTS_DIR" "$REPORT_DIR"

# Load configuration from properties file
if [ -f "$CONFIG_FILE" ]; then
    echo "📋 Loading configuration from $CONFIG_FILE"
    source <(grep = "$CONFIG_FILE" | sed 's/[[:space:]]*=[[:space:]]*/=/g')
else
    echo "⚠️ Configuration file not found, using defaults"
    domain="https://dev.melpotapp.de"
    api_key="dr2ROX4BJzfp3ZBrhZpRdkpx6pv/E9wiHyq8LrMOE24nAv0WBT+449WK/BZGh3q6"
    username="odin"
    password="1234"
    threads=10
    rampup=60
    duration=300
fi

# Override with command line arguments if provided
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--threads)
            threads="$2"
            shift 2
            ;;
        -r|--rampup)
            rampup="$2"
            shift 2
            ;;
        -d|--duration)
            duration="$2"
            shift 2
            ;;
        -u|--username)
            username="$2"
            shift 2
            ;;
        -p|--password)
            password="$2"
            shift 2
            ;;
        --domain)
            domain="$2"
            shift 2
            ;;
        --api-key)
            api_key="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -t, --threads NUM     Number of threads (default: 10)"
            echo "  -r, --rampup SEC      Ramp-up time in seconds (default: 60)"
            echo "  -d, --duration SEC    Test duration in seconds (default: 300)"
            echo "  -u, --username USER   Username for authentication"
            echo "  -p, --password PASS   Password for authentication"
            echo "  --domain URL          API domain URL"
            echo "  --api-key KEY         API key for authentication"
            echo "  -h, --help            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate JMeter installation
if [ ! -f "$JMETER_HOME/bin/jmeter" ]; then
    echo "❌ JMeter not found at $JMETER_HOME"
    echo "Please ensure JMeter is properly installed"
    exit 1
fi

# Validate test plan
if [ ! -f "$TEST_PLAN" ]; then
    echo "❌ Test plan file not found: $TEST_PLAN"
    exit 1
fi

echo "🔧 Test Configuration:"
echo "  - Domain: $domain"
echo "  - API Key: ${api_key:0:8}...${api_key: -8}"
echo "  - Username: $username"
echo "  - Threads: $threads"
echo "  - Ramp-up: ${rampup}s"
echo "  - Duration: ${duration}s"
echo "  - Results: $RESULTS_DIR"
echo "  - Report: $REPORT_DIR"

# Set JMeter properties
export HEAP="-Xms1g -Xmx2g -XX:MaxMetaspaceSize=256m"

# Results files
RESULTS_FILE="$RESULTS_DIR/results.jtl"
SUMMARY_FILE="$RESULTS_DIR/summary.jtl"
LOG_FILE="$RESULTS_DIR/jmeter.log"

echo ""
echo "🏃 Executing Load Test..."
echo "========================="

# Execute JMeter test
"$JMETER_HOME/bin/jmeter" \
    -n \
    -t "$TEST_PLAN" \
    -Jdomain="$domain" \
    -Japi_key="$api_key" \
    -Jusername="$username" \
    -Jpassword="$password" \
    -Jthreads="$threads" \
    -Jrampup="$rampup" \
    -Jduration="$duration" \
    -l "$RESULTS_FILE" \
    -j "$LOG_FILE" \
    -e \
    -o "$REPORT_DIR" \
    -Jjmeter.reportgenerator.overall_granularity=1000 \
    -Jjmeter.reportgenerator.graph.responseTimeDistribution.property.set_granularity=100

echo ""
echo "📊 Generating Summary Report..."
echo "==============================="

# Generate summary CSV
if [ -f "$RESULTS_FILE" ]; then
    echo "timestamp,label,responseTime,responseCode,success,threadName,grpThreads,allThreads,latency,connect" > "$RESULTS_DIR/performance_summary.csv"
    tail -n +2 "$RESULTS_FILE" | cut -d',' -f1,3,2,4,8,14,15,16,9,10 >> "$RESULTS_DIR/performance_summary.csv"
    
    # Calculate basic statistics
    echo "📈 Test Results Summary:" > "$RESULTS_DIR/test_summary.txt"
    echo "========================" >> "$RESULTS_DIR/test_summary.txt"
    echo "Test completed at: $(date)" >> "$RESULTS_DIR/test_summary.txt"
    echo "Results location: $RESULTS_DIR" >> "$RESULTS_DIR/test_summary.txt"
    echo "HTML Report: $REPORT_DIR/index.html" >> "$RESULTS_DIR/test_summary.txt"
    echo "" >> "$RESULTS_DIR/test_summary.txt"
    
    # Count total samples
    TOTAL_SAMPLES=$(tail -n +2 "$RESULTS_FILE" | wc -l)
    SUCCESS_SAMPLES=$(tail -n +2 "$RESULTS_FILE" | grep ",true," | wc -l)
    ERROR_SAMPLES=$((TOTAL_SAMPLES - SUCCESS_SAMPLES))
    ERROR_RATE=$(echo "scale=2; $ERROR_SAMPLES * 100 / $TOTAL_SAMPLES" | bc -l 2>/dev/null || echo "0.00")
    
    echo "Total Samples: $TOTAL_SAMPLES" >> "$RESULTS_DIR/test_summary.txt"
    echo "Successful: $SUCCESS_SAMPLES" >> "$RESULTS_DIR/test_summary.txt"
    echo "Errors: $ERROR_SAMPLES" >> "$RESULTS_DIR/test_summary.txt"
    echo "Error Rate: ${ERROR_RATE}%" >> "$RESULTS_DIR/test_summary.txt"
    
    # Calculate response time statistics
    if command -v awk >/dev/null 2>&1; then
        tail -n +2 "$RESULTS_FILE" | grep ",true," | cut -d',' -f2 | awk '
            {
                times[NR] = $1
                sum += $1
                if ($1 > max) max = $1
                if (min == 0 || $1 < min) min = $1
            }
            END {
                if (NR > 0) {
                    avg = sum / NR
                    # Sort for percentiles
                    asort(times)
                    p95_idx = int(NR * 0.95)
                    p99_idx = int(NR * 0.99)
                    print "Average Response Time: " avg " ms"
                    print "Min Response Time: " min " ms"
                    print "Max Response Time: " max " ms"
                    print "95th Percentile: " times[p95_idx] " ms"
                    print "99th Percentile: " times[p99_idx] " ms"
                }
            }
        ' >> "$RESULTS_DIR/test_summary.txt"
    fi
    
    echo "" >> "$RESULTS_DIR/test_summary.txt"
    echo "Log file: $LOG_FILE" >> "$RESULTS_DIR/test_summary.txt"
    
    cat "$RESULTS_DIR/test_summary.txt"
else
    echo "⚠️ Results file not found: $RESULTS_FILE"
fi

echo ""
echo "✅ Load Test Completed!"
echo "======================="
echo "📁 Results saved to: $RESULTS_DIR"
echo "📊 HTML Report: $REPORT_DIR/index.html"
echo "📋 Summary: $RESULTS_DIR/test_summary.txt"

# Security cleanup
echo ""
echo "🔒 Cleaning up sensitive data from logs..."
if [ -f "$LOG_FILE" ]; then
    # Remove sensitive information from logs (passwords, tokens)
    sed -i 's/password=[^,&]*/password=***REDACTED***/g' "$LOG_FILE" 2>/dev/null || true
    sed -i 's/api_key=[^,&]*/api_key=***REDACTED***/g' "$LOG_FILE" 2>/dev/null || true
    sed -i 's/accessToken":"[^"]*"/accessToken":"***REDACTED***"/g' "$LOG_FILE" 2>/dev/null || true
fi

echo "🔐 Security cleanup completed"
echo ""
echo "🎯 Next Steps:"
echo "1. Review the HTML report: file://$PWD/$REPORT_DIR/index.html"
echo "2. Analyze performance metrics in: $RESULTS_DIR/performance_summary.csv"
echo "3. Check for errors in: $LOG_FILE"

# Check for performance issues
if [ -f "$RESULTS_DIR/test_summary.txt" ]; then
    if grep -q "Error Rate: 0.00%" "$RESULTS_DIR/test_summary.txt"; then
        echo "✅ No errors detected"
    else
        echo "⚠️ Errors detected - please review the results"
    fi
fi