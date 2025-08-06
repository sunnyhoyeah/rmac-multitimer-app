# iOS Code Signing & Certificate Setup Guide

## Overview

iOS app deployment requires valid certificates and provisioning profiles. There are two main approaches:

## Option 1: Manual Certificate Management (Simpler)

### Prerequisites
- Valid Apple Developer account
- Xcode installed and configured with your Apple ID

### Steps
1. **Open Xcode**
2. **Go to Preferences > Accounts**
3. **Add your Apple ID** if not already added
4. **Select your team** and click "Manage Certificates"
5. **Create certificates** if needed:
   - iOS Development (for testing)
   - iOS Distribution (for App Store)

### Verification
```bash
# Check if you have valid certificates
security find-identity -v -p codesigning

# Should show certificates like:
# 1) ABC123... "Apple Distribution: Your Name (TEAM_ID)"
# 2) DEF456... "Apple Development: Your Name (TEAM_ID)"
```

## Option 2: Automated Certificate Management with Match (Recommended for Teams)

### What is Match?
Fastlane Match stores your certificates and provisioning profiles in a private Git repository, making it easy to share them across your team and CI/CD systems.

### Setup Steps

#### 1. Create a Private Git Repository
Create a new **private** repository (GitHub, GitLab, etc.) for storing certificates:
```
Repository name: ios-certificates (or similar)
Visibility: Private (IMPORTANT!)
```

#### 2. Initialize Match
```bash
cd ios
bundle exec fastlane match init
```

You'll be prompted for:
- Git URL of your certificates repository
- Passphrase for encrypting certificates (store this securely!)

#### 3. Generate Certificates
```bash
# Generate development certificates
bundle exec fastlane match development

# Generate App Store certificates
bundle exec fastlane match appstore
```

#### 4. Update Matchfile
Edit `ios/fastlane/Matchfile`:
```ruby
git_url("https://github.com/yourusername/ios-certificates.git")
storage_mode("git")
type("development") # The default type, can be: appstore, adhoc, development, enterprise
app_identifier(["com.rmac.multitimer"])
username("your-apple-id@example.com")
```

## Current Project Status

The RMAC MultiTimer project is currently configured to work **without** Match setup. The deployment lanes will:

1. ✅ **Try to use Match** if configured
2. ✅ **Fall back gracefully** if Match isn't available
3. ✅ **Use manual certificates** from Xcode if available

## Testing Your Setup

### Test API Connection Only
```bash
source ~/.appstore_connect_env
cd ios
bundle exec fastlane test_api
```

### Test Local Build (No Upload)
```bash
source ~/.appstore_connect_env
cd ios
bundle exec fastlane test_build
```

### Test Full Deployment
```bash
source ~/.appstore_connect_env
cd ios
bundle exec fastlane deploy_testflight
```

## Common Issues & Solutions

### Issue: "No signing identity found"
**Solution**: Install certificates in Xcode or setup Match

### Issue: "No provisioning profiles found"
**Solution**: 
1. Open your project in Xcode
2. Select your target
3. Go to Signing & Capabilities
4. Ensure "Automatically manage signing" is checked
5. Select your development team

### Issue: "match git repo access denied"
**Solution**: 
1. Ensure the git repository is accessible
2. Check your git credentials
3. Verify the repository URL in Matchfile

## Security Best Practices

1. **Never commit certificates** to your main project repository
2. **Use a separate private repository** for Match
3. **Store the Match passphrase securely** (password manager, CI secrets)
4. **Rotate certificates regularly** (annually)
5. **Use app-specific passwords** for Apple ID authentication

## Next Steps

1. **For immediate deployment**: Use manual certificates (Option 1)
2. **For team/CI setup**: Implement Match (Option 2)
3. **Test the setup** with the provided test commands

The current configuration will work with either approach!
