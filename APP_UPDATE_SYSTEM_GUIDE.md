# App Update System Implementation Guide

## Overview
This guide explains how to implement the force update/app update checking system for RMAC MultiTimer.

## Backend API Requirements

### 1. Version Check Endpoint

Create an API endpoint that returns version information:

**Endpoint**: `GET https://your-api.com/api/app-version-check`

**Query Parameters**:
- `platform`: `ios` or `android`
- `current_version`: Current app version (e.g., `1.1.0`)

**Response Format**:
```json
{
  "latest_version": "1.2.0",
  "minimum_version": "1.1.0",
  "force_update": false,
  "release_notes": "• Added new timer features\n• Improved performance\n• Bug fixes",
  "download_url": "https://apps.apple.com/app/your-app",
  "update_available": true
}
```

### 2. Simple Implementation Options

#### Option A: Static JSON File (Simple)
Host a simple JSON file on your web server:

**ios-version.json**:
```json
{
  "latest_version": "1.2.0",
  "minimum_version": "1.1.0",
  "force_update": false,
  "release_notes": "• Enhanced haptic feedback\n• Performance improvements\n• Bug fixes",
  "download_url": "https://apps.apple.com/app/rmac-multitimer"
}
```

**android-version.json**:
```json
{
  "latest_version": "1.2.0",
  "minimum_version": "1.1.0",
  "force_update": false,
  "release_notes": "• Enhanced haptic feedback\n• Performance improvements\n• Bug fixes",
  "download_url": "https://play.google.com/store/apps/details?id=com.rmac.multitimer"
}
```

#### Option B: Firebase Remote Config (Recommended)
Use Firebase Remote Config for easy management without deploying a backend.

#### Option C: Simple PHP/Node.js API
Basic server-side script to return version information.

## Integration in Flutter App

### 1. Add to main.dart

```dart
import 'app_update_manager.dart';

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // Check for updates after app initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }
  
  void _checkForUpdates() async {
    // Wait a bit to let the app fully load
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      // Check for updates - don't show "no update" dialog automatically
      AppUpdateManager.checkForUpdates(context, showNoUpdateDialog: false);
    }
  }
  
  // ... rest of your MyApp implementation
}
```

### 2. Manual Update Check (Optional)

Add a menu item or button to manually check for updates:

```dart
// In your settings screen or menu
ElevatedButton(
  onPressed: () {
    AppUpdateManager.checkForUpdates(context, showNoUpdateDialog: true);
  },
  child: Text('Check for Updates'),
),
```

## Update Scenarios

### 1. Optional Update (force_update: false)
- User can dismiss the dialog
- App continues to work normally
- Good for feature updates

### 2. Force Update (force_update: true)
- User cannot dismiss the dialog
- App requires update to continue
- Good for critical security updates or breaking changes

### 3. Minimum Version Check
- If user's version is below minimum_version, force update
- Useful for deprecating old versions

## Implementation Steps

### Phase 1: Basic Setup (Next Release - v1.2.0)
1. ✅ Add dependencies to pubspec.yaml
2. ✅ Create AppUpdateManager class
3. 🔄 Set up simple static JSON endpoint
4. 🔄 Integrate update check in app startup
5. 🔄 Test with different version scenarios

### Phase 2: Enhanced Features (v1.3.0)
1. Add Firebase Remote Config for easier management
2. Implement update frequency controls (daily/weekly checks)
3. Add update analytics tracking
4. Implement silent updates for non-critical updates

### Phase 3: Advanced Features (v1.4.0)
1. In-app update support (Android)
2. Changelog display improvements
3. Update scheduling (install on next restart)
4. A/B testing for update prompts

## Testing Strategy

### 1. Version Testing Matrix
Test with these scenarios:
- Current: 1.1.0, Latest: 1.2.0, Force: false → Show optional update
- Current: 1.0.0, Latest: 1.2.0, Force: true → Show force update
- Current: 1.2.0, Latest: 1.2.0 → No update needed

### 2. Mock API Responses
Create test endpoints that return different version scenarios for testing.

### 3. Test on Different Platforms
- iOS: Test App Store redirect
- Android: Test Play Store redirect

## Configuration Example

Update the AppUpdateManager with your actual URLs:

```dart
class AppUpdateManager {
  // Update these URLs with your actual endpoints
  static const String _updateCheckUrl = 'https://your-domain.com/api/version-check';
  static const String _iosAppStoreUrl = 'https://apps.apple.com/app/id1234567890';
  static const String _androidPlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.rmac.multitimer';
  
  // ... rest of implementation
}
```

## Benefits

1. **User Retention**: Ensure users have latest features
2. **Security**: Force critical security updates
3. **Support**: Reduce support burden from old versions
4. **Analytics**: Track adoption rates of new versions
5. **Control**: Gradually roll out updates or halt problematic versions

## Next Steps

1. Deploy the update system in v1.2.0
2. Create version check endpoints
3. Test thoroughly before App Store/Play Store submission
4. Monitor update adoption rates
5. Iterate based on user feedback
