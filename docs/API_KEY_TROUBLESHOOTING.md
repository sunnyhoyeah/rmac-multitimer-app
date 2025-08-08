# GitHub Secrets Configuration Guide for App Store Connect API

## Problem
The deployment is failing with error: `Failed to configure API key: invalid curve name`

This error occurs when the App Store Connect API key configuration in GitHub Secrets is incorrect.

## Root Cause Analysis

The test script (`test_api_key.rb`) confirms that both API key files in the repository are valid:
- `AuthKey_5GQ446J4X4.p8` ✅ Valid PKCS#8 format
- `AuthKey_LX4RW29VFH.p8` ✅ Valid PKCS#8 format

The issue is with the GitHub Secrets configuration.

## Required GitHub Secrets

You need to configure exactly these 3 secrets in your GitHub repository:

### 1. `APP_STORE_CONNECT_API_KEY_ID`
**Value:** Must be one of these exact values:
- `5GQ446J4X4` (for AuthKey_5GQ446J4X4.p8)
- `LX4RW29VFH` (for AuthKey_LX4RW29VFH.p8)

### 2. `APP_STORE_CONNECT_ISSUER_ID`
**Value:** Your App Store Connect issuer ID (looks like: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
- Find this in App Store Connect → Users and Access → Keys → App Store Connect API

### 3. `APP_STORE_CONNECT_API_KEY`
**Value:** Base64 encoded content of the corresponding API key file

#### For Key ID `5GQ446J4X4` (UPDATED - 2025-08-08):
```
LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZ1N2cEhsS1BLdmd6UTB6UjcKZCtlT0x2NTV6ZTB0dWEyOWk3V01hYndHSjZ1Z0NnWUlLb1pJemowREFRZWhSQU5DQUFSblpOV0s5WHhEbys2YwpRdGloSnZTb1o1dUlqY2QwaS9oODBnSDV2UkhsNGdramF6QkttQ3pTTWRuRHMyaE13MDBSbk1RVFhyVjByTEFlCkNlZUxYMXpjCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=
```

> **⚠️ IMPORTANT**: This is the corrected base64 string generated on August 8, 2025. If the deployment still fails with "invalid private key format", you need to update your GitHub Secret `APP_STORE_CONNECT_API_KEY` with this exact value.

#### For Key ID `LX4RW29VFH`:
```
LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZ1VEajZpU3ZQbTJySzBSeEMKVFVyYnUzWUMxK29pakJnU0d1VzZuSkVsZmtLZ0NnWUlLb1pJemowREFRZWhSQU5DQUFRT1ZVRWc0WEFNbHdWYwo2Rnd5WHh6TmxyUEsxeXMvQzJPSXFxRDZsRExjUjJtakg5MTlvS0ZHUzQ2ZHUwNHBlaFNCT3VRTklMWUlnTDlICjdqRXJCbFdyCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=
```

## How to Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each secret
4. Enter the exact names and values above

## Verification Steps

After configuring the secrets, the enhanced error handling will show:
- Which Key ID is being used
- File validation results  
- More specific error messages

## Testing Locally

You can test the API key configuration locally by running:
```bash
cd ios
export APP_STORE_CONNECT_API_KEY_ID="5GQ446J4X4"  # or LX4RW29VFH
export APP_STORE_CONNECT_ISSUER_ID="your-issuer-id"
export APP_STORE_CONNECT_API_KEY="base64-content-from-above"
bundle exec fastlane test_api_key
```

## Common Issues

1. **Wrong Key ID**: Ensure the ID matches exactly (case-sensitive)
2. **Corrupted Base64**: Copy the entire base64 string without line breaks
3. **Wrong Issuer ID**: Must match your App Store Connect account
4. **Extra Spaces**: GitHub Secrets should not have leading/trailing spaces

## Next Steps

1. Configure the 3 GitHub Secrets with the exact values above
2. Trigger a new deployment with `make release-patch`
3. Monitor the workflow logs for improved error messages
4. If still failing, run the `test_api_key` lane locally first
