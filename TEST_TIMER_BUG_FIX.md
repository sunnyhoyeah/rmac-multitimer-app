# Timer Bug Fix Testing Guide

## Issue Description
When the app has more than 8 rows, after starting all timers and scrolling down then back up, the timers in the first 4 rows would either reset to 00:00:00 or stop at the time when they went off-screen.

## Secondary Issue (Fixed)
After the initial fix, timers were running too slowly (1/100 second became 1 second) due to incorrect time formatting.

## Root Cause
The issue was caused by dual timer management:
1. **TimerState objects** - persistent timer states meant to survive scrolling
2. **Individual TimerRow widgets** - each creating their own periodic timers that got cancelled during widget rebuilds

When scrolling occurred, the ListView would rebuild widgets, causing the TimerRow periodic timers to be cancelled while the TimerState objects persisted but were not being updated.

The secondary timing issue was caused by using hours:minutes:seconds format instead of the expected minutes:seconds:centiseconds format.

## Fix Applied
1. **Centralized Timer Management**: All timer logic moved to `_TimerListState`
2. **Persistent Timer States**: `TimerState` objects now handle all timer functionality
3. **Widget Delegation**: `TimerRow` widgets now only delegate timer actions to the parent
4. **Eliminated Dual Timers**: Removed separate periodic timers from individual `TimerRow` widgets
5. **Corrected Time Format**: Fixed `_formatTime` to use MM:SS:CC (minutes:seconds:centiseconds) instead of HH:MM:SS

## Testing Steps

### Manual Testing
1. **Setup**: Add 16+ rows using the + button
2. **Start All**: Press the "Start All" button (play arrow) in the header
3. **Verify Running**: All timers should start counting up
4. **Scroll Test**: 
   - Scroll down to see rows 8-16
   - Wait a few seconds
   - Scroll back up to see rows 1-8
5. **Expected Result**: All timers should continue running and show the correct elapsed time
6. **Previous Bug**: Timers in first 4 rows would show 00:00:00 or freeze

### Automated Verification
The fix ensures:
- ✅ Timer states persist across scrolling
- ✅ No timer cancellation during widget rebuilds
- ✅ Centralized timer management prevents state inconsistencies
- ✅ UI updates continue even for off-screen timers

### Code Changes Summary
- **TimerState**: Added persistent timer objects with unique IDs
- **_TimerListState**: Centralized all timer control methods
- **TimerRow**: Converted to pure UI component that delegates to parent
- **Key Management**: Proper widget keys to maintain state during scrolling

## Verification Results
- ✅ Build successful
- ✅ App launches without errors
- ✅ Timer state persistence verified
- ✅ Scrolling behavior fixed
