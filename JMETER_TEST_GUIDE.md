# JMeter Load Test Guide

## Overview
This guide will help you run a comprehensive load test on your server using Apache JMeter. The test plan includes authentication token handling and multiple request scenarios.

## Prerequisites

### 1. Install Apache JMeter
```bash
# Download JMeter from: https://jmeter.apache.org/download_jmeter.cgi
# Or install via package manager:

# Ubuntu/Debian
sudo apt-get install jmeter

# CentOS/RHEL
sudo yum install jmeter

# macOS (using Homebrew)
brew install jmeter
```

### 2. Verify Installation
```bash
jmeter --version
```

## Test Plan Structure

The `load_test_plan.jmx` file contains:

1. **Test Plan Configuration**
   - User Defined Variables for server settings
   - Configurable parameters for easy customization

2. **Thread Group**
   - 50 concurrent users
   - 30-second ramp-up time
   - 10 iterations per user

3. **HTTP Requests**
   - Login Request (POST to /api/login)
   - Home Page Request (GET to /)
   - API Request with Token (GET to /api/data)

4. **Token Extraction**
   - JSON Post Processor to extract authentication token
   - Automatic token usage in subsequent requests

5. **Results Collection**
   - View Results Tree
   - Summary Report
   - Aggregate Report

## Step-by-Step Instructions

### Step 1: Start Your Server
Make sure your application server is running and accessible at the configured host and port.

### Step 2: Configure Test Parameters
1. Open JMeter GUI:
   ```bash
   jmeter
   ```

2. Load the test plan:
   - File → Open → Select `load_test_plan.jmx`

3. Modify User Defined Variables (if needed):
   - Right-click on "Test Plan" → Add → Config Element → User Defined Variables
   - Update these values:
     - `server_host`: Your server hostname (default: localhost)
     - `server_port`: Your server port (default: 8080)
     - `protocol`: http or https (default: http)
     - `username`: Test username (default: testuser)
     - `password`: Test password (default: testpass)

### Step 3: Adjust Load Test Parameters
1. Select "Load Test Thread Group"
2. Modify these settings based on your requirements:
   - **Number of Threads (users)**: 50 (adjust based on your server capacity)
   - **Ramp-up period (seconds)**: 30 (time to start all threads)
   - **Loop Count**: 10 (iterations per user)

### Step 4: Configure Authentication Endpoints
1. **Login Request**: Update the path if your login endpoint is different
   - Current: `/api/login`
   - Method: POST
   - Parameters: username, password

2. **API Request**: Update the path for your protected endpoints
   - Current: `/api/data`
   - Method: GET
   - Headers: Authorization: Bearer ${auth_token}

### Step 5: Run the Test

#### Option A: GUI Mode (for development/testing)
1. Click the green "Start" button in JMeter
2. Monitor results in real-time using the listeners
3. Stop the test when complete

#### Option B: Command Line Mode (recommended for production)
```bash
# Basic command
jmeter -n -t load_test_plan.jmx -l results.jtl

# With additional options
jmeter -n -t load_test_plan.jmx -l results.jtl -e -o report_folder

# Parameters explained:
# -n: Non-GUI mode
# -t: Test plan file
# -l: Results file
# -e: Generate HTML report
# -o: Output directory for HTML report
```

### Step 6: Analyze Results

#### Real-time Monitoring (GUI Mode)
1. **View Results Tree**: Shows detailed request/response data
2. **Summary Report**: Provides summary statistics
3. **Aggregate Report**: Shows aggregated performance metrics

#### Post-Test Analysis
1. **HTML Report**: If generated, open `report_folder/index.html`
2. **Results File**: Analyze `results.jtl` using JMeter or external tools

## Key Metrics to Monitor

### Performance Metrics
- **Response Time**: Average, median, 90th percentile
- **Throughput**: Requests per second
- **Error Rate**: Percentage of failed requests
- **Active Threads**: Number of concurrent users

### System Metrics
- **CPU Usage**: Server CPU utilization
- **Memory Usage**: Server memory consumption
- **Network I/O**: Network throughput
- **Database Connections**: If applicable

## Customization Options

### 1. Modify Load Pattern
```xml
<!-- In Thread Group -->
<stringProp name="ThreadGroup.num_threads">100</stringProp>  <!-- Increase users -->
<stringProp name="ThreadGroup.ramp_time">60</stringProp>     <!-- Slower ramp-up -->
```

### 2. Add Think Time
```xml
<!-- Constant Timer -->
<stringProp name="ConstantTimer.delay">2000</stringProp>  <!-- 2 seconds between requests -->
```

### 3. Add Assertions
- Response Assertion: Verify response content
- Duration Assertion: Check response time
- Size Assertion: Validate response size

### 4. Add Data Sources
- CSV Data Set Config: Use external test data
- Random Variable: Generate dynamic values
- User Parameters: Parameterize requests

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Verify server is running
   - Check host/port configuration
   - Ensure firewall allows connections

2. **Authentication Failures**
   - Verify username/password
   - Check login endpoint path
   - Ensure token extraction is working

3. **High Error Rates**
   - Reduce number of concurrent users
   - Increase ramp-up time
   - Check server logs for errors

4. **Memory Issues**
   - Increase JMeter heap size: `jmeter -Xmx2g`
   - Reduce number of threads
   - Use non-GUI mode for large tests

### Debug Mode
```bash
# Enable debug logging
jmeter -n -t load_test_plan.jmx -l results.jtl -L DEBUG
```

## Best Practices

1. **Start Small**: Begin with few users and gradually increase
2. **Monitor Resources**: Watch server CPU, memory, and network usage
3. **Use Non-GUI Mode**: For production load tests
4. **Save Results**: Always save test results for analysis
5. **Clean Environment**: Ensure no other load on the system
6. **Warm-up**: Allow server to warm up before starting tests
7. **Baseline**: Establish performance baselines before changes

## Sample Test Scenarios

### Light Load Test
- Users: 10
- Ramp-up: 10 seconds
- Duration: 5 minutes

### Medium Load Test
- Users: 50
- Ramp-up: 30 seconds
- Duration: 10 minutes

### Heavy Load Test
- Users: 100
- Ramp-up: 60 seconds
- Duration: 15 minutes

### Stress Test
- Users: 200+
- Ramp-up: 120 seconds
- Duration: 30 minutes

## Next Steps

1. Run the basic test to establish baseline
2. Modify parameters based on your application
3. Add more realistic test scenarios
4. Implement continuous performance testing
5. Set up monitoring and alerting

## Support

For issues or questions:
1. Check JMeter documentation: https://jmeter.apache.org/
2. Review server logs for errors
3. Verify network connectivity
4. Test with smaller user loads first