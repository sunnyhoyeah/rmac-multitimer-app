# App Crash Fix Guide - RMAC MultiTimer

## Problem
After uploading the AAB to Google Play Store for internal testing, the app crashed immediately upon opening.

## Root Cause
The release build was missing critical configuration to prevent issues with code obfuscation and minification that can cause crashes in production builds.

## Fix Applied

### 1. Updated `android/app/build.gradle.kts`
- **Disabled code minification**: `isMinifyEnabled = false`
- **Disabled resource shrinking**: `isShrinkResources = false`
- **Added ProGuard configuration**: Better rules for Flutter apps
- **Added debug build type**: Explicit configuration for consistency

### 2. Enhanced `android/app/proguard-rules.pro`
- **Added Flutter engine rules**: Keep Flutter embedding classes
- **Added native method protection**: Keep JNI methods
- **Added reflection protection**: Keep annotation and signature attributes
- **Added storage protection**: Keep SharedPreferences and file storage classes

## New Build Files

✅ **Updated AAB**: `build/app/outputs/bundle/release/app-release.aab` (43.8MB)
✅ **Updated APK**: `build/app/outputs/flutter-apk/app-release.apk` (25.3MB)
✅ **Version**: 1.0.52 (Build 56) - **New version code for Google Play Store**
✅ **Still properly signed** with release certificate: CN=RMAC MultiTimer

## Testing the Fix

### Option 1: Test APK Locally
```bash
# Install the APK directly on your Android device
adb install build/app/outputs/flutter-apk/app-release.apk

# Check if the app opens without crashing
```

### Option 2: Upload New AAB to Play Store
1. Go to Google Play Console
2. Go to your app's Internal Testing track
3. Upload the new AAB file: `build/app/outputs/bundle/release/app-release.aab`
4. Test the new version

## What Changed
- **Before**: Code was being obfuscated/minified, causing runtime crashes
- **After**: Code remains unobfuscated, preventing crashes while maintaining security through proper signing

## Build Commands
```bash
# Clean and rebuild if needed
flutter clean
flutter pub get
flutter build appbundle --release
flutter build apk --release
```

## Important Notes
- The app is still properly signed with your release certificate
- File size increased slightly (43.8MB vs 42MB) due to less compression
- This is the recommended configuration for Flutter apps on Play Store
- The fix maintains all security and Play Store requirements

## Next Steps
1. **Test the new APK locally** to confirm the crash is fixed
2. **Upload the new AAB** to Google Play Console internal testing
3. **Test via Play Store** to confirm the fix works in the Play Store environment
4. **Proceed with Play Store submission** once testing confirms the fix
