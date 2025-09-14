#!/bin/bash

# RMAC Multitimer - Enhanced Android Haptic Feedback Test Script
# This script helps test and debug haptic feedback issues on Android devices

echo "🔧 RMAC Multitimer - Android Haptic Debug Test"
echo "=============================================="

# Check if device is connected
echo "📱 Checking connected Android devices..."
flutter devices --android

echo ""
echo "🛠️ Building debug APK with verbose logging..."
flutter build apk --debug --verbose

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi

echo ""
echo "📲 Installing app on connected Android device..."
flutter install --debug

if [ $? -ne 0 ]; then
    echo "❌ Installation failed. Please check if device is connected and USB debugging is enabled."
    exit 1
fi

echo ""
echo "🔍 Starting app with debug logging..."
echo "💡 Tap the Start/Stop and Lap/Reset buttons to test haptic feedback."
echo "📊 Watch the debug output below for haptic feedback logs:"
echo ""

# Run the app and filter for haptic feedback logs
flutter run --debug --verbose | grep -E "(🔔|📱|🎛️|✅|❌|haptic|vibrat|Haptic|Vibrat)"

echo ""
echo "✅ Test completed. Review the debug output above for haptic feedback status."
echo ""
echo "🔧 Common troubleshooting steps:"
echo "1. Ensure 'Vibration' is enabled in device settings"
echo "2. Check 'Touch vibration' or 'Haptic feedback' in Accessibility settings"
echo "3. Try increasing system volume (some devices link vibration to volume)"
echo "4. Test on a different Android device if available"
echo "5. Check if the device has a physical vibrator motor"
