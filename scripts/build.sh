#!/bin/bash

# Build script for RMAC MultiTimer
# Usage: ./scripts/build.sh [ios|android|all] [debug|release]

set -e

PLATFORM=${1:-all}
BUILD_MODE=${2:-release}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 RMAC MultiTimer Build Script${NC}"
echo -e "${BLUE}Platform: $PLATFORM | Mode: $BUILD_MODE${NC}"
echo ""

# Validate inputs
if [[ ! "$PLATFORM" =~ ^(ios|android|all)$ ]]; then
    echo -e "${RED}Error: Invalid platform. Use 'ios', 'android', or 'all'${NC}"
    exit 1
fi

if [[ ! "$BUILD_MODE" =~ ^(debug|release)$ ]]; then
    echo -e "${RED}Error: Invalid build mode. Use 'debug' or 'release'${NC}"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2)
echo -e "${YELLOW}📦 Building version: $CURRENT_VERSION${NC}"
echo ""

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Function to build iOS
build_ios() {
    echo -e "${BLUE}🍎 Building iOS ($BUILD_MODE)...${NC}"
    
    if [[ "$BUILD_MODE" == "release" ]]; then
        flutter build ios --release --no-codesign
    else
        flutter build ios --debug --no-codesign
    fi
    
    echo -e "${GREEN}✅ iOS build completed!${NC}"
    echo -e "${GREEN}📁 iOS build location: build/ios/iphoneos/Runner.app${NC}"
}

# Function to build Android
build_android() {
    echo -e "${BLUE}🤖 Building Android ($BUILD_MODE)...${NC}"
    
    if [[ "$BUILD_MODE" == "release" ]]; then
        # Build APK
        flutter build apk --release
        echo -e "${GREEN}✅ Android APK build completed!${NC}"
        echo -e "${GREEN}📁 APK location: build/app/outputs/flutter-apk/app-release.apk${NC}"
        
        # Build App Bundle
        flutter build appbundle --release
        echo -e "${GREEN}✅ Android App Bundle build completed!${NC}"
        echo -e "${GREEN}📁 AAB location: build/app/outputs/bundle/release/app-release.aab${NC}"
    else
        flutter build apk --debug
        echo -e "${GREEN}✅ Android debug APK build completed!${NC}"
        echo -e "${GREEN}📁 APK location: build/app/outputs/flutter-apk/app-debug.apk${NC}"
    fi
}

# Execute builds based on platform
case "$PLATFORM" in
    "ios")
        build_ios
        ;;
    "android")
        build_android
        ;;
    "all")
        build_ios
        echo ""
        build_android
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Build process completed successfully!${NC}"

# Show build artifacts
echo ""
echo -e "${YELLOW}📋 Build Artifacts:${NC}"
if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]]; then
    if [[ -d "build/ios/iphoneos/Runner.app" ]]; then
        echo -e "${GREEN}  ✅ iOS: build/ios/iphoneos/Runner.app${NC}"
    fi
fi

if [[ "$PLATFORM" == "android" || "$PLATFORM" == "all" ]]; then
    if [[ "$BUILD_MODE" == "release" ]]; then
        if [[ -f "build/app/outputs/flutter-apk/app-release.apk" ]]; then
            echo -e "${GREEN}  ✅ Android APK: build/app/outputs/flutter-apk/app-release.apk${NC}"
        fi
        if [[ -f "build/app/outputs/bundle/release/app-release.aab" ]]; then
            echo -e "${GREEN}  ✅ Android AAB: build/app/outputs/bundle/release/app-release.aab${NC}"
        fi
    else
        if [[ -f "build/app/outputs/flutter-apk/app-debug.apk" ]]; then
            echo -e "${GREEN}  ✅ Android Debug APK: build/app/outputs/flutter-apk/app-debug.apk${NC}"
        fi
    fi
fi
