import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'app_update_manager.dart';

/// Comprehensive haptic feedback function with multiple fallbacks for Android compatibility
Future<void> performHapticFeedback() async {
  if (kDebugMode) {
    print('🔔 Attempting haptic feedback on ${defaultTargetPlatform}');
  }
  
  try {
    // Method 1: For Android, use the vibration plugin first (most reliable)
    if (defaultTargetPlatform == TargetPlatform.android) {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (kDebugMode) print('📱 Device has vibrator: $hasVibrator');
      
      if (hasVibrator == true) {
        try {
          // Check if amplitude control is supported
          bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();
          if (kDebugMode) print('🎛️ Amplitude control support: $hasAmplitudeControl');
          
          if (hasAmplitudeControl == true) {
            // Use amplitude-controlled vibration
            await Vibration.vibrate(duration: 100, amplitude: 128);
            if (kDebugMode) print('✅ Amplitude vibration succeeded');
            return;
          } else {
            // Fallback to simple vibration
            await Vibration.vibrate(duration: 100);
            if (kDebugMode) print('✅ Simple vibration succeeded');
            return;
          }
        } catch (e) {
          if (kDebugMode) print('❌ Vibration plugin failed: $e');
          // Continue to next method
        }
      } else {
        if (kDebugMode) print('❌ No vibrator available on device');
      }
    }
    
    // Method 2: Try Flutter's built-in haptic feedback (iOS and Android fallback)
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await HapticFeedback.mediumImpact();
      if (kDebugMode) print('✅ iOS haptic feedback succeeded');
      return;
    }
    
    // Method 3: For Android fallback, try Flutter's haptic feedback
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await HapticFeedback.mediumImpact();
        if (kDebugMode) print('✅ Android Flutter mediumImpact succeeded');
        return;
      } catch (e1) {
        if (kDebugMode) print('❌ mediumImpact failed: $e1');
        try {
          await HapticFeedback.lightImpact();
          if (kDebugMode) print('✅ Android lightImpact succeeded');
          return;
        } catch (e2) {
          if (kDebugMode) print('❌ lightImpact failed: $e2');
          try {
            await HapticFeedback.heavyImpact();
            if (kDebugMode) print('✅ Android heavyImpact succeeded');
            return;
          } catch (e3) {
            if (kDebugMode) print('❌ heavyImpact failed: $e3');
            try {
              await HapticFeedback.selectionClick();
              if (kDebugMode) print('✅ Android selectionClick succeeded');
              return;
            } catch (e4) {
              if (kDebugMode) print('❌ selectionClick failed: $e4');
              // Method 4: Manual vibration using platform channel
              await _manualVibration();
            }
          }
        }
      }
    }
  } catch (e) {
    // If all methods fail, print debug info but don't crash
    if (kDebugMode) {
      print('❌ All haptic feedback methods failed: $e');
    }
  }
}

/// Manual vibration using platform channel as ultimate fallback
Future<void> _manualVibration() async {
  try {
    if (kDebugMode) print('🔧 Attempting manual vibration via platform channel');
    const platform = MethodChannel('flutter/haptic_feedback');
    await platform.invokeMethod('vibrate', {'duration': 50});
    if (kDebugMode) print('✅ Manual vibration succeeded');
  } catch (e) {
    if (kDebugMode) {
      print('❌ Manual vibration failed: $e');
    }
  }
}

/// Test method to specifically debug haptic feedback issues
Future<void> testAllHapticMethods() async {
  if (kDebugMode) {
    print('🧪 HAPTIC TEST: Starting comprehensive haptic feedback test');
    print('📱 Platform: ${defaultTargetPlatform}');
  }
  
  // Test 1: Vibration plugin - hasVibrator check
  try {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (kDebugMode) print('🧪 TEST 1 - hasVibrator(): $hasVibrator');
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 1 - hasVibrator() ERROR: $e');
  }
  
  // Test 2: Vibration plugin - amplitude control check
  try {
    bool? hasAmplitudeControl = await Vibration.hasAmplitudeControl();
    if (kDebugMode) print('🧪 TEST 2 - hasAmplitudeControl(): $hasAmplitudeControl');
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 2 - hasAmplitudeControl() ERROR: $e');
  }
  
  // Test 3: Simple vibration
  try {
    await Vibration.vibrate(duration: 100);
    if (kDebugMode) print('🧪 TEST 3 - Simple vibrate(100ms): SUCCESS');
    await Future.delayed(Duration(milliseconds: 200));
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 3 - Simple vibrate(100ms) ERROR: $e');
  }
  
  // Test 4: Amplitude vibration (if supported)
  try {
    await Vibration.vibrate(duration: 100, amplitude: 128);
    if (kDebugMode) print('🧪 TEST 4 - Amplitude vibrate(100ms, 128): SUCCESS');
    await Future.delayed(Duration(milliseconds: 200));
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 4 - Amplitude vibrate(100ms, 128) ERROR: $e');
  }
  
  // Test 5: Flutter's HapticFeedback.mediumImpact
  try {
    await HapticFeedback.mediumImpact();
    if (kDebugMode) print('🧪 TEST 5 - HapticFeedback.mediumImpact(): SUCCESS');
    await Future.delayed(Duration(milliseconds: 200));
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 5 - HapticFeedback.mediumImpact() ERROR: $e');
  }
  
  // Test 6: Flutter's HapticFeedback.lightImpact
  try {
    await HapticFeedback.lightImpact();
    if (kDebugMode) print('🧪 TEST 6 - HapticFeedback.lightImpact(): SUCCESS');
    await Future.delayed(Duration(milliseconds: 200));
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 6 - HapticFeedback.lightImpact() ERROR: $e');
  }
  
  // Test 7: Flutter's HapticFeedback.heavyImpact
  try {
    await HapticFeedback.heavyImpact();
    if (kDebugMode) print('🧪 TEST 7 - HapticFeedback.heavyImpact(): SUCCESS');
    await Future.delayed(Duration(milliseconds: 200));
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 7 - HapticFeedback.heavyImpact() ERROR: $e');
  }
  
  // Test 8: Flutter's HapticFeedback.selectionClick
  try {
    await HapticFeedback.selectionClick();
    if (kDebugMode) print('🧪 TEST 8 - HapticFeedback.selectionClick(): SUCCESS');
    await Future.delayed(Duration(milliseconds: 200));
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 8 - HapticFeedback.selectionClick() ERROR: $e');
  }
  
  // Test 9: Manual platform channel
  try {
    const platform = MethodChannel('flutter/haptic_feedback');
    await platform.invokeMethod('vibrate', {'duration': 50});
    if (kDebugMode) print('🧪 TEST 9 - Manual platform channel: SUCCESS');
  } catch (e) {
    if (kDebugMode) print('🧪 TEST 9 - Manual platform channel ERROR: $e');
  }
  
  if (kDebugMode) {
    print('🧪 HAPTIC TEST: Complete! Check above for working methods.');
    print('💡 If no tests show SUCCESS, the device may not support vibration.');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const List<String> quotes = [
    //"改變",
    "靜待這一秒世界改變，抑或把握這一秒走遍世界",
  ];

  late String randomQuote;

  @override
  void initState() {
    super.initState();
    randomQuote = quotes[Random().nextInt(quotes.length)];
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TimerList()),
      );
      
      // Check for app updates after navigating to main screen
      _checkForUpdates();
    });
  }
  
  void _checkForUpdates() async {
    // Wait a bit for the main screen to load
    await Future.delayed(Duration(seconds: 3));
    
    if (mounted) {
      try {
        // Check for updates silently (don't show "no update" dialog)
        AppUpdateManager.checkForUpdates(context, showNoUpdateDialog: false);
      } catch (e) {
        if (kDebugMode) {
          print('Update check failed: $e');
        }
        // Silently fail - don't interrupt user experience
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/rmac_timer.jpeg'),
                    SizedBox(height: 24),
                    Text(
                      'RMAC - MULTI TIMER',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        randomQuote,
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 32),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerList extends StatefulWidget {
  @override
  _TimerListState createState() => _TimerListState();
}

// Timer state class to persist timer data across widget rebuilds
class TimerState {
  final String id;
  Timer? periodicTimer;
  bool isRunning = false;
  Stopwatch lapStopwatch = Stopwatch();
  String currentLapTimeValue = '00:00:00';
  int currentLapNumber = 1;
  Stopwatch stopwatch = Stopwatch();
  String timerValue = '00:00:00';
  String previousTime = '00:00:00';
  List<LapEntry> lapEntries = [];
  int lapNumber = 0;

  TimerState(this.id);

  void dispose() {
    periodicTimer?.cancel();
    periodicTimer = null;
    stopwatch.stop();
    lapStopwatch.stop();
  }
}

class _TimerListState extends State<TimerList> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<String> runnerNames = ['Runner 1', 'Runner 2', 'Runner 3'];
  late List<GlobalKey<_TimerRowState>> rowKeys;
  
  // NEW: Persistent timer states that survive scrolling
  Map<String, TimerState> timerStates = {};
  
  int? pendingDeleteIndex;
  
  // Sliding page functionality
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  bool _isSlidePageVisible = false;
  
  // Pace calculation variables
  double _paceValue = 5.0; // Pace in minutes (e.g., 5.5 = 5:30)
  bool _isEditingPace = false;
  late TextEditingController _paceController;
  late FocusNode _paceFocusNode;
  
  // Controllers and state for editable distance times
  Map<String, TextEditingController> _distanceControllers = {};
  String? _editingDistance;
  DateTime? _lastDragTime;
  DateTime? _lastHapticTime;

  @override
  void initState() {
    super.initState();
    rowKeys = List.generate(
      runnerNames.length,
      (_) => GlobalKey<_TimerRowState>(),
    );
    // Initialize timer states for each runner
    _initializeTimerStates();
    loadRunnerNames();
    
    // Initialize pace editing controllers
    _paceController = TextEditingController(text: _formatPaceDisplay(_paceValue));
    _paceFocusNode = FocusNode();
    _paceFocusNode.addListener(() {
      if (!_paceFocusNode.hasFocus && _isEditingPace) {
        _finishEditingPace();
      }
    });
    
    // Initialize distance time controllers
    final distances = ['400m', '550m', '800m', '1200m', '1400m', '1600m', '3km', '5km', '10km', 'Half', 'Full'];
    for (String distance in distances) {
      _distanceControllers[distance] = TextEditingController();
    }
    
    // Initialize slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _initializeTimerStates() {
    for (int i = 0; i < runnerNames.length; i++) {
      String uniqueId = 'timer_${i}_${runnerNames[i]}';
      if (!timerStates.containsKey(uniqueId)) {
        timerStates[uniqueId] = TimerState(uniqueId);
      }
    }
  }
  
  String _getTimerStateId(int index) {
    return 'timer_${index}_${runnerNames[index]}';
  }

  TimerState _getTimerState(int index) {
    String timerId = _getTimerStateId(index);
    if (!timerStates.containsKey(timerId)) {
      timerStates[timerId] = TimerState(timerId);
    }
    return timerStates[timerId]!;
  }

  void _remapTimerStatesAfterReorder() {
    // Create a new map with updated timer state IDs based on current order
    Map<String, TimerState> newTimerStates = {};
    
    // For each runner in the current order, find their timer state by runner name
    for (int i = 0; i < runnerNames.length; i++) {
      String runnerName = runnerNames[i];
      String newTimerId = _getTimerStateId(i);
      
      // Find existing timer state for this runner (search by runner name)
      TimerState? existingState;
      for (var entry in timerStates.entries) {
        if (entry.key.endsWith('_$runnerName')) {
          existingState = entry.value;
          break;
        }
      }
      
      // If found, use existing state; otherwise create new one
      if (existingState != null) {
        newTimerStates[newTimerId] = existingState;
      } else {
        newTimerStates[newTimerId] = TimerState(newTimerId);
      }
    }
    
    // Dispose old timer states that are no longer used
    for (var entry in timerStates.entries) {
      if (!newTimerStates.containsValue(entry.value)) {
        entry.value.dispose();
      }
    }
    
    // Replace the old timer states map
    timerStates = newTimerStates;
  }

  void startAllTimers() {
    for (int i = 0; i < runnerNames.length; i++) {
      String timerId = _getTimerStateId(i);
      TimerState? timerState = timerStates[timerId];
      if (timerState != null) {
        _startTimer(timerState);
      }
    }
  }

  void stopAllTimers() {
    for (int i = 0; i < runnerNames.length; i++) {
      String timerId = _getTimerStateId(i);
      TimerState? timerState = timerStates[timerId];
      if (timerState != null) {
        _stopTimer(timerState);
      }
    }
  }

  void resetAllTimers() {
    for (int i = 0; i < runnerNames.length; i++) {
      String timerId = _getTimerStateId(i);
      TimerState? timerState = timerStates[timerId];
      if (timerState != null) {
        _resetTimer(timerState);
      }
    }
    // Additional UI update after resetting all timers
    if (mounted) {
      setState(() {});
    }
  }
  
  void _startTimer(TimerState timerState) {
    timerState.stopwatch.start();
    timerState.lapStopwatch.start();
    timerState.isRunning = true;
    timerState.periodicTimer?.cancel();
    timerState.periodicTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (mounted) {
        timerState.timerValue = _formatTime(timerState.stopwatch.elapsedMilliseconds);
        timerState.currentLapTimeValue = _formatTime(timerState.lapStopwatch.elapsedMilliseconds);
        setState(() {}); // Trigger rebuild to update UI
      } else {
        timer.cancel();
      }
    });
  }
  
  void _takeLapTime(TimerState timerState) {
    if (timerState.isRunning) {
      final currentTimerValue = timerState.timerValue;
      final lapTime = _calculateLapTime(currentTimerValue, timerState.previousTime);
      final splitTime = currentTimerValue;
      timerState.previousTime = currentTimerValue;
      timerState.lapNumber++;
      timerState.lapEntries.insert(0, LapEntry(lapTime: lapTime, splitTime: splitTime));
      // Reset lap timer
      timerState.lapStopwatch.reset();
      timerState.lapStopwatch.start();
      timerState.currentLapNumber = timerState.lapNumber + 1;
      timerState.currentLapTimeValue = '00:00:00';
      setState(() {}); // Trigger UI update
    }
  }
  
  String _calculateLapTime(String currentTimerValue, String previousTime) {
    final currentDuration = _timeStringToDuration(currentTimerValue);
    final previousDuration = _timeStringToDuration(previousTime);
    final lapDuration = currentDuration - previousDuration;
    final int ms = ((lapDuration.inMilliseconds % 1000) ~/ 10);
    final String lapTime =
        '${lapDuration.inMinutes.toString().padLeft(2, '0')}:'
        '${(lapDuration.inSeconds % 60).toString().padLeft(2, '0')}:'
        '${ms.toString().padLeft(2, '0')}';
    return lapTime;
  }

  Duration _timeStringToDuration(String timeString) {
    final List<String> timeComponents = timeString.split(':');
    final int minutes = int.parse(timeComponents[0]);
    final int seconds = int.parse(timeComponents[1]);
    final int centiseconds = int.parse(timeComponents[2]);
    return Duration(minutes: minutes, seconds: seconds, milliseconds: centiseconds * 10);
  }
  
  void _stopTimer(TimerState timerState) {
    if (timerState.isRunning) {
      // Take a final lap time before stopping
      _takeLapTime(timerState);
    }
    timerState.stopwatch.stop();
    timerState.lapStopwatch.stop();
    timerState.isRunning = false;
    timerState.periodicTimer?.cancel();
    setState(() {}); // Trigger UI update
  }
  
  void _resetTimer(TimerState timerState) {
    // Cancel any running timer first
    timerState.periodicTimer?.cancel();
    timerState.periodicTimer = null;
    
    // Reset all stopwatch instances
    timerState.stopwatch.reset();
    timerState.lapStopwatch.reset();
    
    // Reset all state variables
    timerState.isRunning = false;
    timerState.timerValue = '00:00:00';
    timerState.currentLapTimeValue = '00:00:00';
    timerState.previousTime = '00:00:00';
    timerState.lapEntries.clear();
    timerState.currentLapNumber = 1;
    timerState.lapNumber = 0;
    
    // Force UI update to reflect reset state
    if (mounted) {
      setState(() {});
    }
  }
  
  String _formatTime(int milliseconds) {
    // Convert to centiseconds (1/100 second) format: MM:SS:CC
    final int centiseconds = (milliseconds / 10).truncate();
    final int seconds = (centiseconds / 100).truncate();
    final int minutes = (seconds / 60).truncate();
    final String centisecondsStr = (centiseconds % 100).toString().padLeft(2, '0');
    final String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    final String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr:$centisecondsStr';
  }

  // Pace calculation helper functions
  String _formatPaceDisplay(double paceValue) {
    final minutes = paceValue.floor();
    final seconds = ((paceValue - minutes) * 60).round();
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String _formatTimeFromSeconds(double totalSeconds) {
    final hours = (totalSeconds / 3600).floor();
    final minutes = ((totalSeconds % 3600) / 60).floor();
    final seconds = (totalSeconds % 60).floor();
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  double _calculateTimeForDistance(int distanceInMeters) {
    // Convert pace value to seconds per meter
    final pacePerKmInSeconds = _paceValue * 60; // Convert minutes to seconds
    final pacePerMeterInSeconds = pacePerKmInSeconds / 1000.0;
    
    // Calculate total time for the distance
    return distanceInMeters * pacePerMeterInSeconds;
  }
  
  void _finishEditingPace() {
    setState(() {
      _isEditingPace = false;
      // Parse the entered pace value
      final paceText = _paceController.text.trim();
      final pacePattern = RegExp(r'^(\d+):([0-5]\d)$');
      final match = pacePattern.firstMatch(paceText);
      
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final newPaceValue = minutes + (seconds / 60.0);
        
        // Clamp to valid range
        _paceValue = newPaceValue.clamp(2.0, 10.0);
      }
      
      // Update controller with formatted value
      _paceController.text = _formatPaceDisplay(_paceValue);
    });
  }
  
  void _startEditingPace() {
    setState(() {
      _isEditingPace = true;
      _paceController.text = _formatPaceDisplay(_paceValue);
    });
    _paceFocusNode.requestFocus();
  }

  void _adjustPaceValue(double adjustment) async {
    final int currentPaceSeconds = (_paceValue * 60).round();
    final int adjustmentSeconds = (adjustment * 3).round(); // 3 seconds per unit for sensitivity
    final int newPaceSeconds = (currentPaceSeconds + adjustmentSeconds).clamp(120, 600); // 2:00 to 10:00
    
    setState(() {
      _paceValue = newPaceSeconds / 60.0;
    });
    
    // Throttled haptic feedback
    final now = DateTime.now();
    if (_lastHapticTime == null || now.difference(_lastHapticTime!).inMilliseconds > 50) {
      HapticFeedback.selectionClick();
      _lastHapticTime = now;
    }
  }

  void _showPaceEditDialog() {
    final TextEditingController dialogController = TextEditingController(
      text: _formatPaceDisplay(_paceValue),
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Pace per KM'),
          content: TextField(
            controller: dialogController,
            decoration: InputDecoration(
              labelText: 'Pace (MM:SS)',
              hintText: 'e.g., 4:30',
            ),
            keyboardType: TextInputType.text,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updatePaceFromDialog(dialogController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  void _updatePaceFromDialog(String paceText) {
    try {
      final parts = paceText.split(':');
      if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        final totalMinutes = minutes + (seconds / 60.0);
        final clampedPace = totalMinutes.clamp(2.0, 10.0);
        
        setState(() {
          _paceValue = clampedPace;
          _isEditingPace = false;
        });
      }
    } catch (e) {
      // Invalid format, ignore
    }
  }
  
  void _startEditingDistance(String distanceName, String currentTime) {
    setState(() {
      _editingDistance = distanceName;
      _distanceControllers[distanceName]?.text = currentTime;
    });
  }
  
  void _adjustDistanceTime(String distanceName, int distanceInMeters, int adjustment) async {
    // Add throttled haptic feedback for drag adjustments
    if (adjustment != 0) {
      final now = DateTime.now();
      if (_lastDragTime == null || now.difference(_lastDragTime!).inMilliseconds > 100) {
        await performHapticFeedback();
        _lastDragTime = now;
      }
    }
    
    // Calculate current time for this distance
    final currentTimeInSeconds = _calculateTimeForDistance(distanceInMeters);
    
    // Adjust time by 1 second increments
    final newTimeInSeconds = (currentTimeInSeconds + adjustment).clamp(1.0, 86400.0); // Max 24 hours
    
    // Calculate new pace per km from this adjusted time
    final newPacePerKmInSeconds = (newTimeInSeconds * 1000.0) / distanceInMeters;
    final newPaceValue = newPacePerKmInSeconds / 60.0; // Convert to minutes
    
    // Update pace (this will automatically update all distance times)
    setState(() {
      _paceValue = newPaceValue.clamp(2.0, 10.0);
      _paceController.text = _formatPaceDisplay(_paceValue);
    });
  }
  
  void _showTimeEditDialog(String distanceName, int distanceInMeters, String currentTime) {
    final TextEditingController dialogController = TextEditingController(text: currentTime);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $distanceName Time'),
          content: TextField(
            controller: dialogController,
            decoration: InputDecoration(
              labelText: 'Time (MM:SS or H:MM:SS)',
              hintText: 'e.g., 4:30 or 1:25:30',
            ),
            keyboardType: TextInputType.text,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateTimeFromDialog(distanceName, distanceInMeters, dialogController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
  
  void _updateTimeFromDialog(String distanceName, int distanceInMeters, String timeText) {
    final timeInSeconds = _parseTimeToSeconds(timeText.trim());
    
    if (timeInSeconds > 0) {
      // Calculate new pace per km from this time
      final newPacePerKmInSeconds = (timeInSeconds * 1000.0) / distanceInMeters;
      final newPaceValue = newPacePerKmInSeconds / 60.0; // Convert to minutes
      
      // Update pace and exit editing mode
      setState(() {
        _paceValue = newPaceValue.clamp(2.0, 10.0);
        _paceController.text = _formatPaceDisplay(_paceValue);
        _editingDistance = null;
      });
    }
  }
  
  // Helper function to parse time strings (MM:SS or H:MM:SS) to seconds
  double _parseTimeToSeconds(String timeText) {
    try {
      final parts = timeText.split(':');
      if (parts.length == 2) {
        // MM:SS format
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return (minutes * 60 + seconds).toDouble();
      } else if (parts.length == 3) {
        // H:MM:SS format
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return (hours * 3600 + minutes * 60 + seconds).toDouble();
      }
    } catch (e) {
      // Invalid format
    }
    return 0.0;
  }

  void toggleSlidePanel() {
    setState(() {
      _isSlidePageVisible = !_isSlidePageVisible;
      if (_isSlidePageVisible) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }
  
  Widget _buildSlidePanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - compact for narrow panel
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Color.fromRGBO(243, 134, 32, 1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'PACE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: toggleSlidePanel,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          // Main pace calculator content
          Expanded(
            child: _buildPaceCalculator(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaceCalculator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pace input section
          Text(
            'Pace per km:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          
          // Pace display and slider control
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // Current pace display - editable with drag control
                _isEditingPace
                    ? GestureDetector(
                        onPanUpdate: (details) {
                          // Horizontal drag to adjust pace
                          final double sensitivity = 2.0; // Adjust sensitivity (lower = more sensitive)
                          final double adjustment = details.delta.dx / sensitivity;
                          if (adjustment.abs() > 0.5) {
                            _adjustPaceValue(adjustment);
                          }
                        },
                        onTap: () => _showPaceEditDialog(),
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color.fromRGBO(243, 134, 32, 0.6), width: 1),
                            borderRadius: BorderRadius.circular(4),
                            color: Color.fromRGBO(243, 134, 32, 0.1),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(243, 134, 32, 0.3),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Left drag indicator
                              Container(
                                width: 10,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(243, 134, 32, 0.3),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    bottomLeft: Radius.circular(3),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.drag_indicator,
                                    size: 8,
                                    color: Color.fromRGBO(243, 134, 32, 1),
                                  ),
                                ),
                              ),
                              // Pace display with drag functionality
                              Expanded(
                                child: Container(
                                  height: 28,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        size: 12,
                                        color: Color.fromRGBO(243, 134, 32, 1),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        _formatPaceDisplay(_paceValue),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(243, 134, 32, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Right drag indicator
                              Container(
                                width: 10,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(243, 134, 32, 0.3),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(3),
                                    bottomRight: Radius.circular(3),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.drag_indicator,
                                    size: 8,
                                    color: Color.fromRGBO(243, 134, 32, 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => _startEditingPace(),
                        onLongPress: () => _showPaceEditDialog(),
                        child: Container(
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Color.fromRGBO(243, 134, 32, 0.1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 10,
                                color: Color.fromRGBO(243, 134, 32, 0.7),
                              ),
                              SizedBox(width: 2),
                              Text(
                                _formatPaceDisplay(_paceValue),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(243, 134, 32, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                SizedBox(height: 4),
                
                // Slider for pace adjustment
                Container(
                  height: 30,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                      activeTrackColor: Color.fromRGBO(243, 134, 32, 1),
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Color.fromRGBO(243, 134, 32, 1),
                      overlayColor: Color.fromRGBO(243, 134, 32, 0.2),
                    ),
                    child: Slider(
                      value: _paceValue,
                      min: 2.0,
                      max: 10.0,
                      divisions: 160, // Allows 3-second increments (8 minutes * 60 seconds / 3)
                      onChanged: (value) {
                        setState(() {
                          _paceValue = value;
                        });
                      },
                    ),
                  ),
                ),
                
                // Range indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('2:00', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    Text('10:00', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Results section
          Text(
            'Times:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDistanceResults(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildDistanceResults() {
    final distances = [
      {'name': '400m', 'meters': 400},
      {'name': '550m', 'meters': 550},
      {'name': '800m', 'meters': 800},
      {'name': '1200m', 'meters': 1200},
      {'name': '1400m', 'meters': 1400},
      {'name': '1600m', 'meters': 1600},
      {'name': '3km', 'meters': 3000},
      {'name': '5km', 'meters': 5000},
      {'name': '10km', 'meters': 10000},
      {'name': 'Half', 'meters': 21097},
      {'name': 'Full', 'meters': 42195},
    ];
    
    return distances.map((distance) {
      final distanceName = distance['name'] as String;
      final distanceInMeters = distance['meters'] as int;
      final timeInSeconds = _calculateTimeForDistance(distanceInMeters);
      final formattedTime = _formatTimeFromSeconds(timeInSeconds);
      final isEditing = _editingDistance == distanceName;
      
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              distanceName,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
            isEditing 
              ? GestureDetector(
                  onPanUpdate: (details) {
                    // Horizontal drag to adjust time
                    final double sensitivity = 0.5;
                    final int adjustment = (details.delta.dx / sensitivity).round();
                    if (adjustment != 0) {
                      _adjustDistanceTime(distanceName, distanceInMeters, adjustment);
                    }
                  },
                  onTap: () => _showTimeEditDialog(distanceName, distanceInMeters, formattedTime),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 85,
                      minWidth: 70,
                    ),
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromRGBO(243, 134, 32, 0.6), width: 1),
                      borderRadius: BorderRadius.circular(3),
                      color: Color.fromRGBO(243, 134, 32, 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(243, 134, 32, 0.3),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Left drag indicator
                              Container(
                                width: 5,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(243, 134, 32, 0.3),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(2),
                                    bottomLeft: Radius.circular(2),
                                  ),
                                ),
                                child: Icon(
                                  Icons.drag_indicator,
                                  size: 3,
                                  color: Color.fromRGBO(243, 134, 32, 1),
                                ),
                              ),
                              // Time display with drag functionality
                              Expanded(
                                child: Container(
                                  height: 22,
                                  constraints: BoxConstraints(
                                    minWidth: 40,
                                  ),
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formattedTime,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(243, 134, 32, 1),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ),
                              ),
                              // Right drag indicator
                              Container(
                                width: 5,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(243, 134, 32, 0.3),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(2),
                                    bottomRight: Radius.circular(2),
                                  ),
                                ),
                                child: Icon(
                                  Icons.drag_indicator,
                                  size: 3,
                                  color: Color.fromRGBO(243, 134, 32, 1),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () => _startEditingDistance(distanceName, formattedTime),
                  onLongPress: () => _showTimeEditDialog(distanceName, distanceInMeters, formattedTime),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Color.fromRGBO(243, 134, 32, 0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 8,
                          color: Color.fromRGBO(243, 134, 32, 0.7),
                        ),
                        SizedBox(width: 2),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(243, 134, 32, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _paceController.dispose();
    _paceFocusNode.dispose();
    // Dispose distance controllers
    for (var controller in _distanceControllers.values) {
      controller.dispose();
    }
    // Dispose all timer states
    for (var timerState in timerStates.values) {
      timerState.dispose();
    }
    super.dispose();
  }

  void addTimerRow() {
    setState(() {
      runnerNames.add('Runner ${runnerNames.length + 1}');
      rowKeys.add(GlobalKey<_TimerRowState>());
      
      // Initialize timer state for new row
      String newTimerId = _getTimerStateId(runnerNames.length - 1);
      timerStates[newTimerId] = TimerState(newTimerId);
    });
    saveRunnerNames();
  }

  void removeTimerRow(int index) {
    // Clean up timer state before removing
    String timerId = _getTimerStateId(index);
    TimerState? timerState = timerStates[timerId];
    if (timerState != null) {
      timerState.dispose();
      timerStates.remove(timerId);
    }
    
    setState(() {
      runnerNames.removeAt(index);
      rowKeys.removeAt(index);
    });
    
    // Reinitialize timer states for remaining rows to maintain correct indices
    _reinitializeTimerStates();
    saveRunnerNames();
  }
  
  void _reinitializeTimerStates() {
    Map<String, TimerState> newTimerStates = {};
    for (int i = 0; i < runnerNames.length; i++) {
      String newTimerId = _getTimerStateId(i);
      
      // Try to find existing timer state by runner name
      TimerState? existingState;
      for (var entry in timerStates.entries) {
        if (entry.key.endsWith(runnerNames[i])) {
          existingState = entry.value;
          break;
        }
      }
      
      if (existingState != null) {
        newTimerStates[newTimerId] = existingState;
      } else {
        newTimerStates[newTimerId] = TimerState(newTimerId);
      }
    }
    
    // Dispose old timer states that are no longer needed
    for (var entry in timerStates.entries) {
      if (!newTimerStates.containsValue(entry.value)) {
        entry.value.dispose();
      }
    }
    
    timerStates = newTimerStates;
  }

  Future<void> saveRunnerNames() async {
    try {
      // Save to both SharedPreferences and Document Directory for maximum reliability
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('runnerNames', runnerNames);
      
      // Also save to document directory (survives app updates)
      await _saveToDocumentDirectory();
    } catch (e) {
      print('Error saving runner names: $e');
    }
  }

  Future<void> loadRunnerNames() async {
    try {
      // First try to load from document directory (survives app updates)
      List<String>? savedNames = await _loadFromDocumentDirectory();
      
      // If document directory doesn't have data, try SharedPreferences
      if (savedNames == null || savedNames.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        savedNames = prefs.getStringList('runnerNames');
        
        // If we found data in SharedPreferences, migrate it to document directory
        if (savedNames != null && savedNames.isNotEmpty) {
          await _saveToDocumentDirectory();
        }
      }
      
      if (savedNames != null && savedNames.isNotEmpty) {
        setState(() {
          runnerNames = savedNames!;
          rowKeys = List.generate(
            runnerNames.length,
            (_) => GlobalKey<_TimerRowState>(),
          );
        });
        // Reinitialize timer states after loading names
        _initializeTimerStates();
      }
    } catch (e) {
      print('Error loading runner names: $e');
    }
  }

  Future<void> _saveToDocumentDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/runner_data.json');
      
      final data = {
        'runnerNames': runnerNames,
        'version': '1.0',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(data));
    } catch (e) {
      print('Error saving to document directory: $e');
    }
  }

  Future<List<String>?> _loadFromDocumentDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/runner_data.json');
      
      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = json.decode(contents) as Map<String, dynamic>;
        
        if (data['runnerNames'] != null) {
          return List<String>.from(data['runnerNames']);
        }
      }
    } catch (e) {
      print('Error loading from document directory: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double screenWidth = mediaQuery.size.width;
    
    // Responsive app bar height based on screen size - slightly increased for better text fit
    final double appBarHeight = screenWidth < 375 ? 56 : 60; // Slightly increased for iPhone 13 mini
    final double totalAppBarHeight = appBarHeight + mediaQuery.padding.top;
    final double availableHeight = screenHeight - totalAppBarHeight - mediaQuery.padding.bottom;
    
    // Improved row height calculation prioritizing 8 rows visibility while maintaining usability
    final double minRowHeight = screenWidth < 375 ? 70.0 : 80.0; // Adjusted to fit 8 rows
    final double maxRowHeight = screenWidth < 375 ? 110.0 : 130.0; // Reasonable maximum
    final double idealRowsToShow = 8.0; // Always try to show 8 rows
    final double calculatedRowHeight = availableHeight / idealRowsToShow; // Prioritize 8 rows
    final double rowHeight = calculatedRowHeight.clamp(minRowHeight, maxRowHeight);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          toolbarHeight: appBarHeight,
          flexibleSpace: SafeArea(
            child: Container(
              height: appBarHeight,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 375 ? 2 : 6, // Reduced padding for more text space
                vertical: screenWidth < 375 ? 1 : 3
              ),
              child: Row(
                children: [
                  // Logo with transparent background - no color issues!
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth < 375 ? 2.0 : 4.0, right: screenWidth < 375 ? 4.0 : 6.0),
                    child: Image.asset(
                      'assets/RMAC_Text_transparent.png',
                      height: screenWidth < 375 ? 12 : 16,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Text with calculated available space
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Use larger base font sizes for better visibility
                        final double baseFontSize = screenWidth < 375 ? 16 : 20;
                        
                        return Container(
                          width: constraints.maxWidth,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'MULTI TIMER', // Removed leading space for better fit
                              style: TextStyle(
                                fontSize: baseFontSize, // Larger base font size
                                fontWeight: FontWeight.bold
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Buttons with minimal spacing
                  IconButton(
                    icon: Icon(Icons.stop, size: screenWidth < 375 ? 20 : 26),
                    onPressed: stopAllTimers,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: screenWidth < 375 ? 28 : 36,
                      minHeight: screenWidth < 375 ? 28 : 36
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.play_arrow, size: screenWidth < 375 ? 20 : 26),
                    onPressed: startAllTimers,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: screenWidth < 375 ? 28 : 36,
                      minHeight: screenWidth < 375 ? 28 : 36
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, size: screenWidth < 375 ? 22 : 26), // Slightly smaller for consistency
                    onPressed: resetAllTimers,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: screenWidth < 375 ? 30 : 36, // Reduced for more text space
                      minHeight: screenWidth < 375 ? 30 : 36
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: screenWidth < 375 ? 22 : 26), // Slightly smaller for consistency
                    onPressed: addTimerRow,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: screenWidth < 375 ? 30 : 36, // Reduced for more text space
                      minHeight: screenWidth < 375 ? 30 : 36
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main timer list content - no sliding, only buttons covered by drawer
          ReorderableListView(
            scrollController: _scrollController,
            buildDefaultDragHandles: true,
            padding: EdgeInsets.zero,
            onReorder: (oldIndex, newIndex) {
              if (mounted) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final name = runnerNames.removeAt(oldIndex);
                  final key = rowKeys.removeAt(oldIndex);
                  runnerNames.insert(newIndex, name);
                  rowKeys.insert(newIndex, key);
                  
                  // CRITICAL FIX: Remap timer states after reordering
                  _remapTimerStatesAfterReorder();
                  
                  saveRunnerNames();
                });
              }
            },
            children: [
              for (int index = 0; index < runnerNames.length; index++)
                Container(
                  key: ValueKey('${runnerNames[index]}-$index'),
                  height: rowHeight,
                  child: Builder(
                    builder: (context) {
                      final Color rowColor = index.isOdd
                          ? Colors.white
                          : Color.fromRGBO(254, 205, 146, 1);
                      if (pendingDeleteIndex == index) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 32),
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        pendingDeleteIndex = null;
                                      });
                                      removeTimerRow(index);
                                    }
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              left: -60,
                              right: 60,
                              top: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onHorizontalDragEnd: (details) {
                                  if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                                    if (mounted) {
                                      setState(() {
                                        pendingDeleteIndex = null;
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  color: rowColor,
                                  child: TimerRow(
                                    key: rowKeys[index],
                                    runnerName: runnerNames[index],
                                    rowIndex: index,
                                    scrollController: _scrollController,
                                    rowHeight: rowHeight,
                                    rowColor: rowColor,
                                    timerState: _getTimerState(index),
                                    onNameChanged: (newName) {
                                      _updateRunnerName(index, newName);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                            if (mounted) {
                              setState(() {
                                pendingDeleteIndex = index;
                              });
                            }
                          }
                        },
                        child: Container(
                          color: rowColor,
                          child: TimerRow(
                            key: rowKeys[index],
                            runnerName: runnerNames[index],
                            rowIndex: index,
                            scrollController: _scrollController,
                            rowHeight: rowHeight,
                            rowColor: rowColor,
                            timerState: _getTimerState(index),
                            onNameChanged: (newName) {
                              _updateRunnerName(index, newName);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          // Slide-out panel - covers only the left button area (about 150px wide)
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              // Panel width set to 155px as requested
              final double panelWidth = 155;
              final slideOffset = -panelWidth + (_slideAnimation.value * panelWidth);
              return Transform.translate(
                offset: Offset(slideOffset, 0),
                child: Container(
                  width: panelWidth,
                  height: double.infinity,
                  color: Colors.white,
                  child: _buildSlidePanel(),
                ),
              );
            },
          ),
          // PACE tab button - moves with drawer animation
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              // Calculate tab position based on drawer state
              final double panelWidth = 155; // Match panel width
              final double tabLeftPosition = _slideAnimation.value * panelWidth;
              
              return Positioned(
                bottom: 60,
                left: tabLeftPosition,
                child: GestureDetector(
                  onTap: toggleSlidePanel,
                  child: Container(
                    width: 28, // Very small width for minimal tab appearance
                    height: 80, // Height that won't cover buttons
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(243, 134, 32, 1),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(2, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: OverflowBox(
                        maxWidth: 50, // Allow text to extend beyond container width
                        child: Transform.rotate(
                          angle: pi / 2, // Rotate 90 degrees clockwise
                          child: Text(
                            'PACE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12, // Optimized font size
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.0, // No letter spacing to keep text compact
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _updateRunnerName(int index, String newName) {
    // Get the current timer state before name change
    String oldTimerId = _getTimerStateId(index);
    TimerState? currentTimerState = timerStates[oldTimerId];
    
    // Update the runner name
    runnerNames[index] = newName;
    
    // Update timer state mapping if timer state exists
    if (currentTimerState != null) {
      String newTimerId = _getTimerStateId(index);
      
      // Remove old mapping and add new mapping
      timerStates.remove(oldTimerId);
      timerStates[newTimerId] = currentTimerState;
    }
    
    saveRunnerNames();
  }
}
class LapEntry {
  final String lapTime;
  final String splitTime;
  LapEntry({required this.lapTime, required this.splitTime});
}

class TimerRow extends StatefulWidget {
  final String runnerName;
  final int rowIndex;
  final ScrollController scrollController;
  final double rowHeight;
  final ValueChanged<String>? onNameChanged;
  final Color rowColor;
  final TimerState timerState;

  TimerRow({
    Key? key,
    required this.runnerName,
    required this.rowIndex,
    required this.scrollController,
    required this.rowHeight,
    required this.rowColor, 
    required this.timerState,
    this.onNameChanged, 
  }) : super(key: key);

  @override
  _TimerRowState createState() => _TimerRowState();
}

class _TimerRowState extends State<TimerRow> {
  bool isEditingName = false;
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;

  // Use the shared timer state instead of local state
  TimerState get timerState => widget.timerState;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.runnerName);
    _nameFocusNode = FocusNode();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus && isEditingName) {
        _finishEditingName();
      }
    });
  }

  @override
  void dispose() {
    // Only dispose UI-related resources, not the shared timer state
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    // Delegate to parent's centralized timer management
    final parentState = context.findAncestorStateOfType<_TimerListState>();
    parentState?._startTimer(timerState);
  }

  void stopTimer() {
    // Delegate to parent's centralized timer management
    final parentState = context.findAncestorStateOfType<_TimerListState>();
    parentState?._stopTimer(timerState);
  }

  void resetTimer() {
    // Delegate to parent's centralized timer management
    final parentState = context.findAncestorStateOfType<_TimerListState>();
    parentState?._resetTimer(timerState);
  }

  void takeLapTime() {
    // Delegate to parent's centralized timer management
    final parentState = context.findAncestorStateOfType<_TimerListState>();
    parentState?._takeLapTime(timerState);
  }

  void _finishEditingName() {
    setState(() {
      isEditingName = false;
    });
    if (widget.onNameChanged != null) {
      widget.onNameChanged!(_nameController.text);
    }
  }

  void _showLapTimesDialog() {
    showDialog(
      context: context,
      barrierColor:Colors.transparent,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        backgroundColor: Colors.white.withAlpha(238), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: LapTimesPage(
          lapEntries: timerState.lapEntries,
          runnerName: _nameController.text,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final bool isOrangeRow = widget.rowColor == Color.fromRGBO(254, 205, 146, 1);
    final Color buttonColor = isOrangeRow
    ? Colors.white
    : (timerState.isRunning ? Colors.deepOrange[300]! : const Color.fromRGBO(243, 134, 32, 1));
     final Color buttonTextColor = isOrangeRow
    ? Colors.black
    : Colors.white;
    
    // Current lap timer color: red on white rows, black on orange rows
    final Color currentLapTimerColor = isOrangeRow ? Colors.black : Colors.red;
    
    // Responsive flex ratios to give more space to name on small screens
    final int nameFlex = screenWidth < 375 ? 2 : 1;  // More space for name on small screens
    final int timerSectionFlex = screenWidth < 375 ? 3 : 2;  // Adjusted proportionally
    
    // Responsive font sizes based on screen width and row height - optimized for 8-row display
    // Balanced sizing: main timer still largest, lap times significantly larger but proportional
    final double mainTimerFontSize = screenWidth < 375 
        ? (widget.rowHeight * 0.30).clamp(22.0, 32.0)  // Slightly increased for better visibility
        : screenWidth < 415  // iPhone 14 Pro Max is 430px, regular iPhone 14 is 390px
            ? (widget.rowHeight * 0.34).clamp(26.0, 38.0) // Increased for better balance
            : (widget.rowHeight * 0.36).clamp(30.0, 42.0); // Increased for larger screens
    
    final double nameFontSize = screenWidth < 375 ? 15.0 : 17.0; // Keep name font size unchanged
    final double lapNumberFontSize = screenWidth < 375 ? 11.0 : 
                                   screenWidth < 415 ? 12.0 : 13.0; // Increased for better visibility
    final double lapTimeFontSize = screenWidth < 375 ? 19.0 : 
                                 screenWidth < 415 ? 22.0 : 24.0; // Significantly increased, closer to main timer
    
    // Optimize flex ratios to better utilize space
    final int timerFlex = screenWidth < 375 ? 2 : 3;  // More space for main timer
    final int lapFlex = screenWidth < 375 ? 2 : 2;    // More space for lap times
    //final Color buttonColor = isRunning ? Colors.deepOrange[300]! : Colors.orange[200]!;
    
    // Portrait layout only (landscape mode disabled)
    return Container(
      decoration: BoxDecoration(),
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add left margin to avoid overlap with PACE tab
            SizedBox(width: 25), // Space to avoid PACE tab overlap
            // Start/Stop and Lap/Reset buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 60,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: buttonColor, 
                  ),
                  onPressed: () async {
                    // Use comprehensive haptic feedback but don't block the timer action
                    performHapticFeedback(); // Remove await to not block the action
                    
                    if (timerState.isRunning) {
                      stopTimer();
                    } else {
                      startTimer();
                    }
                  },
                  child: Text(
                    timerState.isRunning ? 'Stop' : 'Start',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: buttonTextColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 60,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                    backgroundColor: buttonColor, 
                  ),
                  onPressed: () async {
                    // Use comprehensive haptic feedback but don't block the reset action
                    performHapticFeedback(); // Remove await to not block the action
                    
                    if (timerState.isRunning) {
                      takeLapTime();
                    } else {
                      resetTimer();
                    }
                  },
                  child: Text(
                    timerState.isRunning ? 'Lap' : 'Reset',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: buttonTextColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            // Right side content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Runner name with responsive sizing and proper vertical space
                  Expanded(
                    flex: nameFlex, // More space on small screens
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: screenWidth < 375 ? 1.0 : 4.0), // Minimal padding to maximize text space
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            isEditingName = true;
                          });
                          await Future.delayed(Duration(milliseconds: 100));
                          _nameFocusNode.requestFocus();
                          widget.scrollController.animateTo(
                            widget.rowIndex * widget.rowHeight,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity, // Use full available height
                          alignment: Alignment.centerLeft,
                          color: Colors.transparent,
                          child: isEditingName
                              ? TextField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  autofocus: true,
                                  textAlign: TextAlign.left,
                                  onSubmitted: (_) {
                                    _finishEditingName();
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero, // Remove all padding for more space
                                  ),
                                  style: TextStyle(
                                    fontSize: nameFontSize, // Responsive font size
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    height: 1.2, // Proper line height to prevent clipping
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _nameController.text.isEmpty ? ' ' : _nameController.text,
                                    style: TextStyle(
                                      fontSize: nameFontSize, // Same font size as TextField
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      height: 1.2, // Proper line height to prevent vertical clipping
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis, // Use ellipsis instead of scaling
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom row: Timer value (large) and lap times (smaller)
                  Expanded(
                    flex: timerSectionFlex, // Adjusted flex for better proportions
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left column: Main timer value (larger font)
                        Expanded(
                          flex: timerFlex, // More space for timer on larger screens
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth < 375 ? 2.0 : 1.0, // Reduced padding for more space
                              horizontal: 1.0 // Reduced horizontal padding
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                timerState.timerValue,
                                style: TextStyle(
                                  fontSize: mainTimerFontSize, // Responsive font size
                                  fontFamily: 'Courier',
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        // Right column: Current lap and last 2 lap times (smaller fonts)
                        Expanded(
                          flex: lapFlex, // Responsive flex for lap times
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end, // Align to right
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Current lap number and timer
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenWidth < 375 ? 0.5 : 0.5, // Reduced vertical padding
                                  horizontal: screenWidth < 375 ? 2.0 : 1.0 // Reduced horizontal padding
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end, // Align row content to right
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Fixed width for lap number to maintain alignment
                                    SizedBox(
                                      width: screenWidth < 375 ? 18 : 20, // Fixed width for consistent alignment
                                      child: Text(
                                        '${timerState.currentLapNumber}',
                                        style: TextStyle(
                                          fontSize: lapNumberFontSize, // Responsive font size
                                          fontWeight: FontWeight.bold,
                                          color: currentLapTimerColor, // Use dynamic color based on row
                                          fontFamily: 'Courier',
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.right, // Right align within fixed width
                                      ),
                                    ),
                                    SizedBox(width: 1), // Reduced spacing
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          timerState.currentLapTimeValue,
                                          style: TextStyle(
                                            fontSize: lapTimeFontSize, // Responsive font size
                                            fontWeight: FontWeight.bold,
                                            color: currentLapTimerColor, // Use dynamic color based on row
                                            fontFamily: 'Courier',
                                            height: 1,
                                          ),
                                          maxLines: 1,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Last two lap rows
                              if (timerState.lapEntries.isNotEmpty)
                                ...[
                                  for (var i = 0; i < timerState.lapEntries.length && i < 2; i++)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenWidth < 375 ? 0.5 : 0.5, // Reduced vertical padding
                                        horizontal: screenWidth < 375 ? 2.0 : 1.0 // Reduced horizontal padding
                                      ),
                                      child: GestureDetector(
                                        onTap: _showLapTimesDialog,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end, // Align row content to right
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Fixed width for lap number to maintain alignment
                                            SizedBox(
                                              width: screenWidth < 375 ? 18 : 20, // Fixed width for consistent alignment
                                              child: Text(
                                                '${timerState.lapEntries.length - i}',
                                                style: TextStyle(
                                                  fontSize: lapNumberFontSize, // Responsive font size
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black, 
                                                  fontFamily: 'Courier',
                                                  height: 1,
                                                ),
                                                textAlign: TextAlign.right, // Right align within fixed width
                                              ),
                                            ),
                                            SizedBox(width: 1), // Reduced spacing
                                            Flexible(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  timerState.lapEntries[i].lapTime,
                                                  style: TextStyle(
                                                    fontSize: lapTimeFontSize, // Responsive font size
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontFamily: 'Courier',
                                                    height: 1,
                                                  ),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class LapTimesPage extends StatelessWidget {
  final List<LapEntry> lapEntries;
  final String runnerName;

  LapTimesPage({required this.lapEntries, required this.runnerName});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    
    // More aggressive font size reduction for iPhone 13 mini to ensure single-line fit
    final double titleFontSize = screenWidth < 375 ? 16.0 : 18.0;
    final double lapTextFontSize = screenWidth < 375 ? 10.0 : 14.0; // Reduced for small screens
    
    List<int> lapMillis = lapEntries
        .map((e) => _parseDuration(e.lapTime).inMilliseconds)
        .toList();
    int? maxLap = lapMillis.isNotEmpty ? lapMillis.reduce((a, b) => a > b ? a : b) : null;
    int? minLap = lapMillis.isNotEmpty ? lapMillis.reduce((a, b) => a < b ? a : b) : null;

    return Padding(
      padding: EdgeInsets.all(screenWidth < 375 ? 12.0 : 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$runnerName Lap Times',
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: screenWidth < 375 ? 20 : 24),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: screenWidth < 375 ? 32 : 40,
                  minHeight: screenWidth < 375 ? 32 : 40,
                ),
              ),
            ],
          ),
          Divider(),
          SizedBox(
            height: 300, // Set a fixed height for scrollable list
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: lapEntries.length,
              itemBuilder: (context, index) {
                final entry = lapEntries[index];
                final lapMs = lapMillis[index];
                Color? tileColor;
                if (lapMs == maxLap) tileColor = Colors.red[100];
                if (lapMs == minLap) tileColor = Colors.green[100];
                return ListTile(
                  tileColor: tileColor,
                  dense: true, // Always dense for consistent height
                  isThreeLine: false,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 375 ? 6.0 : 16.0, // Reduced padding on small screens
                    vertical: screenWidth < 375 ? 2.0 : 4.0,   // Minimal vertical padding
                  ),
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate available width for text, reserving space for badge if needed
                      double availableWidth = constraints.maxWidth;
                      bool hasBadge = (lapMs == maxLap || lapMs == minLap);
                      double badgeWidth = hasBadge ? (screenWidth < 375 ? 24 : 30) : 0;
                      double spacing = hasBadge ? 4 : 0;
                      double textWidth = availableWidth - badgeWidth - spacing;
                      
                      String displayText = 'Lap ${lapEntries.length - index}: ${entry.lapTime}   Split: ${entry.splitTime}';
                      
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Simple FittedBox solution for reliable single-line scaling
                          SizedBox(
                            width: textWidth,
                            height: 20, // Fixed height for consistency
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                displayText,
                                style: TextStyle(fontSize: lapTextFontSize, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                          // Compact badge
                          if (hasBadge) ...[
                            SizedBox(width: 4),
                            Container(
                              width: screenWidth < 375 ? 20 : 26,
                              height: screenWidth < 375 ? 14 : 16,
                              decoration: BoxDecoration(
                                color: lapMs == maxLap ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(screenWidth < 375 ? 2 : 3),
                              ),
                              child: Center(
                                child: Text(
                                  lapMs == maxLap ? 'Min' : 'Max',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth < 375 ? 6 : 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  trailing: null, // No trailing needed since badge is integrated
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Duration _parseDuration(String timeString) {
    final parts = timeString.split(':');
    final minutes = int.parse(parts[0]);
    final seconds = int.parse(parts[1]);
    final hundredths = int.parse(parts[2]);
    return Duration(minutes: minutes, seconds: seconds, milliseconds: hundredths * 10);
  }
}