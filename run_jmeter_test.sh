#!/bin/bash

# JMeter Load Test Runner Script
# This script helps you run JMeter load tests with different configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEST_PLAN="load_test_plan.jmx"
RESULTS_FILE="results.jtl"
REPORT_DIR="jmeter_report"
USERS=50
RAMP_UP=30
DURATION=300
MODE="cli"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}   JMeter Load Test Runner${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --test-plan FILE     Test plan file (default: load_test_plan.jmx)"
    echo "  -u, --users NUMBER       Number of concurrent users (default: 50)"
    echo "  -r, --ramp-up SECONDS    Ramp-up time in seconds (default: 30)"
    echo "  -d, --duration SECONDS   Test duration in seconds (default: 300)"
    echo "  -m, --mode MODE          Test mode: gui or cli (default: cli)"
    echo "  -o, --output DIR         Output directory for reports (default: jmeter_report)"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run with default settings"
    echo "  $0 -u 100 -r 60                       # 100 users, 60s ramp-up"
    echo "  $0 -m gui                             # Run in GUI mode"
    echo "  $0 -u 10 -r 10 -d 60                  # Light load test"
    echo "  $0 -u 200 -r 120 -d 1800              # Heavy load test"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if JMeter is installed
    if ! command -v jmeter &> /dev/null; then
        print_error "JMeter is not installed or not in PATH"
        echo "Please install JMeter first:"
        echo "  Ubuntu/Debian: sudo apt-get install jmeter"
        echo "  CentOS/RHEL: sudo yum install jmeter"
        echo "  macOS: brew install jmeter"
        echo "  Or download from: https://jmeter.apache.org/download_jmeter.cgi"
        exit 1
    fi
    
    # Check if test plan exists
    if [ ! -f "$TEST_PLAN" ]; then
        print_error "Test plan file '$TEST_PLAN' not found"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Function to update test plan parameters
update_test_plan() {
    print_status "Updating test plan parameters..."
    
    # Create a temporary copy of the test plan
    TEMP_PLAN="temp_${TEST_PLAN}"
    cp "$TEST_PLAN" "$TEMP_PLAN"
    
    # Update thread group parameters using sed
    sed -i "s/<stringProp name=\"ThreadGroup.num_threads\">[0-9]*<\/stringProp>/<stringProp name=\"ThreadGroup.num_threads\">$USERS<\/stringProp>/g" "$TEMP_PLAN"
    sed -i "s/<stringProp name=\"ThreadGroup.ramp_time\">[0-9]*<\/stringProp>/<stringProp name=\"ThreadGroup.ramp_time\">$RAMP_UP<\/stringProp>/g" "$TEMP_PLAN"
    
    # If duration is specified, update the scheduler
    if [ "$DURATION" -gt 0 ]; then
        sed -i "s/<boolProp name=\"ThreadGroup.scheduler\">false<\/boolProp>/<boolProp name=\"ThreadGroup.scheduler\">true<\/boolProp>/g" "$TEMP_PLAN"
        sed -i "s/<stringProp name=\"ThreadGroup.duration\"><\/stringProp>/<stringProp name=\"ThreadGroup.duration\">$DURATION<\/stringProp>/g" "$TEMP_PLAN"
    fi
    
    TEST_PLAN="$TEMP_PLAN"
    print_status "Test plan updated with $USERS users, ${RAMP_UP}s ramp-up, ${DURATION}s duration"
}

# Function to run the test
run_test() {
    print_status "Starting JMeter load test..."
    echo "Configuration:"
    echo "  Test Plan: $TEST_PLAN"
    echo "  Users: $USERS"
    echo "  Ramp-up: ${RAMP_UP}s"
    echo "  Duration: ${DURATION}s"
    echo "  Mode: $MODE"
    echo "  Results: $RESULTS_FILE"
    echo "  Report: $REPORT_DIR"
    echo ""
    
    if [ "$MODE" = "gui" ]; then
        print_status "Starting JMeter in GUI mode..."
        jmeter -t "$TEST_PLAN"
    else
        print_status "Starting JMeter in CLI mode..."
        
        # Create output directory
        mkdir -p "$REPORT_DIR"
        
        # Run JMeter
        jmeter -n -t "$TEST_PLAN" -l "$RESULTS_FILE" -e -o "$REPORT_DIR"
        
        print_status "Test completed!"
        print_status "Results saved to: $RESULTS_FILE"
        print_status "HTML report generated in: $REPORT_DIR"
        
        # Show summary
        if [ -f "$RESULTS_FILE" ]; then
            echo ""
            print_status "Test Summary:"
            echo "  Total requests: $(grep -c "true" "$RESULTS_FILE" 2>/dev/null || echo "N/A")"
            echo "  Failed requests: $(grep -c "false" "$RESULTS_FILE" 2>/dev/null || echo "N/A")"
        fi
        
        # Open report if possible
        if command -v xdg-open &> /dev/null; then
            xdg-open "$REPORT_DIR/index.html" 2>/dev/null || true
        elif command -v open &> /dev/null; then
            open "$REPORT_DIR/index.html" 2>/dev/null || true
        fi
    fi
}

# Function to cleanup
cleanup() {
    if [ -f "temp_${TEST_PLAN}" ]; then
        rm -f "temp_${TEST_PLAN}"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--test-plan)
            TEST_PLAN="$2"
            shift 2
            ;;
        -u|--users)
            USERS="$2"
            shift 2
            ;;
        -r|--ramp-up)
            RAMP_UP="$2"
            shift 2
            ;;
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -o|--output)
            REPORT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_header
    
    # Validate mode
    if [ "$MODE" != "gui" ] && [ "$MODE" != "cli" ]; then
        print_error "Invalid mode: $MODE. Use 'gui' or 'cli'"
        exit 1
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Update test plan if needed
    if [ "$MODE" = "cli" ]; then
        update_test_plan
    fi
    
    # Run the test
    run_test
    
    # Cleanup
    cleanup
    
    print_status "Load test completed successfully!"
}

# Trap cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"