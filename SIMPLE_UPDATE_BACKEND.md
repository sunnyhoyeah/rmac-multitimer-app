# Simple Static JSON Example for App Update System

## For Testing/Development

Create these JSON files on your web server or CDN:

### 1. iOS Version Check
**File**: `https://your-domain.com/rmac-ios-version.json`

```json
{
  "latest_version": "1.1.2",
  "minimum_version": "1.1.1",
  "force_update": false,
  "release_notes": "🎉 What's New in v1.1.2:\n\n• Enhanced timer precision\n• Improved haptic feedback\n• Performance optimizations\n• Bug fixes and stability improvements\n\nThank you for using RMAC MultiTimer!",
  "download_url": "https://apps.apple.com/app/rmac-multitimer/id1234567890"
}
```

### 2. Android Version Check
**File**: `https://your-domain.com/rmac-android-version.json`

```json
{
  "latest_version": "1.1.2",
  "minimum_version": "1.1.1",
  "force_update": false,
  "release_notes": "🎉 What's New in v1.1.2:\n\n• Enhanced timer precision\n• Improved haptic feedback\n• Performance optimizations\n• Bug fixes and stability improvements\n\nThank you for using RMAC MultiTimer!",
  "download_url": "https://play.google.com/store/apps/details?id=com.rmac.multitimer"
}
```

### 3. Force Update Example
When you need to force users to update (critical security fix, etc.):

```json
{
  "latest_version": "1.1.3",
  "minimum_version": "1.1.2",
  "force_update": true,
  "release_notes": "🚨 Critical Security Update\n\nThis update contains important security fixes. Please update immediately to continue using the app safely.",
  "download_url": "https://apps.apple.com/app/rmac-multitimer/id1234567890"
}
```

## Update AppUpdateManager Configuration

In `lib/app_update_manager.dart`, update these URLs:

```dart
class AppUpdateManager {
  static String get _updateCheckUrl {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'https://your-domain.com/rmac-ios-version.json';
    } else {
      return 'https://your-domain.com/rmac-android-version.json';
    }
  }
  
  static const String _iosAppStoreUrl = 'https://apps.apple.com/app/rmac-multitimer/id1234567890';
  static const String _androidPlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.rmac.multitimer';
  
  // ... rest of implementation
}
```

## Testing Scenarios

### Test 1: Optional Update Available
Set JSON to:
```json
{
  "latest_version": "1.1.2",
  "force_update": false
}
```
Expected: Shows update dialog with "Later" option

### Test 2: Force Update Required
Set JSON to:
```json
{
  "latest_version": "1.2.0",
  "force_update": true
}
```
Expected: Shows update dialog without "Later" option

### Test 3: No Update Needed
Set JSON to:
```json
{
  "latest_version": "1.1.0"
}
```
Expected: No dialog shown (current version = latest version)

## Deployment Process

1. **Create JSON files** with appropriate version info
2. **Upload to your web server** or CDN
3. **Update app code** with correct URLs
4. **Test thoroughly** with different scenarios
5. **Deploy new app version** with update system
6. **Monitor adoption** rates and user feedback

## Benefits of This Approach

✅ **Simple**: Just static JSON files, no backend required  
✅ **Fast**: CDN cached responses  
✅ **Reliable**: No database dependencies  
✅ **Flexible**: Easy to update version info instantly  
✅ **Cost-effective**: No server-side logic needed  

## Next Steps

1. Set up your web hosting/CDN
2. Create the JSON files
3. Update the URLs in AppUpdateManager
4. Test the update flow
5. Deploy with your next app version (v1.2.0)
