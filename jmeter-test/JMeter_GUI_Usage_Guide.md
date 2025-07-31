# JMeter GUI Test Plan Usage Guide

## File: Melpot_API_GUI_Test_Plan.jmx

This JMeter test plan is designed for interactive GUI usage with comprehensive monitoring and real-time visualization.

## Quick Start

### Step 1: Download the Test Plan
Save the `Melpot_API_GUI_Test_Plan.jmx` file to your local machine.

### Step 2: Open JMeter GUI
Start JMeter GUI application

### Step 3: Load the Test Plan
1. Open JMeter GUI
2. Go to File → Open
3. Select `Melpot_API_GUI_Test_Plan.jmx`

## Configuration

### User Defined Variables
Located at: Test Plan → User Defined Variables

| Variable | Default Value | Description |
|----------|---------------|-------------|
| BASE_URL | https://dev.melpotapp.de | API base URL |
| API_KEY | dr2ROX4B... | Your API authentication key |
| USERNAME | odin | Login username |
| PASSWORD | 1234 | Login password |
| THREAD_COUNT | 5 | Number of virtual users |
| RAMP_UP_TIME | 30 | Time to start all users (seconds) |
| TEST_DURATION | 120 | Total test duration (seconds) |

## How to Run the Test

1. Configure Variables (if needed)
2. Start Test: Click the green Start button
3. Monitor: Watch real-time results in listeners
4. Stop Test: Click the red Stop button when done

## Monitoring Components

### 1. View Results Tree
- Purpose: Detailed request/response inspection
- Use For: Debugging failed requests, viewing API responses

### 2. Summary Report
- Shows: High-level performance metrics
- Metrics: Average response time, throughput, error percentage

### 3. Aggregate Report
- Shows: Detailed statistics per request type
- Metrics: 90th, 95th, 99th percentile response times

### 4. Graph Results
- Shows: Real-time response time visualization

### 5. Response Time Graph
- Shows: Response time over time

## Test Scenarios

### Quick Health Check (30 seconds)
```
THREAD_COUNT = 2
RAMP_UP_TIME = 5
TEST_DURATION = 30
```

### Standard Load Test (5 minutes)
```
THREAD_COUNT = 10
RAMP_UP_TIME = 60
TEST_DURATION = 300
```

## Success Indicators

Your test is successful when:
- All authentication requests pass (green in View Results Tree)
- Error rate is below 1%
- Average response time is under 2 seconds
- Throughput meets your expectations

This test plan replicates your Python LoadTester functionality with enhanced GUI monitoring!
