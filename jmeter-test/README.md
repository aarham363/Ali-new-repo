# Melpot API Load Test with JMeter

This directory contains a comprehensive JMeter load testing suite for the Melpot API, based on the original Python LoadTester script.

## 🚀 Quick Start

### Prerequisites
- Java 17+ (already installed)
- JMeter 5.6.3 (already installed at `/workspace/jmeter`)
- Access to Melpot API with valid credentials

### Run a Quick Test (Recommended First)
```bash
# Quick validation test (2 users, 30 seconds)
./run_load_test.sh -t 2 -r 10 -d 30
```

### Run Full Load Test
```bash
# Default test (10 users, 5 minutes)
./run_load_test.sh

# Custom parameters
./run_load_test.sh -t 20 -r 120 -d 600
```

## 📁 Directory Structure

```
jmeter-test/
├── melpot_api_test.jmx          # Main JMeter test plan
├── run_load_test.sh             # Execution script
├── config/
│   ├── melpot_test.properties   # Full test configuration
│   └── quick_test.properties    # Quick test configuration
├── results/                     # Test results (timestamped)
├── reports/                     # HTML reports (timestamped)
└── logs/                        # Log files
```

## 🔧 Configuration

### Test Parameters
Edit `config/melpot_test.properties` or use command line options:

- **threads**: Number of concurrent users (default: 10)
- **rampup**: Time to start all users in seconds (default: 60)
- **duration**: Test duration in seconds (default: 300)
- **domain**: API base URL
- **api_key**: API authentication key
- **username/password**: User credentials

### Command Line Options
```bash
./run_load_test.sh [OPTIONS]

Options:
  -t, --threads NUM     Number of threads (default: 10)
  -r, --rampup SEC      Ramp-up time in seconds (default: 60)
  -d, --duration SEC    Test duration in seconds (default: 300)
  -u, --username USER   Username for authentication
  -p, --password PASS   Password for authentication
  --domain URL          API domain URL
  --api-key KEY         API key for authentication
  -h, --help            Show help message
```

## 🎯 Test Design

### Authentication Flow
1. **Setup Thread Group**: Performs login once and shares token globally
2. **Extract Tokens**: Captures access_token and user_id from login response
3. **Global Properties**: Makes authentication available to all test threads

### API Operations (Weighted Distribution)
- **Feed Operations (40%)**: Home feeds, profile feeds, post lists
- **Post Operations (30%)**: Post details, views, resources
- **Interaction Operations (20%)**: Comments, likes, viewing
- **Create Operations (10%)**: Adding comments and posts

### Performance Thresholds
- **Response Time**: < 2000ms assertion
- **Error Rate**: Monitored and reported
- **Throughput**: Configurable target RPS

## 📊 Test Endpoints

Based on the original LoadTester, the following endpoints are tested:

### Authentication
- `POST /auth/login/` - User authentication with device simulation

### Feed Endpoints
- `POST /api/v2/feed/home_post_list` - Home feed with pagination
- `POST /api/v2/feed/home_post_v2` - Enhanced home feed
- `POST /api/v2/feed/profile_post_list` - User profile posts

### Post Endpoints  
- `POST /api/v2/post/details` - Individual post details
- `POST /api/v2/post/add_view` - Track post views
- `POST /api/v2/post/add` - Create new posts

### Interaction Endpoints
- `POST /api/v2/comment/list` - Get post comments
- `POST /api/v2/comment/add` - Add comments
- `POST /api/v2/like/add` - Like posts

## 📈 Results and Reporting

### Generated Artifacts
1. **HTML Report**: `reports/{timestamp}/index.html` - Comprehensive dashboard
2. **Results File**: `results/{timestamp}/results.jtl` - Raw test data
3. **Summary**: `results/{timestamp}/test_summary.txt` - Key metrics
4. **CSV Export**: `results/{timestamp}/performance_summary.csv` - Spreadsheet data
5. **Logs**: `results/{timestamp}/jmeter.log` - Detailed execution logs

### Key Metrics
- **Total Requests**: Count of all API calls
- **Success Rate**: Percentage of successful responses
- **Response Times**: Average, Min, Max, 95th/99th percentiles
- **Throughput**: Requests per second achieved
- **Error Analysis**: Failed request details

## 🔒 Security Features

### Credential Protection
- Passwords masked in logs and reports
- API keys redacted from output files
- Access tokens sanitized post-execution

### Data Simulation
- Random device information (iPhone, Samsung, etc.)
- Randomized locations and device IDs
- Varied post content and timestamps

## 🛠 Advanced Usage

### Custom JMeter Properties
```bash
# Override JMeter heap settings
export HEAP="-Xms2g -Xmx4g"

# Run with custom JMeter properties
./run_load_test.sh --threads 50 --duration 900
```

### Environment-Specific Testing
```bash
# Test against different environments
./run_load_test.sh --domain https://staging.melpotapp.de
./run_load_test.sh --domain https://prod.melpotapp.de
```

### Debugging
```bash
# Enable detailed logging
JVM_ARGS="-Dlog4j2.level=DEBUG" ./run_load_test.sh -t 1 -d 60
```

## 📋 Performance Benchmarks

### Baseline Expectations
- **Response Time**: 95% < 2000ms
- **Error Rate**: < 1%
- **Throughput**: Target varies by endpoint
- **Concurrent Users**: Test with 10-50 users typical

### Scaling Guidelines
- **Light Load**: 1-10 users, 60-300 seconds
- **Medium Load**: 10-50 users, 300-900 seconds  
- **Heavy Load**: 50+ users, 900+ seconds

## 🚨 Troubleshooting

### Common Issues
1. **Login Failures**: Verify credentials in config file
2. **SSL Errors**: Check domain accessibility
3. **Memory Issues**: Increase heap size for large tests
4. **Token Errors**: Ensure authentication succeeds before API calls

### Log Analysis
```bash
# Check for errors
grep -i "error\|exception" results/{timestamp}/jmeter.log

# View authentication details
grep -i "login\|token" results/{timestamp}/jmeter.log

# Monitor response codes
grep "responseCode" results/{timestamp}/results.jtl | sort | uniq -c
```

## 🔄 Integration

### CI/CD Pipeline
The script supports automation and can be integrated into build pipelines:

```bash
# Exit codes: 0 = success, 1 = configuration error, >1 = test failure
./run_load_test.sh -t 5 -d 120 || echo "Load test failed"
```

### Monitoring Integration
Results can be parsed and sent to monitoring systems:
- Parse CSV files for metrics extraction
- Alert on error rates exceeding thresholds
- Track performance trends over time

## 📞 Support

For issues with the load test setup:
1. Check the generated logs in `results/{timestamp}/`
2. Verify API accessibility and credentials
3. Review JMeter installation and Java version
4. Consult the test summary for specific error details

---

**Note**: This load test is designed to replicate the behavior of the original Python LoadTester script while providing enhanced reporting and configuration flexibility through JMeter.