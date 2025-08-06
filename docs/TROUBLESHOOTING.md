# App Store Connect API Troubleshooting Guide

## Common Issues and Solutions

### 1. "App Store Connect API connection failed"

This error can occur for several reasons:

#### Check Your Credentials

1. **API Key ID**: Verify this matches exactly with your App Store Connect API key
   - Go to [App Store Connect API](https://appstoreconnect.apple.com/access/api)
   - Check the Key ID of your API key

2. **Issuer ID**: This should be your team's issuer ID
   - Found on the same API page, at the top right

3. **API Key File**: Ensure the .p8 file is valid
   - The file should start with `-----BEGIN PRIVATE KEY-----`
   - The file should end with `-----END PRIVATE KEY-----`

#### Check API Key Permissions

Your API key needs the following permissions:
- **App Manager** or **Admin** role
- Access to the specific app you're trying to deploy

#### Check Apple Developer Account Status

1. Ensure your Apple Developer account is active
2. Verify you have access to the app identifier
3. Check that your account hasn't been suspended

### 2. Base64 Encoding Issues

If you're getting decoding errors:

```bash
# Test if your base64 encoding is correct
echo "YOUR_BASE64_STRING" | base64 --decode
```

### 3. Environment Variables Not Set

Ensure all required variables are exported:

```bash
# Check if variables are set
echo $FASTLANE_USER
echo $APP_STORE_CONNECT_API_KEY_ID
echo $APP_STORE_CONNECT_ISSUER_ID
# Don't echo the password or API key for security
```

### 4. Fastlane Gem Issues

Update Fastlane to the latest version:

```bash
cd ios
bundle update fastlane
```

### 5. Network Issues

If you're behind a corporate firewall:
- Ensure access to `api.appstoreconnect.apple.com`
- Check proxy settings

### 6. Testing the Setup

You can test individual components:

1. **Test API key file**:
   ```bash
   cd ios
   bundle exec fastlane run app_store_connect_api_key \
     key_id:"YOUR_KEY_ID" \
     issuer_id:"YOUR_ISSUER_ID" \
     key_filepath:"path/to/AuthKey_KEYID.p8"
   ```

2. **Test full setup**:
   ```bash
   source ~/.appstore_connect_env
   cd ios
   bundle exec fastlane test_api
   ```

### 7. Manual Verification

You can manually verify your setup:

1. Create a test .p8 file:
   ```bash
   echo "YOUR_BASE64_API_KEY" | base64 --decode > test_key.p8
   ```

2. Check the file content:
   ```bash
   cat test_key.p8
   ```

3. Clean up:
   ```bash
   rm test_key.p8
   ```

## Getting Help

If you're still having issues:

1. Check the [Fastlane documentation](https://docs.fastlane.tools/app-store-connect-api/)
2. Review [Apple's API documentation](https://developer.apple.com/documentation/appstoreconnectapi)
3. Check the error logs in detail

## Security Notes

- Never commit API keys to version control
- Rotate API keys regularly
- Use app-specific passwords, not your main Apple ID password
- Store sensitive data in environment variables or secure vaults
