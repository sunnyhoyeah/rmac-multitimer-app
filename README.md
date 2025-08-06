# RMAC MultiTimer

A Flutter-based multi-timer application for track and field events. Built with automated CI/CDmake deploy-appstore-no-precheck # → App Store (skip precheck)
```

### What Happens During Git-Triggered Deployment

1. ✅ **Version bumped** in `pubspec.yaml`
2. ✅ **Git commit** created and tagged  
3. ✅ **Pushed to GitHub** automatically
4. ✅ **GitHub Actions** builds iOS app
5. ✅ **Automated upload** to TestFlight/App Store Connect
6. ✅ **GitHub Release** created with IPA file
7. ✅ **Notifications sent** (if configured)

#### Deploy to TestFlight
```bash
# Local deployment
make deploy-testflight

# Or via GitHub Actions
gh workflow run ios-appstore-deployment.yml -f deployment_type=testflight
```

#### Deploy to App Store
```bash
# Local deployment
make deploy-appstore

# Or via GitHub Actions
gh workflow run ios-appstore-deployment.yml -f deployment_type=appstore
```ent.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.24.0 or later)
- Xcode (for iOS builds)
- Android Studio (for Android builds)
- Make (for easy command execution)

### Setup
```bash
# Clone the repository
git clone https://github.com/sunnyhoyeah/rmac-multitimer-app.git
cd rmac-multitimer-app

# Setup development environment
make setup

# Run the app
flutter run
```

## 🔨 Development Commands

We use a Makefile for easy development workflow management:

```bash
# Show all available commands
make help

# Development
make setup           # Setup development environment
make clean           # Clean build artifacts
make test            # Run tests
make analyze         # Run code analysis
make format          # Format code

# Building
make build-ios       # Build iOS app (release)
make build-android   # Build Android app (release)
make build-all       # Build both platforms
make build-debug     # Build debug versions

# Version Management
make version-patch   # Bump patch version (1.0.0 -> 1.0.1)
make version-minor   # Bump minor version (1.0.0 -> 1.1.0)
make version-major   # Bump major version (1.0.0 -> 2.0.0)

# Releases (automatic version bump + git tag + push)
make release-patch   # Create patch release
make release-minor   # Create minor release
make release-major   # Create major release
```

## 📦 Automated Build & Release

### GitHub Actions

This project includes automated CI/CD with GitHub Actions:

- **Automatic versioning**: Patch version auto-increments on main branch pushes
- **Automated builds**: iOS and Android builds on every main branch push
- **Release creation**: Automatic GitHub releases with build artifacts
- **Code quality**: Automated testing, formatting, and analysis
- **App Store Connect**: Automated TestFlight and App Store deployment

### App Store Connect Deployment

The app supports both **automated git-triggered deployment** and **manual local deployment**.

#### 🤖 Git-Triggered Deployment (Recommended)

Simply commit, tag, and push - GitHub Actions handles everything!

**Production Releases (→ App Store):**
```bash
make release-patch    # Bug fixes: 1.0.0 → 1.0.1
make release-minor    # New features: 1.0.0 → 1.1.0  
make release-major    # Breaking changes: 1.0.0 → 2.0.0
```

**Beta/Testing (→ TestFlight):**
```bash
make release-beta     # Creates beta release to TestFlight
make release-alpha    # Creates alpha release to TestFlight
```

**Preview Changes (Dry Run):**
```bash
make preview-release-patch  # See what would happen
```

**Setup Required:** Configure GitHub Secrets - See [GitHub Actions Setup Guide](docs/GITHUB_ACTIONS_SETUP.md)

#### 📱 Manual Local Deployment

For testing or direct control:

**Setup (One-time):**
```bash
./scripts/setup_appstore_env.sh  # Configure API keys
make setup-fastlane              # Install Ruby dependencies
```

**Deploy:**
```bash
make deploy-testflight           # → TestFlight
make deploy-appstore             # → App Store  
make deploy-appstore-no-precheck # → App Store (skip precheck)
```
make ios-certificates
```

#### Deploy to TestFlight
```bash
# Local deployment
make deploy-testflight

# Or via GitHub Actions
gh workflow run ios-appstore-deployment.yml -f deployment_type=testflight
```

#### Deploy to App Store
```bash
# Local deployment
make deploy-appstore

# Or via GitHub Actions
gh workflow run ios-appstore-deployment.yml -f deployment_type=appstore
```

### Manual Release Workflow

1. **Local Development**:
   ```bash
   # Make your changes
   git add .
   git commit -m "feat: add new feature"
   
   # Create a release (automatically bumps version and pushes)
   make release-patch  # or release-minor, release-major
   ```

2. **GitHub Actions** will automatically:
   - Run tests and code analysis
   - Build iOS and Android apps
   - Create a GitHub release
   - Upload build artifacts

### Manual Version Control

You can also manually control versioning:

```bash
# Bump version without creating a release
./scripts/bump_version.sh patch  # or minor, major

# Manual build
./scripts/build.sh all release   # or ios/android, debug/release
```

## 🏗️ Project Structure

```
├── .github/workflows/     # GitHub Actions CI/CD
├── android/              # Android-specific files
├── ios/                  # iOS-specific files
├── lib/                  # Flutter source code
├── scripts/              # Build and version management scripts
├── test/                 # Test files
├── Makefile             # Development commands
└── pubspec.yaml         # Project dependencies and version
```

## 🔧 Configuration

### iOS Configuration
- Minimum iOS version: 12.0
- Configured in `ios/Podfile`
- Auto-versioning enabled

### Android Configuration
- Minimum SDK: Configured in `android/app/build.gradle`
- Auto-versioning enabled

## 🚀 Release Process

### Automated (Recommended)
1. Push changes to main branch
2. GitHub Actions automatically:
   - Increments patch version
   - Builds apps
   - Creates release
   - Uploads artifacts

### Manual
1. Use `make release-patch/minor/major` for controlled releases
2. Or use GitHub's workflow dispatch for custom version bumping

## 📱 Supported Platforms

- ✅ iOS (12.0+)
- ✅ Android (API level as configured)
- ✅ Web (Flutter web support)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Check formatting: `make format`
6. Submit a pull request

## 📄 License

This project is supported by RMAC (Richmond Multicultural Academy Collective).
