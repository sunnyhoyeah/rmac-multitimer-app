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
