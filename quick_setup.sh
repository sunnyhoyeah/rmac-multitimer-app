#!/bin/bash

# Quick setup script with pre-filled values
echo "🚀 Quick App Store Connect Setup"
echo ""

# Set the environment variables directly
export FASTLANE_USER="sunmoon.yu@gmail.com"
export APP_STORE_CONNECT_API_KEY_ID="LX4RW29VFH"
export APP_STORE_CONNECT_ISSUER_ID="7554bcb1-4a61-4c87-af77-a97d50fdba29"

# Convert the API key file to base64
if [ -f "assets/AuthKey_LX4RW29VFH.p8" ]; then
    export APP_STORE_CONNECT_API_KEY=$(base64 -i assets/AuthKey_LX4RW29VFH.p8)
    echo "✅ API key loaded from file"
else
    echo "❌ API key file not found at assets/AuthKey_LX4RW29VFH.p8"
    exit 1
fi

# Prompt for password
echo -n "Enter your app-specific password: "
read -s FASTLANE_PASSWORD
export FASTLANE_PASSWORD
echo ""

# Generate config file
CONFIG_FILE="$HOME/.appstore_connect_env"
cat > "$CONFIG_FILE" << EOF
# App Store Connect Environment Variables for RMAC MultiTimer
export FASTLANE_USER="$FASTLANE_USER"
export FASTLANE_PASSWORD="$FASTLANE_PASSWORD"
export APP_STORE_CONNECT_API_KEY_ID="$APP_STORE_CONNECT_API_KEY_ID"
export APP_STORE_CONNECT_ISSUER_ID="$APP_STORE_CONNECT_ISSUER_ID"
export APP_STORE_CONNECT_API_KEY="$APP_STORE_CONNECT_API_KEY"
EOF

echo "✅ Configuration saved to: $CONFIG_FILE"
echo ""
echo "🧪 Testing API connection..."

# Test the connection
cd ios
if bundle exec fastlane test_api; then
    echo "✅ API connection successful!"
    echo "🚀 You can now run: make deploy-testflight"
else
    echo "❌ API connection failed - check your credentials"
fi
