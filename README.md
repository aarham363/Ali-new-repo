# JMeter Load Test Plan for dev.melpot.de

This JMeter test plan is designed to perform load testing on the dev.melpot.de application with proper login authentication and API testing.

## Files Included

1. **`melpot_load_test_fixed.jmx`** - The main JMeter test plan with actual values (not variables)
2. **`credentials.properties`** - Configuration file for your credentials
3. **`update_credentials.sh`** - Script to update the test plan with your credentials
4. **`run_load_test.sh`** - Helper script to run the tests easily
5. **`README.md`** - This documentation file

## Features

- **Fixed Values**: All server details are hardcoded (no more variable issues)
- **Proper Login Flow**: Uses POST method for login with CSRF token extraction
- **API Testing**: Includes API requests with your API key and location data
- **Realistic Headers**: Includes proper browser headers for authentic requests
- **CSRF Token Handling**: Automatically extracts and uses CSRF tokens from login page
- **Response Validation**: Checks for successful login indicators
- **Comprehensive Reporting**: Includes multiple result collectors for detailed analysis

## Quick Start

### 1. Update Your Credentials

Edit the `credentials.properties` file with your actual credentials:

```properties
# Login Credentials
username=your_actual_username_here
password=your_actual_password_here

# API Key
api_key=your_actual_api_key_here

# Location Data (Berlin, Germany - you can change these)
latitude=52.5200
longitude=13.4050
```

### 2. Update the JMeter Test Plan

Run the credentials updater script:

```bash
./update_credentials.sh
```

This will automatically update the JMeter test plan with your actual credentials.

### 3. Run the Test

```bash
# Using the helper script (recommended)
./run_load_test.sh

# Or manually
jmeter -n -t melpot_load_test_fixed.jmx -l results.jtl -e -o report_folder
```

## Test Configuration

### Current Settings
- **Target Domain**: dev.melpot.de (hardcoded)
- **Protocol**: HTTPS (hardcoded)
- **Port**: 443 (hardcoded)
- **Threads**: 20 concurrent users
- **Ramp-up**: 30 seconds
- **Loops**: 5 iterations per user
- **Think Time**: 2 seconds between requests

### Test Flow
1. **Get Login Page**: Retrieves the login page to extract CSRF token
2. **Login Request**: Performs POST login with credentials and CSRF token
3. **Dashboard Access**: Accesses the dashboard after successful login
4. **API Request with Location**: Makes API calls with your location data
5. **API Request with Auth Header**: Makes API calls with Authorization header

## What's Fixed

### Previous Issues Resolved:
1. **Variable Resolution**: No more `${server_host}`, `${protocol}`, etc. showing as literal text
2. **Domain Consistency**: Correctly targets `dev.melpot.de`
3. **Proper Authentication**: Uses POST login with CSRF token handling
4. **API Integration**: Includes your API key and location data
5. **Realistic Headers**: Includes proper browser headers

### Current Configuration:
- **Server Name**: dev.melpot.de (hardcoded)
- **Protocol**: https (hardcoded)
- **Port**: 443 (hardcoded)
- **Path**: /login, /dashboard, /api/data, /api/v1/data

## Setup Instructions

### 1. Install JMeter
```bash
# Download JMeter from https://jmeter.apache.org/download_jmeter.cgi
# Or use package manager
sudo apt-get install jmeter  # Ubuntu/Debian
```

### 2. Update Credentials
1. Edit `credentials.properties` with your actual credentials
2. Run `./update_credentials.sh` to update the JMeter test plan
3. The script will create a backup of the original file

### 3. Verify Configuration
Open `melpot_load_test_fixed.jmx` in JMeter GUI to verify:
- Server Name shows: `dev.melpot.de`
- Protocol shows: `https`
- Port shows: `443`
- All credentials are properly set

## Running the Test

### GUI Mode (Recommended for development)
```bash
jmeter -t melpot_load_test_fixed.jmx
```

### Command Line Mode (Recommended for production)
```bash
jmeter -n -t melpot_load_test_fixed.jmx -l results.jtl -e -o report_folder
```

### Using Helper Script
```bash
# Run with default settings
./run_load_test.sh

# Run with custom parameters
./run_load_test.sh -t 50 -r 60 -l 10

# Run in GUI mode
./run_load_test.sh -g
```

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
   - Check if credentials are correct in `credentials.properties`
   - Verify the login endpoint path (`/login`)
   - Ensure CSRF token extraction is working

2. **Connection Issues**
   - Verify the domain is accessible: `https://dev.melpot.de`
   - Check if HTTPS certificates are valid
   - Ensure firewall allows connections

3. **API Issues**
   - Verify your API key is correct
   - Check if the API endpoints exist (`/api/data`, `/api/v1/data`)
   - Ensure location data is in correct format

### Debug Mode
To debug issues, enable response data in result collectors:
1. Right-click on **View Results Tree**
2. Select **Configure**
3. Check **Response Data** in the configuration

## Security Notes

- Never commit `credentials.properties` to version control
- The `update_credentials.sh` script creates backups automatically
- Consider using environment variables for production environments
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
5. Check that credentials were properly updated using `./update_credentials.sh`