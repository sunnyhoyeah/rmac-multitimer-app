#!/bin/bash

# App Store Connect Deployment Script for RMAC MultiTimer
# Usage: ./scripts/appstore_deploy.sh [testflight|appstore] [release_notes]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

DEPLOYMENT_TYPE=${1:-testflight}
RELEASE_NOTES=${2:-"Automated release via script"}

# Handle help command first
if [[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
    show_usage() {
        echo -e "${BLUE}🚀 App Store Connect Deployment Script${NC}"
        echo ""
        echo -e "${YELLOW}Usage:${NC} ./scripts/appstore_deploy.sh [deployment_type] [release_notes]"
        echo ""
        echo -e "${YELLOW}Deployment Types:${NC}"
        echo -e "  ${GREEN}testflight${NC}  - Deploy to TestFlight for beta testing"
        echo -e "  ${GREEN}appstore${NC}    - Deploy to App Store for public release"
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo -e "  ./scripts/appstore_deploy.sh testflight \"Bug fixes and improvements\""
        echo -e "  ./scripts/appstore_deploy.sh appstore \"New timer features added\""
        echo ""
        echo -e "${YELLOW}Environment Setup:${NC}"
        echo -e "  Set these environment variables before running:"
        echo -e "  • FASTLANE_USER"
        echo -e "  • FASTLANE_PASSWORD"
        echo -e "  • APP_STORE_CONNECT_API_KEY_ID"
        echo -e "  • APP_STORE_CONNECT_ISSUER_ID"
        echo -e "  • APP_STORE_CONNECT_API_KEY"
    }
    show_usage
    exit 0
fi

echo -e "${BLUE}🚀 RMAC MultiTimer - App Store Connect Deployment${NC}"
echo -e "${BLUE}Deployment Type: $DEPLOYMENT_TYPE${NC}"
echo ""

# Validate deployment type
if [[ ! "$DEPLOYMENT_TYPE" =~ ^(testflight|appstore)$ ]]; then
    echo -e "${RED}Error: Invalid deployment type. Use 'testflight' or 'appstore'${NC}"
    exit 1
fi

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔧 Checking prerequisites...${NC}"
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}❌ Please run this script from the project root directory${NC}"
        exit 1
    fi
    
    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
        exit 1
    fi
    
    # Check Ruby and Bundler
    if ! command -v bundle &> /dev/null; then
        echo -e "${YELLOW}Installing bundler...${NC}"
        gem install bundler
    fi
    
    # Check Fastlane
    cd ios
    if [ ! -f "Gemfile" ]; then
        echo -e "${RED}❌ Gemfile not found in ios directory${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Installing Ruby dependencies...${NC}"
    bundle install
    cd ..
    
    echo -e "${GREEN}✅ Prerequisites checked!${NC}"
}

# Setup environment variables
setup_environment() {
    echo -e "${YELLOW}🔧 Setting up environment...${NC}"
    
    # Check for required environment variables
    REQUIRED_VARS=(
        "FASTLANE_USER"
        "FASTLANE_PASSWORD"
        "APP_STORE_CONNECT_API_KEY_ID"
        "APP_STORE_CONNECT_ISSUER_ID"
        "APP_STORE_CONNECT_API_KEY"
    )
    
    MISSING_VARS=()
    
    for var in "${REQUIRED_VARS[@]}"; do
        if [ -z "${!var}" ]; then
            MISSING_VARS+=("$var")
        fi
    done
    
    if [ ${#MISSING_VARS[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing required environment variables:${NC}"
        for var in "${MISSING_VARS[@]}"; do
            echo -e "   ${RED}• $var${NC}"
        done
        echo ""
        echo -e "${YELLOW}💡 Setup instructions:${NC}"
        echo -e "   1. Create App Store Connect API Key:"
        echo -e "      https://appstoreconnect.apple.com/access/api"
        echo -e "   2. Set environment variables in your shell profile:"
        echo -e "      export FASTLANE_USER=\"your-apple-id@email.com\""
        echo -e "      export FASTLANE_PASSWORD=\"your-app-specific-password\""
        echo -e "      export APP_STORE_CONNECT_API_KEY_ID=\"your-key-id\""
        echo -e "      export APP_STORE_CONNECT_ISSUER_ID=\"your-issuer-id\""
        echo -e "      export APP_STORE_CONNECT_API_KEY=\"base64-encoded-p8-key\""
        echo ""
        echo -e "${YELLOW}   Or use GitHub Secrets for automated deployment${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Environment configured!${NC}"
}

# Get current version from pubspec.yaml
get_version() {
    VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
    BUILD=$(grep '^version:' pubspec.yaml | cut -d'+' -f2)
    echo -e "${BLUE}📦 Current version: $VERSION ($BUILD)${NC}"
}

# Deploy to TestFlight
deploy_testflight() {
    echo -e "${PURPLE}🛫 Deploying to TestFlight...${NC}"
    
    cd ios
    
    # Create API key file
    echo "$APP_STORE_CONNECT_API_KEY" | base64 --decode > AuthKey_$APP_STORE_CONNECT_API_KEY_ID.p8
    
    # Deploy using Fastlane
    bundle exec fastlane deploy_testflight changelog:"$RELEASE_NOTES"
    
    # Cleanup
    rm -f AuthKey_*.p8
    
    cd ..
    
    echo -e "${GREEN}✅ TestFlight deployment completed!${NC}"
    echo -e "${BLUE}💡 Check TestFlight for your new build${NC}"
}

# Deploy to App Store
deploy_appstore() {
    echo -e "${PURPLE}🏪 Deploying to App Store...${NC}"
    
    echo -e "${YELLOW}⚠️  This will submit your app for App Store review!${NC}"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deployment cancelled${NC}"
        exit 0
    fi
    
    cd ios
    
    # Create API key file
    echo "$APP_STORE_CONNECT_API_KEY" | base64 --decode > AuthKey_$APP_STORE_CONNECT_API_KEY_ID.p8
    
    # Deploy using Fastlane
    bundle exec fastlane deploy_appstore release_notes:"$RELEASE_NOTES"
    
    # Cleanup
    rm -f AuthKey_*.p8
    
    cd ..
    
    echo -e "${GREEN}✅ App Store deployment completed!${NC}"
    echo -e "${BLUE}💡 Your app has been submitted for review${NC}"
}

# Show usage
show_usage() {
    echo -e "${BLUE}🚀 App Store Connect Deployment Script${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC} ./scripts/appstore_deploy.sh [deployment_type] [release_notes]"
    echo ""
    echo -e "${YELLOW}Deployment Types:${NC}"
    echo -e "  ${GREEN}testflight${NC}  - Deploy to TestFlight for beta testing"
    echo -e "  ${GREEN}appstore${NC}    - Deploy to App Store for public release"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  ./scripts/appstore_deploy.sh testflight \"Bug fixes and improvements\""
    echo -e "  ./scripts/appstore_deploy.sh appstore \"New timer features added\""
    echo ""
    echo -e "${YELLOW}Environment Setup:${NC}"
    echo -e "  Set these environment variables before running:"
    echo -e "  • FASTLANE_USER"
    echo -e "  • FASTLANE_PASSWORD"
    echo -e "  • APP_STORE_CONNECT_API_KEY_ID"
    echo -e "  • APP_STORE_CONNECT_ISSUER_ID"
    echo -e "  • APP_STORE_CONNECT_API_KEY"
}

# Main execution
main() {
    case "$DEPLOYMENT_TYPE" in
        "testflight")
            check_prerequisites
            setup_environment
            get_version
            deploy_testflight
            ;;
        "appstore")
            check_prerequisites
            setup_environment
            get_version
            deploy_appstore
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            echo -e "${RED}❌ Unknown deployment type: $DEPLOYMENT_TYPE${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
