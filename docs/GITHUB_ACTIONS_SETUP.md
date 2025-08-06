# GitHub Actions Setup Guide

This guide will help you configure GitHub Actions secrets for automated deployment.

## 🔐 Required GitHub Secrets

To enable automated deployment via git tags, you need to configure these secrets in your GitHub repository:

### Navigation: Repository Settings → Secrets and Variables → Actions

## 📱 App Store Connect Secrets

### 1. `APP_STORE_CONNECT_API_KEY_ID`
Your App Store Connect API Key ID (e.g., `5GQ446J4X4`)

### 2. `APP_STORE_CONNECT_ISSUER_ID` 
Your App Store Connect Issuer ID (e.g., `7554bcb1-4a61-4c87-af77-a97d50fdba29`)

### 3. `APP_STORE_CONNECT_API_KEY`
Base64-encoded content of your `.p8` API key file

**To get the base64 value:**
```bash
base64 -i ~/path/to/AuthKey_XXXXXXXXXX.p8 | pbcopy
```

### 4. `FASTLANE_USER`
Your Apple ID email address (e.g., `your.email@example.com`)

### 5. `FASTLANE_PASSWORD`
Your Apple ID App-Specific Password

**To create an App-Specific Password:**
1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign In → Security → App-Specific Passwords
3. Generate a new password for "Fastlane CI/CD"

## 🔧 Optional Secrets

### 6. `APP_STORE_APP_ID` (Optional)
Your app's App Store Connect App ID for direct links in notifications

### 7. `SLACK_URL` (Optional) 
Slack webhook URL for deployment notifications

## 📋 Quick Setup Checklist

- [ ] Create App Store Connect API Key with "App Manager" role
- [ ] Add all 5 required secrets to GitHub repository
- [ ] Test the workflow by creating a git tag
- [ ] Verify builds appear in TestFlight/App Store Connect

## 🚀 Usage After Setup

Once secrets are configured, deployment is fully automated:

### For Production Releases:
```bash
# Create and push a version tag
make release-patch    # 1.0.0 → 1.0.1 → App Store
make release-minor    # 1.0.0 → 1.1.0 → App Store  
make release-major    # 1.0.0 → 2.0.0 → App Store
```

### For Beta/Testing:
```bash
# Create beta/alpha releases
make release-beta     # → TestFlight
make release-alpha    # → TestFlight
```

### Manual GitHub Actions Trigger:
1. Go to your repository's **Actions** tab
2. Select **iOS App Store Deployment**
3. Click **Run workflow**
4. Choose deployment type and add release notes

## 🔄 Deployment Flow

1. **Developer commits & tags** → `git tag v1.0.0 && git push --tags`
2. **GitHub Actions triggers** → Builds iOS app
3. **Automated upload** → TestFlight (beta) or App Store (production)
4. **GitHub Release created** → With IPA file attached
5. **Notifications sent** → Slack/email (if configured)

## 🧪 Testing the Setup

1. **Dry run locally:**
   ```bash
   make preview-release-patch
   ```

2. **Test with beta release:**
   ```bash
   make release-beta
   ```

3. **Check GitHub Actions logs** for any issues

## 🚨 Troubleshooting

### Common Issues:

**🔴 "Missing secrets" error:**
- Verify all required secrets are added to GitHub repository
- Check secret names match exactly (case-sensitive)

**🔴 "Certificate/Provisioning profile" error:**
- Ensure you have valid certificates installed locally
- Consider setting up Fastlane Match for team environments

**🔴 "Build number conflict" error:**
- This is handled automatically by incrementing build numbers
- Manual builds might cause conflicts

**🔴 "API key invalid" error:**
- Recreate App Store Connect API Key with "App Manager" role
- Re-encode the .p8 file to base64
- Verify the key hasn't expired

## 📞 Support

If you encounter issues:
1. Check GitHub Actions logs for detailed error messages
2. Verify your local environment works: `make deploy-testflight`
3. Test API connection: `cd ios && bundle exec fastlane test_api`

---

**Next Steps:** After setting up secrets, try a beta release to test the automation:
```bash
make release-beta
```
