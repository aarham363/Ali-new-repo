# JMeter Load Test Plan for dev.melpot.de

This JMeter test plan is designed to perform load testing on the dev.melpot.de application with proper login authentication.

## Features

- **Proper Login Flow**: Uses POST method for login with CSRF token extraction
- **Realistic Headers**: Includes proper browser headers for authentic requests
- **CSRF Token Handling**: Automatically extracts and uses CSRF tokens from login page
- **Response Validation**: Checks for successful login indicators
- **Comprehensive Reporting**: Includes multiple result collectors for detailed analysis

## Test Configuration

### Current Settings
- **Target Domain**: dev.melpot.de
- **Protocol**: HTTPS (port 443)
- **Threads**: 20 concurrent users
- **Ramp-up**: 30 seconds
- **Loops**: 5 iterations per user
- **Think Time**: 2 seconds between requests

### Test Flow
1. **Get Login Page**: Retrieves the login page to extract CSRF token
2. **Login Request**: Performs POST login with credentials and CSRF token
3. **Dashboard Access**: Accesses the dashboard after successful login
4. **API Request**: Makes API calls (if endpoints exist)

## Setup Instructions

### 1. Install JMeter
```bash
# Download JMeter from https://jmeter.apache.org/download_jmeter.cgi
# Or use package manager
sudo apt-get install jmeter  # Ubuntu/Debian
```

### 2. Update Credentials
Before running the test, update the credentials in the test plan:

1. Open `load_test_plan.jmx` in JMeter GUI
2. Navigate to **Test Plan** → **User Defined Variables**
3. Update the following variables:
   - `username`: Your actual username/email
   - `password`: Your actual password

### 3. Adjust Test Parameters (Optional)
You can modify the load test parameters in the **Thread Group**:
- **Number of Threads**: Increase for higher load
- **Ramp-up Period**: Time to start all threads
- **Loop Count**: Number of iterations per thread

## Running the Test

### GUI Mode (Recommended for development)
```bash
jmeter -t load_test_plan.jmx
```

### Command Line Mode (Recommended for production)
```bash
jmeter -n -t load_test_plan.jmx -l results.jtl -e -o report_folder
```

### Parameters Explained
- `-n`: Non-GUI mode
- `-t`: Test plan file
- `-l`: Results file
- `-e`: Generate HTML report
- `-o`: Output directory for HTML report

## Understanding Results

### View Results Tree
- Shows detailed request/response data
- Useful for debugging individual requests
- Can be disabled in production for better performance

### Summary Report
- Provides overview of all requests
- Shows average, median, 90th percentile response times
- Displays error rates and throughput

### Aggregate Report
- Detailed statistics per request type
- Response time distribution
- Throughput analysis

## Troubleshooting

### Common Issues

1. **Login Failures**
   - Check if credentials are correct
   - Verify the login endpoint path (`/login`)
   - Ensure CSRF token extraction is working

2. **Connection Issues**
   - Verify the domain is accessible
   - Check if HTTPS certificates are valid
   - Ensure firewall allows connections

3. **Performance Issues**
   - Reduce number of threads if system is overwhelmed
   - Increase think time between requests
   - Monitor system resources during test

### Debug Mode
To debug issues, enable response data in result collectors:
1. Right-click on **View Results Tree**
2. Select **Configure**
3. Check **Response Data** in the configuration

## Customization

### Adding New Requests
1. Right-click on **Thread Group**
2. Add → Sampler → HTTP Request
3. Configure the request parameters
4. Add any necessary extractors or assertions

### Modifying Headers
1. Select **HTTP Header Manager**
2. Add or modify headers as needed
3. Common additions: Authorization, Content-Type, etc.

### Adding Assertions
1. Right-click on any HTTP Request
2. Add → Assertions → Response Assertion
3. Configure the assertion criteria

## Security Notes

- Never commit real credentials to version control
- Use environment variables or external property files for sensitive data
- Consider using JMeter's built-in credential management features
- Test against staging environments when possible

## Performance Tips

- Start with a small number of threads and gradually increase
- Monitor system resources (CPU, memory, network)
- Use non-GUI mode for production testing
- Consider distributed testing for high load scenarios
- Use CSV data sets for multiple user credentials

## Support

For issues with the test plan:
1. Check JMeter logs for error messages
2. Verify network connectivity to target server
3. Test manually in browser first
4. Review response data in View Results Tree