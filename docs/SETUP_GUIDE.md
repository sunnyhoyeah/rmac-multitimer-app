# App Store Connect Setup - Quick Start Guide

## What Was Fixed

The setup script had several issues that have been resolved:

### 1. **Improved API Connection Testing**
- Updated the test method to use a custom Fastlane lane
- Better error reporting and troubleshooting tips
- More reliable connection validation

### 2. **Enhanced Fastfile Configuration**
- Added proper API key handling with Base64 decoding
- Created a dedicated `test_api` lane for connection testing
- Improved cleanup and error handling

### 3. **Better Error Messages**
- More descriptive error outputs
- Common troubleshooting tips included in error messages
- Clearer success/failure indicators

## How to Run the Setup

### Option 1: Direct Script Execution
```bash
# Navigate to your project directory
cd /Users/sunkwongyu/RMAC_MULTITIMER

# Make executable and run
chmod +x scripts/setup_appstore_env.sh
./scripts/setup_appstore_env.sh
```

### Option 2: Using the Makefile
```bash
# If you have make commands set up
make setup-appstore
```

### Option 3: Using the Helper Script
```bash
# Use the simple runner script
chmod +x run_setup.sh
./run_setup.sh
```

## What the Script Does

1. **Checks existing environment variables**
2. **Provides setup instructions** for:
   - Apple Developer account requirements
   - App Store Connect API key creation
   - App-specific password generation
3. **Interactively collects credentials** if not already set
4. **Generates a shell configuration file** (`~/.appstore_connect_env`)
5. **Tests the API connection** using Fastlane
6. **Provides next steps** for deployment

## After Setup

Once the setup is successful, you can:

```bash
# Deploy to TestFlight
make deploy-testflight

# Deploy to App Store
make deploy-appstore

# Or source the environment and use Fastlane directly
source ~/.appstore_connect_env
cd ios
bundle exec fastlane deploy_testflight
```

## If the Test Still Fails

1. Check the new troubleshooting guide: `docs/TROUBLESHOOTING.md`
2. Verify your API key has the correct permissions
3. Ensure your Apple Developer account is active
4. Try the manual verification steps in the troubleshooting guide

## Security Notes

- The script stores credentials in `~/.appstore_connect_env`
- API keys are base64 encoded for storage
- Temporary files are automatically cleaned up
- Never commit the environment file to version control
