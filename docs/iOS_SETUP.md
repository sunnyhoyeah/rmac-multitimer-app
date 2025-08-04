# iOS Device Connection & Distribution Setup

This document explains how to set up iPhone connectivity and automated distribution for the RMAC MultiTimer app.

## 🔧 Prerequisites

### Required Tools
```bash
# Install required tools
brew install libimobiledevice ios-deploy
npm install -g ios-deploy
```

### Apple Developer Account
- Apple Developer Account ($99/year)
- App Store Connect access
- iOS Development/Distribution certificates
- Provisioning profiles

## 📱 iPhone Connection Setup

### 1. Physical Connection
1. Connect iPhone via USB cable (Lightning or USB-C)
2. Unlock iPhone and tap "Trust This Computer"
3. Verify connection: `make iphone-list`

### 2. Development Certificate
1. Open Xcode
2. Go to Xcode → Preferences → Accounts
3. Add your Apple ID
4. Download Development Certificates

### 3. Provisioning Profile
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Create App ID: `com.rmac.multitimer`
3. Register your iPhone's UDID
4. Create Development Provisioning Profile

## 🚀 Automated Distribution Setup

### GitHub Secrets Required

Add these secrets to your GitHub repository settings:

```bash
# Code Signing
IOS_DIST_SIGNING_KEY              # Base64 encoded .p12 file
IOS_DIST_SIGNING_KEY_PASSWORD     # Password for .p12 file
APPLE_TEAM_ID                     # Your Apple Team ID

# App Store Connect API
APPSTORE_ISSUER_ID               # App Store Connect API Issuer ID  
APPSTORE_KEY_ID                  # App Store Connect API Key ID
APPSTORE_PRIVATE_KEY             # App Store Connect API Private Key
```

### Setting up App Store Connect API

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Users and Access → Keys
3. Create new API Key with "Developer" role
4. Download the private key (.p8 file)
5. Note the Key ID and Issuer ID

### Creating Certificates

```bash
# Generate Certificate Signing Request (CSR)
openssl req -new -newkey rsa:2048 -nodes -keyout ios_distribution.key -out ios_distribution.csr

# After downloading certificate from Apple Developer Portal
# Convert to .p12 format
openssl pkcs12 -export -out ios_distribution.p12 -inkey ios_distribution.key -in ios_distribution.cer

# Encode to base64 for GitHub Secrets
base64 -i ios_distribution.p12 | pbcopy
```

## 📲 Usage Commands

### Local Development
```bash
# List connected devices
make iphone-list

# Install app to connected iPhone
make iphone-install

# Run tests on device
make iphone-test

# Integration testing
make test-integration
```

### Automated Distribution
```bash
# Trigger TestFlight deployment
make testflight

# Or use GitHub CLI
gh workflow run ios-device-distribution.yml \
  --field distribution_type=testflight \
  --field version_bump=patch
```

## 🔄 Automation Workflows

### 1. Development Workflow
1. Connect iPhone via USB
2. Run `make iphone-install` to install latest version
3. Test manually on device
4. Run `make iphone-test` for automated testing

### 2. TestFlight Workflow
1. Push code to main branch
2. GitHub Actions automatically builds and uploads to TestFlight
3. TestFlight processes the build (usually 1-10 minutes)
4. Distribute to internal testers

### 3. App Store Workflow
1. Create release candidate via TestFlight
2. Submit for App Store review
3. After approval, release to App Store

## 🛠️ Troubleshooting

### iPhone Not Detected
```bash
# Check USB connection
system_profiler SPUSBDataType | grep iPhone

# Reset iOS debugging
sudo xcode-select --install
sudo xcode-select --reset

# Trust computer again
# Disconnect → Reconnect iPhone
# Unlock iPhone → Trust Computer
```

### Build Errors
```bash
# Clean build
flutter clean
cd ios && pod install --repo-update && cd ..
flutter pub get

# Reset iOS build
rm -rf ios/build
rm -rf build/ios
```

### Certificate Issues
```bash
# List available certificates
security find-identity -v -p codesigning

# Import certificate
security import ios_distribution.p12 -k ~/Library/Keychains/login.keychain
```

## 📊 Device Testing Matrix

| Device | iOS Version | Test Status |
|--------|-------------|-------------|
| iPhone 12 | iOS 16.0+ | ✅ Supported |
| iPhone 13 | iOS 17.0+ | ✅ Supported |
| iPhone 14 | iOS 17.0+ | ✅ Supported |
| iPhone 15 | iOS 17.0+ | ✅ Supported |

## 🔐 Security Notes

- Never commit certificates or private keys to Git
- Use GitHub Secrets for sensitive data
- Rotate API keys regularly
- Use environment-specific provisioning profiles

## 📞 Support

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/deployment/deploying-to-your-cloud-provider/deploying-to-apple-app-store)
