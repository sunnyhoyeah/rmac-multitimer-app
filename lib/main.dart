import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart'; 

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
    });
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

class _TimerListState extends State<TimerList> {
  final ScrollController _scrollController = ScrollController();
  List<String> runnerNames = ['Runner 1', 'Runner 2', 'Runner 3'];
  late List<GlobalKey<_TimerRowState>> rowKeys;
  int? pendingDeleteIndex;

  @override
  void initState() {
    super.initState();
    rowKeys = List.generate(
      runnerNames.length,
      (_) => GlobalKey<_TimerRowState>(),
    );
    loadRunnerNames();
  }

  void startAllTimers() {
    for (int i = 0; i < runnerNames.length; i++) {
      rowKeys[i].currentState?.startTimer();
    }
  }

  void stopAllTimers() {
    for (int i = 0; i < runnerNames.length; i++) {
      rowKeys[i].currentState?.stopTimer();
    }
  }

  void resetAllTimers() {
    for (int i = 0; i < runnerNames.length; i++) {
      rowKeys[i].currentState?.resetTimer();
    }
  }

  void addTimerRow() {
    setState(() {
      runnerNames.add('Runner ${runnerNames.length + 1}');
      rowKeys.add(GlobalKey<_TimerRowState>());
    });
    saveRunnerNames();
  }

  void removeTimerRow(int index) {
  setState(() {
    runnerNames.removeAt(index);
    rowKeys.removeAt(index);
  });
  saveRunnerNames();
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
      body: ReorderableListView(
        scrollController: _scrollController,
        buildDefaultDragHandles: true,
        padding: EdgeInsets.zero,
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
                                  onNameChanged: (newName) {
                                    runnerNames[index] = newName;
                                    saveRunnerNames();
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
                          onNameChanged: (newName) {
                            runnerNames[index] = newName;
                            saveRunnerNames();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
          onReorder: (oldIndex, newIndex) {
            if (mounted) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final name = runnerNames.removeAt(oldIndex);
                final key = rowKeys.removeAt(oldIndex);
                runnerNames.insert(newIndex, name);
                rowKeys.insert(newIndex, key);
                saveRunnerNames();
              });
            }
          },
        ),
    );
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

  TimerRow({
    Key? key,
    required this.runnerName,
    required this.rowIndex,
    required this.scrollController,
    required this.rowHeight,
    required this.rowColor, 
    this.onNameChanged, 
  }) : super(key: key);

  @override
  _TimerRowState createState() => _TimerRowState();
}

class _TimerRowState extends State<TimerRow> {
  Timer? _periodicTimer;
  bool isEditingName = false;
  bool isRunning = false;
  Stopwatch lapStopwatch = Stopwatch();
  String currentLapTimeValue = '00:00:00';
  int currentLapNumber = 1;
  Stopwatch stopwatch = Stopwatch();
  String timerValue = '00:00:00';
  String previousTime = '00:00:00';
  List<LapEntry> lapEntries = [];
  int lapNumber = 0;
  late TextEditingController _nameController;
  late FocusNode _nameFocusNode;

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
    // Cancel the periodic timer first to prevent memory leaks and setState calls after dispose
    _periodicTimer?.cancel();
    _periodicTimer = null;
    
    // Stop the stopwatches
    stopwatch.stop();
    lapStopwatch.stop();
    
    // Dispose controllers and focus nodes
    _nameController.dispose();
    _nameFocusNode.dispose();
    
    super.dispose();
  }

  void startTimer() {
    stopwatch.start();
    lapStopwatch.start();
    setState(() {
      isRunning = true;
    });
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (mounted) { // Check if widget is still mounted
        setState(() {
          timerValue = _formatTime(stopwatch.elapsedMilliseconds);
          currentLapTimeValue = _formatTime(lapStopwatch.elapsedMilliseconds);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void stopTimer() {
    if (isRunning) {
      // Take a final lap time before stopping
      takeLapTime();
      
      stopwatch.stop();
      lapStopwatch.stop();
      _periodicTimer?.cancel();
      setState(() {
        // Final update of timer values to ensure accuracy
        timerValue = _formatTime(stopwatch.elapsedMilliseconds);
        currentLapTimeValue = _formatTime(lapStopwatch.elapsedMilliseconds);
        isRunning = false;
      });
    }
  }

  // Helper function for formatting time with correct centiseconds
  String _formatTime(int ms) {
    final int centiseconds = (ms / 10).truncate();
    final int seconds = (centiseconds / 100).truncate();
    final int minutes = (seconds / 60).truncate();
    final String centisecondsStr = (centiseconds % 100).toString().padLeft(2, '0');
    final String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    final String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr:$centisecondsStr';
  }

  void resetTimer() {
    stopwatch.stop();
    stopwatch.reset();
    lapStopwatch.stop();
    lapStopwatch.reset();
    _periodicTimer?.cancel(); // Cancel the periodic timer
    setState(() {
      isRunning = false;
      timerValue = '00:00:00';
      currentLapTimeValue = '00:00:00';
      lapEntries.clear();
      lapNumber = 0;
      currentLapNumber = 1;
      previousTime = '00:00:00'; 
    });
  }

  void takeLapTime() {
    if (isRunning) {
      final currentTimerValue = timerValue;
      final lapTime = _calculateLapTime(currentTimerValue, previousTime);
      final splitTime = currentTimerValue;
      previousTime = currentTimerValue;
      setState(() {
        lapNumber++;
        lapEntries.insert(0, LapEntry(lapTime: lapTime, splitTime: splitTime));
        // Reset lap timer
        lapStopwatch.reset();
        lapStopwatch.start();
        currentLapNumber = lapNumber + 1;
        currentLapTimeValue = '00:00:00';
      });
    }
  }

  void _finishEditingName() {
  setState(() {
    isEditingName = false;
  });
  if (widget.onNameChanged != null) {
    widget.onNameChanged!(_nameController.text);
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

  void _showLapTimesDialog() {
    showDialog(
      context: context,
      barrierColor:Colors.transparent,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        backgroundColor: Colors.white.withAlpha(238), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: LapTimesPage(
          lapEntries: lapEntries,
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
    : (isRunning ? Colors.deepOrange[300]! : const Color.fromRGBO(243, 134, 32, 1));
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
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    isRunning ? stopTimer() : startTimer();
                  },
                  child: Text(
                    isRunning ? 'Stop' : 'Start',
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
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    isRunning ? takeLapTime() : resetTimer();
                  },
                  child: Text(
                    isRunning ? 'Lap' : 'Reset',
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
                                timerValue,
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
                                        '$currentLapNumber',
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
                                          currentLapTimeValue,
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
                              if (lapEntries.isNotEmpty)
                                ...[
                                  for (var i = 0; i < lapEntries.length && i < 2; i++)
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
                                                '${lapEntries.length - i}',
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
                                                  lapEntries[i].lapTime,
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