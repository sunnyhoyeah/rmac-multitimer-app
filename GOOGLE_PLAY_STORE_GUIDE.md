# Google Play Store Submission Guide

## Ready Files for Upload

✅ **App Bundle (AAB)**: `build/app/outputs/bundle/release/app-release.aab` (43.8MB)
✅ **Release APK**: `build/app/outputs/flutter-apk/app-release.apk` (25.3MB)
✅ **Version**: 1.0.55 (Build 57) - **New version code to resolve draft conflict**
✅ **Crash Fix Applied**: Code obfuscation disabled to prevent startup crashes

## Google Play Store Requirements

### 1. Store Listing Information
- **App Title**: RMAC - MULTI TIMER
- **Short Description**: Professional multi-timer app designed for track and field events by RMAC
- **Full Description**: Located in `android/fastlane/metadata/android/en-US/full_description.txt`
- **Package Name**: `com.rmac.multitimer`

### 2. App Category
- **Category**: Sports & Fitness
- **Content Rating**: Everyone

### 3. Screenshots Required
You need to take and upload screenshots:
- **Phone Screenshots**: 2-8 screenshots (1080x1920 or 1080x2340)
- **Feature Graphic**: 1024x500 PNG (optional but recommended)

### 4. Privacy Policy
You may need to provide a privacy policy URL if your app:
- Collects user data
- Uses permissions

### 5. App Permissions
Current permissions (automatically detected):
- No special permissions required

## Next Steps

1. **Create Google Play Console Account** ($25 one-time fee)
2. **Take Screenshots** of the app running
3. **Upload the AAB file** to Google Play Console
4. **Fill out store listing** with the provided metadata
5. **Submit for Review**

## Important Notes

✅ **The app is now properly signed with release keys** (suitable for Google Play Store)
✅ **Release certificate**: CN=RMAC MultiTimer, OU=Development, O=RMAC
✅ **Ready for Google Play Store submission**

## Testing the Build

The APK can be installed directly on Android devices for testing:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```
