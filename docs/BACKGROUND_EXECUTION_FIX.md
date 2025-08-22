# Background Execution and App Self-Closing Fix

## Problem
Users reported that the RMAC MultiTimer app closes itself after being idle for about 2 minutes. This is due to iOS background execution limits and missing app lifecycle management.

## Root Causes
1. **Missing Timer Cleanup**: The `_periodicTimer` in `_TimerRowState` was not being properly cancelled in the `dispose()` method, causing memory leaks and unexpected behavior.

2. **No App Lifecycle Management**: The app didn't handle iOS lifecycle changes (background/foreground transitions), so when iOS suspended the app, the timers would become inconsistent.

3. **Missing Background Modes**: The app lacked proper iOS background execution permissions.

## Solutions Implemented

### 1. Fixed Timer Memory Leaks
**File**: `lib/main.dart` - `_TimerRowState.dispose()`
- Added `_periodicTimer?.cancel()` to the dispose method to prevent memory leaks
- Ensures timers are properly cleaned up when widgets are destroyed

### 2. Added App Lifecycle Management
**File**: `lib/main.dart` - `_TimerListState`
- Implemented `WidgetsBindingObserver` to monitor app lifecycle changes
- Added lifecycle state handling:
  - `AppLifecycleState.paused`: Pause all running timers when app goes to background
  - `AppLifecycleState.resumed`: Resume all paused timers when app comes back to foreground
  - `AppLifecycleState.detached`: Stop all timers when app is terminated
  - `AppLifecycleState.hidden`: Treat like paused state

### 3. Added Timer Pause/Resume Functionality
**File**: `lib/main.dart` - `_TimerRowState`
- Implemented `pauseTimer()` method: Stops the Stopwatch and periodic timer without changing running state
- Implemented `resumeTimer()` method: Restarts the Stopwatch and periodic timer for seamless continuation
- These methods maintain timer accuracy across background/foreground transitions

### 4. Added iOS Background Modes
**File**: `ios/Runner/Info.plist`
- Added `UIBackgroundModes` with:
  - `background-processing`: Allows short background processing
  - `background-fetch`: Enables background refresh capabilities

### 5. Enhanced iOS AppDelegate
**File**: `ios/Runner/AppDelegate.swift`
- Added background fetch configuration
- Implemented background fetch handler to help keep app alive
- Requests minimum background fetch interval for better timer continuity

## Technical Details

### Timer State Management
The solution preserves timer accuracy by:
1. Using `Stopwatch` (which tracks elapsed time) rather than absolute timestamps
2. Pausing the stopwatch when backgrounded (preserves elapsed time)
3. Resuming the stopwatch when foregrounded (continues from where it left off)
4. Maintaining the `isRunning` state across lifecycle changes

### Background Execution Limits
iOS typically allows:
- **3 minutes** of background execution for apps in background
- **30 seconds to 2 minutes** for suspended apps (varies by system load)
- Apps can be terminated by iOS if they consume too many resources

The implemented solution:
- Pauses resource-intensive periodic timers when backgrounded
- Uses background modes to request extended execution time
- Gracefully handles app termination scenarios

### Memory Management
- All periodic timers are properly cancelled in dispose methods
- Lifecycle observer is properly removed when widgets are destroyed
- No memory leaks from running timers after widget disposal

## Expected Behavior After Fix

1. **Background Transition**: When app goes to background, timers pause but maintain their elapsed time
2. **Foreground Return**: When app returns to foreground, timers resume exactly where they left off
3. **No More Self-Closing**: App should no longer terminate unexpectedly after idle periods
4. **Accurate Timing**: Timer values remain accurate across background/foreground transitions
5. **Better Performance**: Reduced resource usage when app is not visible

## Testing Recommendations

1. **Manual Testing**:
   - Start timers
   - Put app in background for 2-5 minutes
   - Return to foreground and verify timers continue accurately

2. **Extended Testing**:
   - Test with multiple timers running
   - Test lap functionality across background transitions
   - Test timer reset/stop operations after background periods

3. **System Testing**:
   - Test under low memory conditions
   - Test with other apps running simultaneously
   - Test on different iOS versions and devices

## Notes

- iOS background execution is still limited by system policies
- Very long background periods (>10 minutes) may still result in app termination
- The solution balances timer accuracy with iOS system requirements
- Users should be aware that extremely long idle periods may still affect app state

This fix addresses the core issue while working within iOS's background execution constraints, providing a much better user experience for timer functionality.
