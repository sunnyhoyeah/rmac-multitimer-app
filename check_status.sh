#!/bin/bash

# Check the current setup status
echo "🔍 RMAC MultiTimer - App Store Connect Status Check"
echo ""

# Check environment file
if [ -f "$HOME/.appstore_connect_env" ]; then
    echo "✅ Environment configuration file exists"
    echo "   Location: $HOME/.appstore_connect_env"
else
    echo "❌ Environment configuration file not found"
fi

# Source environment and check variables
if [ -f "$HOME/.appstore_connect_env" ]; then
    source "$HOME/.appstore_connect_env"
    
    echo ""
    echo "📋 Environment Variables Status:"
    
    if [ ! -z "$FASTLANE_USER" ]; then
        echo "✅ FASTLANE_USER: $FASTLANE_USER"
    else
        echo "❌ FASTLANE_USER not set"
    fi
    
    if [ ! -z "$APP_STORE_CONNECT_API_KEY_ID" ]; then
        echo "✅ APP_STORE_CONNECT_API_KEY_ID: $APP_STORE_CONNECT_API_KEY_ID"
    else
        echo "❌ APP_STORE_CONNECT_API_KEY_ID not set"
    fi
    
    if [ ! -z "$APP_STORE_CONNECT_ISSUER_ID" ]; then
        echo "✅ APP_STORE_CONNECT_ISSUER_ID: $APP_STORE_CONNECT_ISSUER_ID"
    else
        echo "❌ APP_STORE_CONNECT_ISSUER_ID not set"
    fi
    
    if [ ! -z "$FASTLANE_PASSWORD" ]; then
        echo "✅ FASTLANE_PASSWORD: [HIDDEN]"
    else
        echo "❌ FASTLANE_PASSWORD not set"
    fi
    
    if [ ! -z "$APP_STORE_CONNECT_API_KEY" ]; then
        echo "✅ APP_STORE_CONNECT_API_KEY: [HIDDEN]"
    else
        echo "❌ APP_STORE_CONNECT_API_KEY not set"
    fi
fi

echo ""
echo "🧪 Testing API Connection..."

cd ios
if bundle exec fastlane test_api > /dev/null 2>&1; then
    echo "✅ App Store Connect API connection successful!"
else
    echo "❌ App Store Connect API connection failed"
fi

echo ""
echo "🚀 Available Commands:"
echo "   make deploy-testflight    - Deploy to TestFlight"
echo "   make deploy-appstore      - Deploy to App Store"
echo ""
echo "   Or run directly:"
echo "   source ~/.appstore_connect_env"
echo "   cd ios && bundle exec fastlane deploy_testflight"
echo ""
echo "🔧 Individual Fastlane Commands:"
echo "   bundle exec fastlane test_api        - Test API connection"
echo "   bundle exec fastlane build_release   - Build app for release"
echo "   bundle exec fastlane testflight_upload - Upload to TestFlight only"
echo "   bundle exec fastlane appstore_upload - Upload to App Store only"
