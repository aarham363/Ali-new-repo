#!/bin/bash

# Script to update JMeter test plan with actual credentials
# This script reads credentials from credentials.properties and updates the JMeter test plan

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  JMeter Credentials Updater${NC}"
echo -e "${BLUE}================================${NC}"

# Check if credentials file exists
if [ ! -f "credentials.properties" ]; then
    echo -e "${RED}Error: credentials.properties file not found${NC}"
    echo -e "${YELLOW}Please create credentials.properties with your actual credentials${NC}"
    exit 1
fi

# Check if JMeter test plan exists
if [ ! -f "melpot_load_test_fixed.jmx" ]; then
    echo -e "${RED}Error: melpot_load_test_fixed.jmx file not found${NC}"
    exit 1
fi

# Function to read property from file
get_property() {
    local file="$1"
    local key="$2"
    grep "^${key}=" "$file" | cut -d'=' -f2-
}

# Read credentials from properties file
echo -e "${YELLOW}Reading credentials from credentials.properties...${NC}"

USERNAME=$(get_property "credentials.properties" "username")
PASSWORD=$(get_property "credentials.properties" "password")
API_KEY=$(get_property "credentials.properties" "api_key")
LATITUDE=$(get_property "credentials.properties" "latitude")
LONGITUDE=$(get_property "credentials.properties" "longitude")

# Check if credentials are still default values
if [[ "$USERNAME" == "your_actual_username_here" ]] || [[ "$PASSWORD" == "your_actual_password_here" ]] || [[ "$API_KEY" == "your_actual_api_key_here" ]]; then
    echo -e "${RED}Error: Please update credentials.properties with your actual credentials${NC}"
    echo -e "${YELLOW}Current values are still default placeholders${NC}"
    exit 1
fi

echo -e "${GREEN}Credentials loaded successfully!${NC}"
echo -e "  - Username: $USERNAME"
echo -e "  - Password: [HIDDEN]"
echo -e "  - API Key: [HIDDEN]"
echo -e "  - Latitude: $LATITUDE"
echo -e "  - Longitude: $LONGITUDE"

# Create backup of original file
BACKUP_FILE="melpot_load_test_fixed.jmx.backup.$(date +%Y%m%d_%H%M%S)"
cp "melpot_load_test_fixed.jmx" "$BACKUP_FILE"
echo -e "${YELLOW}Backup created: $BACKUP_FILE${NC}"

# Update the JMeter test plan with actual credentials
echo -e "${YELLOW}Updating JMeter test plan with actual credentials...${NC}"

# Update username
sed -i "s/<stringProp name=\"Argument.value\">your_actual_username_here<\/stringProp>/<stringProp name=\"Argument.value\">$USERNAME<\/stringProp>/" "melpot_load_test_fixed.jmx"

# Update password
sed -i "s/<stringProp name=\"Argument.value\">your_actual_password_here<\/stringProp>/<stringProp name=\"Argument.value\">$PASSWORD<\/stringProp>/" "melpot_load_test_fixed.jmx"

# Update API key
sed -i "s/<stringProp name=\"Argument.value\">your_actual_api_key_here<\/stringProp>/<stringProp name=\"Argument.value\">$API_KEY<\/stringProp>/" "melpot_load_test_fixed.jmx"

# Update latitude
sed -i "s/<stringProp name=\"Argument.value\">52.5200<\/stringProp>/<stringProp name=\"Argument.value\">$LATITUDE<\/stringProp>/" "melpot_load_test_fixed.jmx"

# Update longitude
sed -i "s/<stringProp name=\"Argument.value\">13.4050<\/stringProp>/<stringProp name=\"Argument.value\">$LONGITUDE<\/stringProp>/" "melpot_load_test_fixed.jmx"

echo -e "${GREEN}JMeter test plan updated successfully!${NC}"
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Next Steps:${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}1. Open JMeter GUI:${NC}"
echo -e "   jmeter -t melpot_load_test_fixed.jmx"
echo ""
echo -e "${YELLOW}2. Or run the load test directly:${NC}"
echo -e "   jmeter -n -t melpot_load_test_fixed.jmx -l results.jtl -e -o report_folder"
echo ""
echo -e "${YELLOW}3. Or use the helper script:${NC}"
echo -e "   ./run_load_test.sh"
echo ""
echo -e "${BLUE}The test plan now contains your actual credentials and is ready to run!${NC}"