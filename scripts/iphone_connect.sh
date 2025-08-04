#!/bin/bash

# iPhone Device Management Script for RMAC MultiTimer
# Usage: ./scripts/iphone_connect.sh [list|install|test|deploy]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

ACTION=${1:-list}

echo -e "${BLUE}📱 RMAC MultiTimer - iPhone Device Manager${NC}"
echo -e "${BLUE}Action: $ACTION${NC}"
echo ""

# Install required tools if not present
install_tools() {
    echo -e "${YELLOW}🔧 Checking required tools...${NC}"
    
    # Check for ios-deploy
    if ! command -v ios-deploy &> /dev/null; then
        echo -e "${YELLOW}Installing ios-deploy...${NC}"
        npm install -g ios-deploy
    fi
    
    # Check for ideviceinstaller
    if ! command -v ideviceinstaller &> /dev/null; then
        echo -e "${YELLOW}Installing libimobiledevice...${NC}"
        if command -v brew &> /dev/null; then
            brew install libimobiledevice
        else
            echo -e "${RED}Please install Homebrew first: https://brew.sh${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✅ Tools ready!${NC}"
}

# List connected devices
list_devices() {
    echo -e "${PURPLE}📱 Scanning for connected iOS devices...${NC}"
    echo ""
    
    # Using ios-deploy
    echo -e "${BLUE}Via ios-deploy:${NC}"
    ios-deploy --detect || echo -e "${YELLOW}No devices found via ios-deploy${NC}"
    echo ""
    
    # Using idevice_id
    echo -e "${BLUE}Via libimobiledevice:${NC}"
    if command -v idevice_id &> /dev/null; then
        DEVICES=$(idevice_id -l)
        if [ -z "$DEVICES" ]; then
            echo -e "${YELLOW}No devices found${NC}"
        else
            echo -e "${GREEN}Connected devices:${NC}"
            echo "$DEVICES" | while read -r device; do
                if [ ! -z "$device" ]; then
                    DEVICE_NAME=$(ideviceinfo -u "$device" -k DeviceName 2>/dev/null || echo "Unknown Device")
                    DEVICE_VERSION=$(ideviceinfo -u "$device" -k ProductVersion 2>/dev/null || echo "Unknown Version")
                    echo -e "${GREEN}  📱 $DEVICE_NAME (iOS $DEVICE_VERSION) - UDID: $device${NC}"
                fi
            done
        fi
    else
        echo -e "${YELLOW}libimobiledevice not available${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}💡 Tips:${NC}"
    echo -e "  • Make sure your iPhone is unlocked and trusted"
    echo -e "  • Check 'Trust This Computer' on your iPhone"
    echo -e "  • Use original Lightning/USB-C cable for best results"
}

# Install app to connected device
install_app() {
    echo -e "${PURPLE}📲 Installing RMAC MultiTimer to connected iPhone...${NC}"
    
    # Build the app first
    echo -e "${YELLOW}🔨 Building iOS app for device...${NC}"
    flutter clean
    flutter pub get
    cd ios && pod install && cd ..
    flutter build ios --debug --no-codesign
    
    # Install to device
    if ios-deploy --detect | grep -q "Found"; then
        echo -e "${GREEN}📱 Device detected! Installing app...${NC}"
        ios-deploy --bundle build/ios/iphoneos/Runner.app --debug --no-wifi --justlaunch
        echo -e "${GREEN}✅ App installed and launched successfully!${NC}"
    else
        echo -e "${RED}❌ No iPhone detected. Please connect your iPhone and try again.${NC}"
        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo -e "  1. Connect iPhone with USB cable"
        echo -e "  2. Unlock your iPhone"
        echo -e "  3. Tap 'Trust' on the popup"
        echo -e "  4. Run: ./scripts/iphone_connect.sh list"
        exit 1
    fi
}

# Run tests on connected device
test_device() {
    echo -e "${PURPLE}🧪 Running tests on connected iPhone...${NC}"
    
    # Check for connected devices first
    if ! ios-deploy --detect | grep -q "Found"; then
        echo -e "${RED}❌ No iPhone connected. Please connect your device first.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}📱 Running Flutter tests on device...${NC}"
    
    # Run unit tests first
    echo -e "${BLUE}Running unit tests...${NC}"
    flutter test
    
    # Check for integration tests
    if [ -d "integration_test" ]; then
        echo -e "${BLUE}Running integration tests on device...${NC}"
        flutter test integration_test/ -d ios
    else
        echo -e "${YELLOW}No integration tests found. Creating basic integration test...${NC}"
        mkdir -p integration_test
        cat > integration_test/app_test.dart << EOF
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rmac_multitimer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('RMAC MultiTimer Integration Tests', () {
    testWidgets('App should launch and display main screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app launches
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('Basic navigation test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Add more specific tests based on your app's UI
      // For example, test timer functionality, navigation, etc.
    });
  });
}
EOF
        
        # Add integration_test dependency to pubspec.yaml if not present
        if ! grep -q "integration_test:" pubspec.yaml; then
            echo -e "${YELLOW}Adding integration_test dependency...${NC}"
            cat >> pubspec.yaml << EOF

dev_dependencies:
  integration_test:
    sdk: flutter
EOF
            flutter pub get
        fi
        
        echo -e "${GREEN}✅ Basic integration test created. Running on device...${NC}"
        flutter test integration_test/ -d ios
    fi
    
    echo -e "${GREEN}✅ Device testing completed!${NC}"
}

# Deploy to TestFlight
deploy_testflight() {
    echo -e "${PURPLE}🚀 Deploying to TestFlight...${NC}"
    
    # Check if we have the necessary secrets/certificates
    echo -e "${YELLOW}⚠️  This requires proper code signing certificates and App Store Connect API keys.${NC}"
    echo -e "${YELLOW}For automated TestFlight deployment, use GitHub Actions workflow.${NC}"
    echo ""
    echo -e "${BLUE}Manual TestFlight deployment steps:${NC}"
    echo -e "  1. Build release version: flutter build ios --release"
    echo -e "  2. Open ios/Runner.xcworkspace in Xcode"
    echo -e "  3. Archive the app (Product > Archive)"
    echo -e "  4. Upload to App Store Connect"
    echo -e "  5. Submit for TestFlight review"
    echo ""
    echo -e "${BLUE}Automated deployment:${NC}"
    echo -e "  • Push to main branch for automatic TestFlight deployment"
    echo -e "  • Or use: gh workflow run ios-device-distribution.yml"
}

# Show usage help
show_help() {
    echo -e "${BLUE}📱 RMAC MultiTimer - iPhone Device Manager${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC} ./scripts/iphone_connect.sh [command]"
    echo ""
    echo -e "${YELLOW}Commands:${NC}"
    echo -e "  ${GREEN}list${NC}     - List all connected iOS devices"
    echo -e "  ${GREEN}install${NC}  - Build and install app to connected iPhone"
    echo -e "  ${GREEN}test${NC}     - Run tests on connected iPhone"
    echo -e "  ${GREEN}deploy${NC}   - Deploy to TestFlight (manual guidance)"
    echo -e "  ${GREEN}help${NC}     - Show this help message"
    echo ""
    echo -e "${YELLOW}Prerequisites:${NC}"
    echo -e "  • iPhone connected via USB cable"
    echo -e "  • iPhone unlocked and trusted"
    echo -e "  • Xcode installed with command line tools"
    echo -e "  • Flutter development setup complete"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ./scripts/iphone_connect.sh list"
    echo -e "  ./scripts/iphone_connect.sh install"
    echo -e "  ./scripts/iphone_connect.sh test"
}

# Main execution
case "$ACTION" in
    "list")
        install_tools
        list_devices
        ;;
    "install")
        install_tools
        install_app
        ;;
    "test")
        install_tools
        test_device
        ;;
    "deploy")
        deploy_testflight
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown action: $ACTION${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
