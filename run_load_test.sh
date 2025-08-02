#!/bin/bash

# JMeter Load Test Runner Script
# This script helps you run the load test for dev.melpot.de

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_PLAN="load_test_plan.jmx"
RESULTS_FILE="load_test_results.jtl"
REPORT_DIR="load_test_report"
LOG_FILE="jmeter.log"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  JMeter Load Test Runner${NC}"
echo -e "${BLUE}================================${NC}"

# Check if JMeter is installed
if ! command -v jmeter &> /dev/null; then
    echo -e "${RED}Error: JMeter is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install JMeter first:${NC}"
    echo "  - Download from: https://jmeter.apache.org/download_jmeter.cgi"
    echo "  - Or install via package manager: sudo apt-get install jmeter"
    exit 1
fi

# Check if test plan exists
if [ ! -f "$TEST_PLAN" ]; then
    echo -e "${RED}Error: Test plan file '$TEST_PLAN' not found${NC}"
    exit 1
fi

# Function to show usage
show_usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 [OPTIONS]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -g, --gui          Run in GUI mode (for development/debugging)"
    echo "  -c, --cli          Run in command line mode (default)"
    echo "  -t, --threads N    Number of threads (default: 20)"
    echo "  -r, --ramp N       Ramp-up time in seconds (default: 30)"
    echo "  -l, --loops N      Number of loops (default: 5)"
    echo "  -h, --help         Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0                    # Run with default settings"
    echo "  $0 -g                 # Run in GUI mode"
    echo "  $0 -t 50 -r 60        # 50 threads, 60s ramp-up"
    echo "  $0 -t 100 -l 10       # 100 threads, 10 loops"
}

# Parse command line arguments
GUI_MODE=false
THREADS=""
RAMP_TIME=""
LOOPS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--gui)
            GUI_MODE=true
            shift
            ;;
        -c|--cli)
            GUI_MODE=false
            shift
            ;;
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -r|--ramp)
            RAMP_TIME="$2"
            shift 2
            ;;
        -l|--loops)
            LOOPS="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Update test plan with custom parameters if provided
if [ ! -z "$THREADS" ] || [ ! -z "$RAMP_TIME" ] || [ ! -z "$LOOPS" ]; then
    echo -e "${YELLOW}Updating test plan with custom parameters...${NC}"
    
    # Create a temporary copy of the test plan
    TEMP_PLAN="temp_${TEST_PLAN}"
    cp "$TEST_PLAN" "$TEMP_PLAN"
    
    # Update parameters using sed
    if [ ! -z "$THREADS" ]; then
        sed -i "s/<intProp name=\"ThreadGroup.num_threads\">[0-9]*<\/intProp>/<intProp name=\"ThreadGroup.num_threads\">$THREADS<\/intProp>/" "$TEMP_PLAN"
        echo -e "  - Threads: $THREADS"
    fi
    
    if [ ! -z "$RAMP_TIME" ]; then
        sed -i "s/<intProp name=\"ThreadGroup.ramp_time\">[0-9]*<\/intProp>/<intProp name=\"ThreadGroup.ramp_time\">$RAMP_TIME<\/intProp>/" "$TEMP_PLAN"
        echo -e "  - Ramp-up: ${RAMP_TIME}s"
    fi
    
    if [ ! -z "$LOOPS" ]; then
        sed -i "s/<stringProp name=\"LoopController.loops\">[0-9]*<\/stringProp>/<stringProp name=\"LoopController.loops\">$LOOPS<\/stringProp>/" "$TEMP_PLAN"
        echo -e "  - Loops: $LOOPS"
    fi
    
    TEST_PLAN="$TEMP_PLAN"
fi

# Show test configuration
echo -e "${GREEN}Test Configuration:${NC}"
echo -e "  - Test Plan: $TEST_PLAN"
echo -e "  - Target: dev.melpot.de"
echo -e "  - Protocol: HTTPS"

# Check if credentials need to be updated
echo -e "${YELLOW}Important:${NC}"
echo -e "  Make sure to update the credentials in the test plan before running!"
echo -e "  Current default credentials: testuser/testpass"
echo ""

# Ask for confirmation
read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Test cancelled.${NC}"
    exit 0
fi

# Create results directory
mkdir -p "$REPORT_DIR"

# Run JMeter
echo -e "${GREEN}Starting JMeter load test...${NC}"
echo -e "  - Results will be saved to: $RESULTS_FILE"
echo -e "  - HTML report will be generated in: $REPORT_DIR"
echo ""

if [ "$GUI_MODE" = true ]; then
    echo -e "${BLUE}Running in GUI mode...${NC}"
    jmeter -t "$TEST_PLAN" -l "$RESULTS_FILE" 2>&1 | tee "$LOG_FILE"
else
    echo -e "${BLUE}Running in command line mode...${NC}"
    jmeter -n -t "$TEST_PLAN" -l "$RESULTS_FILE" -e -o "$REPORT_DIR" 2>&1 | tee "$LOG_FILE"
fi

# Check if test completed successfully
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  Load Test Completed Successfully!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${GREEN}Results:${NC}"
    echo -e "  - Results file: $RESULTS_FILE"
    if [ "$GUI_MODE" = false ]; then
        echo -e "  - HTML report: $REPORT_DIR/index.html"
    fi
    echo -e "  - Log file: $LOG_FILE"
    echo ""
    
    if [ "$GUI_MODE" = false ]; then
        echo -e "${YELLOW}To view the HTML report:${NC}"
        echo -e "  open $REPORT_DIR/index.html"
    fi
    
    echo -e "${YELLOW}To analyze results in JMeter GUI:${NC}"
    echo -e "  jmeter -t $TEST_PLAN"
    echo -e "  Then load the results file: $RESULTS_FILE"
else
    echo ""
    echo -e "${RED}================================${NC}"
    echo -e "${RED}  Load Test Failed!${NC}"
    echo -e "${RED}================================${NC}"
    echo ""
    echo -e "${YELLOW}Check the log file for details: $LOG_FILE${NC}"
    exit 1
fi

# Clean up temporary file
if [ -f "temp_${TEST_PLAN}" ]; then
    rm "temp_${TEST_PLAN}"
fi