# Quick Start Guide - JMeter Load Test

## 🚀 Get Started in 5 Minutes

### Step 1: Install JMeter
```bash
# Ubuntu/Debian
sudo apt-get install jmeter

# CentOS/RHEL
sudo yum install jmeter

# macOS
brew install jmeter

# Or download from: https://jmeter.apache.org/download_jmeter.cgi
```

### Step 2: Start Your Server
Make sure your application server is running on `localhost:8080`

### Step 3: Run the Load Test

#### Option A: Using the Script (Recommended)
```bash
# Make script executable (if not already)
chmod +x run_jmeter_test.sh

# Run with default settings (50 users, 30s ramp-up)
./run_jmeter_test.sh

# Run a light load test (10 users, 10s ramp-up, 1 minute)
./run_jmeter_test.sh -u 10 -r 10 -d 60

# Run a heavy load test (100 users, 60s ramp-up, 10 minutes)
./run_jmeter_test.sh -u 100 -r 60 -d 600

# Run in GUI mode for development
./run_jmeter_test.sh -m gui
```

#### Option B: Direct JMeter Command
```bash
# Basic test
jmeter -n -t load_test_plan.jmx -l results.jtl

# With HTML report
jmeter -n -t load_test_plan.jmx -l results.jtl -e -o jmeter_report
```

### Step 4: View Results
- **HTML Report**: Open `jmeter_report/index.html` in your browser
- **Results File**: Check `results.jtl` for detailed data
- **Console Output**: View real-time statistics during test execution

## 📊 What the Test Does

1. **Login Request**: Authenticates with username/password
2. **Token Extraction**: Extracts authentication token from response
3. **Home Page**: Requests the main page
4. **API Request**: Makes authenticated API calls using the token
5. **Think Time**: Waits 1 second between requests
6. **Repeat**: Runs this sequence for each user

## ⚙️ Customization

### Update Server Settings
Edit `jmeter_config.properties`:
```properties
server.host=your-server.com
server.port=8080
auth.username=your-username
auth.password=your-password
```

### Update Load Parameters
```bash
# 25 users, 15s ramp-up, 5 minutes duration
./run_jmeter_test.sh -u 25 -r 15 -d 300
```

### Update API Endpoints
Edit the JMX file or modify the configuration file to match your API endpoints.

## 🔍 Understanding Results

### Key Metrics
- **Response Time**: How fast your server responds
- **Throughput**: Requests per second
- **Error Rate**: Percentage of failed requests
- **Active Users**: Number of concurrent users

### Performance Thresholds
- **Good**: Response time < 1 second, Error rate < 5%
- **Acceptable**: Response time < 2 seconds, Error rate < 10%
- **Poor**: Response time > 2 seconds, Error rate > 10%

## 🛠️ Troubleshooting

### Common Issues
1. **Connection Refused**: Server not running or wrong port
2. **Authentication Failed**: Wrong username/password or endpoint
3. **High Error Rate**: Reduce number of users or check server logs

### Debug Mode
```bash
# Enable debug logging
jmeter -n -t load_test_plan.jmx -l results.jtl -L DEBUG
```

## 📁 Files Created
- `load_test_plan.jmx` - JMeter test plan
- `run_jmeter_test.sh` - Easy-to-use runner script
- `jmeter_config.properties` - Configuration file
- `JMETER_TEST_GUIDE.md` - Detailed documentation
- `results.jtl` - Test results (after running)
- `jmeter_report/` - HTML report directory (after running)

## 🎯 Next Steps
1. Run a baseline test to understand current performance
2. Modify endpoints to match your application
3. Adjust load parameters based on your requirements
4. Set up continuous performance monitoring
5. Create different test scenarios for various use cases

## 📞 Need Help?
- Check the detailed guide: `JMETER_TEST_GUIDE.md`
- Review JMeter documentation: https://jmeter.apache.org/
- Check server logs for errors
- Start with smaller user loads and gradually increase