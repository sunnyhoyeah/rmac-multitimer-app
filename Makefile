# RMAC MultiTimer - Development Commands
.PHONY: help setup clean test build-ios build-android build-all version-patch version-minor version-major release iphone-list iphone-install iphone-test

# Default target
help:
	@echo "🚀 RMAC MultiTimer Development Commands"
	@echo ""
	@echo "📋 Available commands:"
	@echo "  make setup           - Setup development environment"
	@echo "  make clean           - Clean build artifacts"
	@echo "  make test            - Run tests"
	@echo "  make analyze         - Run code analysis"
	@echo "  make format          - Format code"
	@echo ""
	@echo "🔨 Build commands:"
	@echo "  make build-ios       - Build iOS app (release)"
	@echo "  make build-android   - Build Android app (release)"
	@echo "  make build-all       - Build both iOS and Android"
	@echo "  make build-debug     - Build debug versions"
	@echo "  make build-release   - Build release APK and AAB (crash-fixed)"
	@echo ""
	@echo "📱 Testing commands:"
	@echo "  make install-apk         - Install APK to connected Android device"
	@echo "  make test-haptic-debug   - Test haptic feedback with debug logging"
	@echo "  make test-haptic-comprehensive - Run full haptic test suite"
	@echo "  make crash-fix-guide     - Show crash fix guide"
	@echo ""
	@echo "📱 iPhone device commands:"
	@echo "  make iphone-list     - List connected iPhones"
	@echo "  make iphone-install  - Install app to connected iPhone"
	@echo "  make iphone-test     - Run integration tests on iPhone"
	@echo "  make iphone-deploy   - Deploy to TestFlight (guidance)"
	@echo ""
	@echo "📦 Version management:"
	@echo "  make version-patch   - Bump patch version (1.0.0 -> 1.0.1)"
	@echo "  make version-minor   - Bump minor version (1.0.0 -> 1.1.0)"
	@echo "  make version-major   - Bump major version (1.0.0 -> 2.0.0)"
	@echo ""
	@echo "🚀 Release commands (Git-triggered deployment):"
	@echo "  make release-patch   - Bump patch version, commit, tag & deploy"
	@echo "  make release-minor   - Bump minor version, commit, tag & deploy"
	@echo "  make release-major   - Bump major version, commit, tag & deploy"
	@echo "  make release-beta    - Create beta release to TestFlight"
	@echo "  make release-alpha   - Create alpha release to TestFlight"
	@echo ""
	@echo "📱 Manual App Store Connect (local deployment):"
	@echo "  make deploy-testflight  - Deploy to TestFlight (manual)"
	@echo "  make deploy-appstore    - Deploy to App Store (manual)"
	@echo "  make deploy-appstore-no-precheck - Deploy to App Store (skip precheck)"
	@echo "  make setup-fastlane     - Setup Fastlane dependencies"
	@echo "  make ios-certificates   - Setup iOS certificates"
	@echo ""
	@echo "🤖 Android / Google Play Store commands:"
	@echo "  make build-android-aab   - Build Android App Bundle (AAB) for Play Store"
	@echo "  make build-android-apk   - Build Android APK for testing"
	@echo "  make android-guide       - Show Google Play Store submission guide"
	@echo ""
	@echo "🔍 Preview commands:"
	@echo "  make preview-release-patch - Preview patch release changes"
	@echo "  make preview-release-minor - Preview minor release changes"
	@echo "  make preview-release-major - Preview major release changes"

# Setup development environment
setup:
	@echo "🛠️  Setting up development environment..."
	flutter doctor
	flutter pub get
	@echo "✅ Setup complete!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	flutter clean
	flutter pub get
	@echo "✅ Clean complete!"

# Run tests
test:
	@echo "🧪 Running tests..."
	flutter test
	@echo "✅ Tests complete!"

# Code analysis
analyze:
	@echo "🔍 Running code analysis..."
	dart analyze
	@echo "✅ Analysis complete!"

# Format code
format:
	@echo "💅 Formatting code..."
	dart format .
	@echo "✅ Formatting complete!"

# Build commands
build-ios:
	@echo "🍎 Building iOS (release)..."
	./scripts/build.sh ios release

build-android:
	@echo "🤖 Building Android (release)..."
	./scripts/build.sh android release

build-all:
	@echo "📱 Building all platforms (release)..."
	./scripts/build.sh all release

build-debug:
	@echo "🔧 Building debug versions..."
	./scripts/build.sh all debug

build-release:
	@echo "🔨 Building release APK and AAB with crash fixes..."
	flutter clean
	flutter pub get
	flutter build apk --release
	flutter build appbundle --release
	@echo "✅ Release builds complete:"
	@echo "   APK: build/app/outputs/flutter-apk/app-release.apk"
	@echo "   AAB: build/app/outputs/bundle/release/app-release.aab"

# Android / Google Play Store builds
build-android-aab:
	@echo "🤖 Building Android App Bundle (AAB) for Google Play Store..."
	flutter build appbundle --release --no-shrink
	@echo "✅ AAB built successfully at: build/app/outputs/bundle/release/app-release.aab"
	@echo "📊 Size: $(shell ls -lh build/app/outputs/bundle/release/app-release.aab | awk '{print $$5}')"

build-android-apk:
	@echo "🤖 Building Android APK for testing..."
	flutter build apk --release --no-shrink
	@echo "✅ APK built successfully at: build/app/outputs/flutter-apk/app-release.apk"
	@echo "📊 Size: $(shell ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $$5}')"

# Install APK to connected Android device
install-apk:
	@echo "📱 Installing APK to Android device..."
	adb install build/app/outputs/flutter-apk/app-release.apk
	@echo "✅ APK installed. Try opening the app to test the crash fix."

# Crash fix guide
crash-fix-guide:
	@echo "🛠️  App Crash Fix Guide"
	@echo "======================="
	@cat CRASH_FIX_GUIDE.md

critical-fix-guide:
	@echo "🚨 CRITICAL Crash Fix Guide - Version 58"
	@echo "========================================"
	@cat CRITICAL_CRASH_FIX_V58.md

app-icon-guide:
	@echo "🎯 App Icon Fix Guide - Version 59"
	@echo "================================="
	@cat APP_ICON_FIX.md

deobfuscation-guide:
	@echo "📊 去模糊化檔案修復指南 - Version 60"
	@echo "===================================="
	@cat DEOBFUSCATION_FIX.md

testing-setup-guide:
	@echo "🧪 Google Play 內部測試設定指南"
	@echo "==============================="
	@cat GOOGLE_PLAY_TESTING_SETUP.md

# Version management (manual version bump only)
version-patch:
	@echo "📦 Bumping patch version..."
	./scripts/bump_version.sh patch

version-minor:
	@echo "📦 Bumping minor version..."
	./scripts/bump_version.sh minor

version-major:
	@echo "📦 Bumping major version..."
	./scripts/bump_version.sh major

# Git-triggered release commands (automated deployment)
release-patch:
	@echo "🚀 Creating patch release (automated deployment)..."
	./scripts/release.sh patch

release-minor:
	@echo "🚀 Creating minor release (automated deployment)..."
	./scripts/release.sh minor

release-major:
	@echo "🚀 Creating major release (automated deployment)..."
	./scripts/release.sh major

release-beta:
	@echo "🧪 Creating beta release (TestFlight)..."
	@read -p "Enter release notes: " notes; \
	./scripts/release.sh patch "$$notes" --beta

release-alpha:
	@echo "🧪 Creating alpha release (TestFlight)..."
	@read -p "Enter release notes: " notes; \
	./scripts/release.sh patch "$$notes" --alpha

# Preview release changes (dry run)
preview-release-patch:
	@echo "🔍 Previewing patch release..."
	./scripts/release.sh patch "" true

preview-release-minor:
	@echo "🔍 Previewing minor release..."
	./scripts/release.sh minor "" true

preview-release-major:
	@echo "🔍 Previewing major release..."
	./scripts/release.sh major "" true

# Development commands
dev-ios:
	@echo "🍎 Starting iOS development..."
	flutter run -d ios

dev-android:
	@echo "🤖 Starting Android development..."
	flutter run -d android

# Install dependencies
deps:
	@echo "📦 Installing dependencies..."
	flutter pub get
	@echo "✅ Dependencies installed!"

# Generate build files
generate:
	@echo "⚙️  Generating build files..."
	flutter pub run build_runner build --delete-conflicting-outputs
	@echo "✅ Generation complete!"

# App Store Connect deployment
deploy-testflight:
	@echo "🛫 Deploying to TestFlight..."
	./scripts/appstore_deploy.sh testflight "Automated TestFlight release"

deploy-appstore:
	@echo "🏪 Deploying to App Store..."
	./scripts/appstore_deploy.sh appstore "New release with latest features"

deploy-appstore-no-precheck:
	@echo "🏪 Deploying to App Store (skip precheck)..."
	./scripts/appstore_deploy.sh appstore-no-precheck "New release with latest features"

# iOS-specific setup
setup-fastlane:
	@echo "💎 Setting up Fastlane..."
	cd ios && bundle install
	@echo "✅ Fastlane setup complete!"

ios-certificates:
	@echo "📱 Setting up iOS certificates..."
	cd ios && bundle exec fastlane certificates
	@echo "✅ iOS certificates setup complete!"

# iPhone device management
iphone-list:
	@echo "📱 Listing connected iPhones..."
	./scripts/iphone_connect.sh list

iphone-install:
	@echo "📲 Installing app to iPhone..."
	./scripts/iphone_connect.sh install

iphone-test:
	@echo "🧪 Testing app on iPhone..."
	./scripts/iphone_connect.sh test

iphone-deploy:
	@echo "� Deploying to TestFlight via iPhone..."
	./scripts/iphone_connect.sh deploy
	@echo "🚀 TestFlight deployment guidance..."
	./scripts/iphone_connect.sh deploy

# Integration testing
test-integration:
	@echo "🧪 Running integration tests..."
	flutter test integration_test/

# Device testing (requires connected device)
test-device:
	@echo "📱 Running tests on connected device..."
	flutter test integration_test/ -d ios

# TestFlight automation (requires GitHub Actions)
testflight:
	@echo "🚀 Triggering TestFlight deployment via GitHub Actions..."
	gh workflow run ios-device-distribution.yml --field distribution_type=testflight

# 📦 Google Play Store commands
play-store-guide:
	@echo "📱 Google Play Store Submission Guide"
	@echo "========================================"
	@cat GOOGLE_PLAY_STORE_GUIDE.md

# Testing commands
test-timer-bug:
	@echo "🧪 Testing timer persistence bug fix..."
	@echo "📋 MANUAL TEST STEPS:"
	@echo "   1. Add 16+ rows using the + button"
	@echo "   2. Press 'Start All' to start all timers"
	@echo "   3. Scroll down to see rows 8-16, wait a few seconds"
	@echo "   4. Scroll back up to see rows 1-8"
	@echo "   5. ✅ EXPECTED: All timers continue running with correct elapsed time"
	@echo "   6. ❌ BUG (FIXED): First 4 rows showed 00:00:00 or froze"
	@echo ""
	@echo "🚀 Starting app for testing..."
	flutter run -d emulator-5554

test-debug:
	@echo "🧪 Running debug build for testing..."
	flutter run --debug

test-haptic-debug:
	@echo "📳 Comprehensive Android Haptic Feedback Debug Testing..."
	@echo "📋 INSTRUCTIONS:"
	@echo "   1. Connect Android device via USB"
	@echo "   2. Enable USB debugging on device"
	@echo "   3. Run debug app with haptic logging filter"
	@echo "   4. Tap Start button ONCE (when timer shows 00:00:00)"
	@echo "   5. Watch console for comprehensive test results:"
	@echo "      🧪 TEST 1-9: Individual haptic method tests"
	@echo "      ✅ SUCCESS  OR  ❌ ERROR messages"
	@echo ""
	@echo "🔧 TROUBLESHOOTING:"
	@echo "   - Check ANDROID_HAPTIC_TROUBLESHOOTING.md for detailed guide"
	@echo "   - Verify: Settings > Sound > Touch vibration = ON"
	@echo "   - Disable: Do Not Disturb and Battery Saver modes"
	@echo "   - Test vibration with native phone app first"
	@echo ""
	@echo "🚀 Starting debug app with haptic logging filter..."
	flutter run --debug | grep -E "(🔔|📱|🎛️|✅|❌|🧪|haptic|vibrat)"

test-haptic-comprehensive:
	@echo "📳 Running comprehensive haptic test via script..."
	@echo "📋 This will:"
	@echo "   1. Build debug APK"
	@echo "   2. Install on connected Android device"
	@echo "   3. Run app with detailed haptic logging"
	@echo "   4. Show troubleshooting guidance"
	@echo ""
	./test_haptic_android.sh

test-haptic:
	@echo "📳 Testing haptic feedback fix..."
	@echo "📋 MANUAL TEST STEPS:"
	@echo "   1. Install the app on an Android device"
	@echo "   2. Tap the Start/Stop button - should feel vibration"
	@echo "   3. Tap the Lap/Reset button - should feel vibration"
	@echo "   4. Compare with iOS device for consistency"
	@echo "   5. ✅ EXPECTED: Haptic feedback works on both platforms"
	@echo "   6. ❌ PREVIOUS: Only worked on iOS, silent on Android"
	@echo ""
	@echo "🔧 TECHNICAL FIX:"
	@echo "   - Added VIBRATE permission to AndroidManifest.xml"
	@echo "   - Enhanced haptic feedback with error handling"
	@echo "   - Added fallback for device compatibility"
	@echo ""
