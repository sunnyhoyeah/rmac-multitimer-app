#!/bin/bash

# Environment Setup Script for App Store Connect Deployment
# This script helps you configure the necessary environment variables

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 RMAC MultiTimer - App Store Connect Environment Setup${NC}"
echo ""

# Function to prompt for input
prompt_input() {
    local prompt="$1"
    local var_name="$2"
    local is_secret="${3:-false}"
    
    echo -n -e "${YELLOW}$prompt: ${NC}"
    if [ "$is_secret" = "true" ]; then
        read -s input
        echo ""
    else
        read input
    fi
    
    if [ -z "$input" ]; then
        echo -e "${RED}❌ This field is required${NC}"
        exit 1
    fi
    
    export $var_name="$input"
}

# Check if environment variables are already set
check_existing_env() {
    echo -e "${BLUE}📋 Checking existing environment variables...${NC}"
    
    VARS_SET=0
    TOTAL_VARS=5
    
    if [ ! -z "$FASTLANE_USER" ]; then
        echo -e "${GREEN}✅ FASTLANE_USER is set${NC}"
        ((VARS_SET++))
    else
        echo -e "${YELLOW}⚠️  FASTLANE_USER not set${NC}"
    fi
    
    if [ ! -z "$FASTLANE_PASSWORD" ]; then
        echo -e "${GREEN}✅ FASTLANE_PASSWORD is set${NC}"
        ((VARS_SET++))
    else
        echo -e "${YELLOW}⚠️  FASTLANE_PASSWORD not set${NC}"
    fi
    
    if [ ! -z "$APP_STORE_CONNECT_API_KEY_ID" ]; then
        echo -e "${GREEN}✅ APP_STORE_CONNECT_API_KEY_ID is set${NC}"
        ((VARS_SET++))
    else
        echo -e "${YELLOW}⚠️  APP_STORE_CONNECT_API_KEY_ID not set${NC}"
    fi
    
    if [ ! -z "$APP_STORE_CONNECT_ISSUER_ID" ]; then
        echo -e "${GREEN}✅ APP_STORE_CONNECT_ISSUER_ID is set${NC}"
        ((VARS_SET++))
    else
        echo -e "${YELLOW}⚠️  APP_STORE_CONNECT_ISSUER_ID not set${NC}"
    fi
    
    if [ ! -z "$APP_STORE_CONNECT_API_KEY" ]; then
        echo -e "${GREEN}✅ APP_STORE_CONNECT_API_KEY is set${NC}"
        ((VARS_SET++))
    else
        echo -e "${YELLOW}⚠️  APP_STORE_CONNECT_API_KEY not set${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}📊 Environment status: $VARS_SET/$TOTAL_VARS variables configured${NC}"
    
    if [ $VARS_SET -eq $TOTAL_VARS ]; then
        echo -e "${GREEN}🎉 All environment variables are configured!${NC}"
        echo -e "${BLUE}You can now run: make deploy-testflight${NC}"
        return 0
    else
        echo -e "${YELLOW}❗ Some environment variables need to be configured${NC}"
        return 1
    fi
}

# Setup instructions
show_setup_instructions() {
    echo -e "${BLUE}📖 App Store Connect Setup Instructions${NC}"
    echo ""
    echo -e "${YELLOW}Step 1: Apple Developer Account${NC}"
    echo -e "• Ensure you have an active Apple Developer account"
    echo -e "• Your account should have App Manager or Admin role"
    echo ""
    echo -e "${YELLOW}Step 2: App Store Connect API Key${NC}"
    echo -e "• Go to: https://appstoreconnect.apple.com/access/api"
    echo -e "• Click '+' to create a new API key"
    echo -e "• Give it 'App Manager' access"
    echo -e "• Download the .p8 file"
    echo -e "• Note the Key ID and Issuer ID"
    echo ""
    echo -e "${YELLOW}Step 3: App-Specific Password${NC}"
    echo -e "• Go to: https://appleid.apple.com/account/manage"
    echo -e "• Sign in with your Apple ID"
    echo -e "• In Security section, generate app-specific password"
    echo -e "• Use this instead of your regular Apple ID password"
    echo ""
}

# Interactive setup
interactive_setup() {
    echo -e "${PURPLE}🔧 Interactive Environment Setup${NC}"
    echo ""
    
    # Apple ID
    if [ -z "$FASTLANE_USER" ]; then
        prompt_input "Enter your Apple ID (email)" "FASTLANE_USER"
    fi
    
    # App-specific password
    if [ -z "$FASTLANE_PASSWORD" ]; then
        echo -e "${YELLOW}💡 Use your app-specific password, not your regular Apple ID password${NC}"
        prompt_input "Enter your app-specific password" "FASTLANE_PASSWORD" true
    fi
    
    # API Key ID
    if [ -z "$APP_STORE_CONNECT_API_KEY_ID" ]; then
        prompt_input "Enter your App Store Connect API Key ID" "APP_STORE_CONNECT_API_KEY_ID"
    fi
    
    # Issuer ID
    if [ -z "$APP_STORE_CONNECT_ISSUER_ID" ]; then
        prompt_input "Enter your App Store Connect Issuer ID" "APP_STORE_CONNECT_ISSUER_ID"
    fi
    
    # API Key file
    if [ -z "$APP_STORE_CONNECT_API_KEY" ]; then
        echo -e "${YELLOW}💡 You need to provide the path to your .p8 API key file${NC}"
        prompt_input "Enter path to your .p8 API key file" "API_KEY_PATH"
        
        if [ ! -f "$API_KEY_PATH" ]; then
            echo -e "${RED}❌ File not found: $API_KEY_PATH${NC}"
            exit 1
        fi
        
        # Convert to base64
        API_KEY_BASE64=$(base64 -i "$API_KEY_PATH")
        export APP_STORE_CONNECT_API_KEY="$API_KEY_BASE64"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Environment variables configured for this session!${NC}"
}

# Generate shell profile configuration
generate_shell_config() {
    echo -e "${BLUE}📝 Generating shell configuration...${NC}"
    
    CONFIG_FILE="$HOME/.appstore_connect_env"
    
    cat > "$CONFIG_FILE" << EOF
# App Store Connect Environment Variables for RMAC MultiTimer
# Source this file in your shell profile or before running deployment commands

export FASTLANE_USER="$FASTLANE_USER"
export FASTLANE_PASSWORD="$FASTLANE_PASSWORD"
export APP_STORE_CONNECT_API_KEY_ID="$APP_STORE_CONNECT_API_KEY_ID"
export APP_STORE_CONNECT_ISSUER_ID="$APP_STORE_CONNECT_ISSUER_ID"
export APP_STORE_CONNECT_API_KEY="$APP_STORE_CONNECT_API_KEY"

# Optional: Slack webhook for notifications
# export SLACK_URL="your-slack-webhook-url"
EOF

    echo -e "${GREEN}✅ Configuration saved to: $CONFIG_FILE${NC}"
    echo ""
    echo -e "${YELLOW}💡 To use these variables in future sessions:${NC}"
    echo -e "   source $CONFIG_FILE"
    echo ""
    echo -e "${YELLOW}💡 To make permanent, add to your shell profile:${NC}"
    echo -e "   echo 'source $CONFIG_FILE' >> ~/.zshrc"
    echo -e "   source ~/.zshrc"
}

# Test deployment setup
test_deployment() {
    echo -e "${BLUE}🧪 Testing deployment setup...${NC}"
    
    cd ios
    
    # Check if Fastlane is available
    if ! bundle exec fastlane --version &> /dev/null; then
        echo -e "${YELLOW}Installing Fastlane dependencies...${NC}"
        bundle install
    fi
    
    # Test API connection
    echo -e "${YELLOW}Testing App Store Connect API connection...${NC}"
    
    # Create temporary API key file
    echo "$APP_STORE_CONNECT_API_KEY" | base64 --decode > AuthKey_$APP_STORE_CONNECT_API_KEY_ID.p8
    
    # Test connection (this will just validate credentials)
    if bundle exec fastlane run app_store_connect_api_key \
        key_id:"$APP_STORE_CONNECT_API_KEY_ID" \
        issuer_id:"$APP_STORE_CONNECT_ISSUER_ID" \
        key_filepath:"AuthKey_$APP_STORE_CONNECT_API_KEY_ID.p8" &> /dev/null; then
        echo -e "${GREEN}✅ App Store Connect API connection successful!${NC}"
    else
        echo -e "${RED}❌ App Store Connect API connection failed${NC}"
        echo -e "${YELLOW}💡 Please check your API credentials${NC}"
    fi
    
    # Cleanup
    rm -f AuthKey_*.p8
    
    cd ..
    
    echo -e "${GREEN}🎉 Setup test completed!${NC}"
    echo ""
    echo -e "${BLUE}🚀 You can now run:${NC}"
    echo -e "   make deploy-testflight"
    echo -e "   make deploy-appstore"
}

# Main execution
main() {
    show_setup_instructions
    echo ""
    
    if check_existing_env; then
        echo -e "${BLUE}Do you want to test the deployment setup? (y/N): ${NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            test_deployment
        fi
    else
        echo ""
        echo -e "${BLUE}Do you want to configure the environment variables now? (Y/n): ${NC}"
        read -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            interactive_setup
            generate_shell_config
            test_deployment
        fi
    fi
}

main "$@"
