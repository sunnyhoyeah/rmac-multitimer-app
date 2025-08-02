import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; 

void main() {
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
    "靜待這一秒世界改善，抑或把握這一秒跑遍世界。",
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/rmac_timer.jpeg'),
            SizedBox(height: 24),
            Text(
              'RMAC - MULTI TIMER',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                '"$randomQuote"',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
          ],
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('runnerNames', runnerNames);
  }

  Future<void> loadRunnerNames() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNames = prefs.getStringList('runnerNames');
    if (savedNames != null && savedNames.isNotEmpty) {
      setState(() {
        runnerNames = savedNames;
        rowKeys = List.generate(
          runnerNames.length,
          (_) => GlobalKey<_TimerRowState>(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double appBarHeight = kToolbarHeight + mediaQuery.padding.top;
    final double bottomBarHeight = 34;
    final double availableHeight = screenHeight - appBarHeight - bottomBarHeight;
    final double rowHeight = (availableHeight / 8).clamp(30.0, 200.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Container(
        height: 90,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset(
                'assets/RMAC_Text.png',
                height: 16,
              ),
            ),
            Text(' MULTI TIMER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Spacer(),
            IconButton(
              icon: Icon(Icons.stop, size: 32),
              onPressed: stopAllTimers,
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: Icon(Icons.play_arrow, size: 32),
              onPressed: startAllTimers,
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: Icon(Icons.refresh, size: 32),
              onPressed: resetAllTimers,
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: Icon(Icons.add, size: 32),
              onPressed: addTimerRow,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ReorderableListView(
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
                    final Color rowColor = index.isEven
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
                                  setState(() {
                                    pendingDeleteIndex = null;
                                  });
                                  removeTimerRow(index);
                                },
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 200),
                            left: -60,
                            right: 60,
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onHorizontalDragEnd: (details) {
                                if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                                  setState(() {
                                    pendingDeleteIndex = null;
                                  });
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
                          setState(() {
                            pendingDeleteIndex = index;
                          });
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
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final name = runnerNames.removeAt(oldIndex);
              final key = rowKeys.removeAt(oldIndex);
              runnerNames.insert(newIndex, name);
              rowKeys.insert(newIndex, key);
              saveRunnerNames();
            });
          },
        ),
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
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    stopwatch.start();
    lapStopwatch.start();
    setState(() {
      isRunning = true;
      // Immediately update timer value for UI
      timerValue = _formatTime(stopwatch.elapsedMilliseconds);
      currentLapTimeValue = _formatTime(lapStopwatch.elapsedMilliseconds);
    });
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        timerValue = _formatTime(stopwatch.elapsedMilliseconds);
        currentLapTimeValue = _formatTime(lapStopwatch.elapsedMilliseconds);
      });
    });
  }

  void stopTimer() {
    if (isRunning) {
      stopwatch.stop();
      lapStopwatch.stop();
      _periodicTimer?.cancel();
      setState(() {
        // Immediately update timer value for UI
        timerValue = _formatTime(stopwatch.elapsedMilliseconds);
        currentLapTimeValue = _formatTime(lapStopwatch.elapsedMilliseconds);
        isRunning = false;
      });
    }
  }

  // Helper function for formatting time
  String _formatTime(int ms) {
    final int hundreds = (ms / 10).truncate();
    final int seconds = (hundreds / 100).truncate();
    final int minutes = (seconds / 60).truncate();
    final String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    final String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    final String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr:$hundredsStr';
  }

  void resetTimer() {
    stopwatch.reset();
    lapStopwatch.reset();
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
    final int hundredths = int.parse(timeComponents[2]);
    return Duration(minutes: minutes, seconds: seconds, milliseconds: hundredths * 10);
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
    final bool isOrangeRow = widget.rowColor == Color.fromRGBO(254, 205, 146, 1);
    final Color buttonColor = isOrangeRow
    ? Colors.white
    : (isRunning ? Colors.deepOrange[300]! : const Color.fromRGBO(243, 134, 32, 1));
     final Color buttonTextColor = isOrangeRow
    ? Colors.black
    : Colors.white;
    //final Color buttonColor = isRunning ? Colors.deepOrange[300]! : Colors.orange[200]!;
    
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final textStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: Colors.black,
      fontFamily: 'Courier',
    );

    if (isLandscape) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Start/Stop button
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 2.0),
              child: IconButton(
                icon: isRunning
                    ? Image.asset('assets/stop.png', width: 40, height: 40)
                    : Image.asset('assets/start.png', width: 40, height: 40),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  isRunning ? stopTimer() : startTimer();
                },
                iconSize: 40,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                visualDensity: VisualDensity.compact,
              ),
            ),
            // Lap/Reset button
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 8.0),
              child: IconButton(
                icon: isRunning
                    ? Image.asset('assets/lap.png', width: 40, height: 40)
                    : Image.asset('assets/reset.png', width: 40, height: 40),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  isRunning ? takeLapTime() : resetTimer();
                },
                iconSize: 40,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                visualDensity: VisualDensity.compact,
              ),
            ),
            // RunnerName
            Expanded(
              flex: 2,
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
                            contentPadding: EdgeInsets.only(left: 0),
                          ),
                          style: textStyle,
                        )
                      : Text(
                          _nameController.text.isEmpty ? ' ' : _nameController.text,
                          style: textStyle,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                ),
              ),
            ),
            // Last two lap texts
            Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = min(1, lapEntries.length - 1); i >= 0; i--)
                    Expanded(
                      child: Text(
                        'Lap ${lapEntries.length - i}: ${lapEntries[i].lapTime}',
                        style: textStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 110, // Adjust as needed for your layout
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerValue,
                      style: textStyle.copyWith(fontSize: 18), // reduced font size
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      currentLapTimeValue,
                      style: textStyle.copyWith(fontSize: 18, color: Colors.red), // slightly smaller
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(),
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start/Stop and Lap/Reset buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // <-- Match timer row padding
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
              padding: const EdgeInsets.symmetric(vertical: 8.0), // <-- Match timer row padding
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
            // Left column: timerValue and runner name
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0), // <-- Add vertical padding
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        timerValue,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 376 ? 20 : 30,
                          fontFamily: 'Courier',
                          height: 1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0), // <-- Add vertical padding
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
                                  contentPadding: EdgeInsets.only(left: 0),
                                ),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                  fontFamily: 'Courier',
                                ),
                              )
                            : Text(
                                _nameController.text.isEmpty ? ' ' : _nameController.text,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                  fontFamily: 'Courier',
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Right column: currentLapTimeValue and last two lap rows
            // In the right column, use Expanded and FittedBox for each timer row to ensure even font size and no overflow:

            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current lap number and timer (always at the top)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0), // <-- Add vertical padding
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentLapNumber',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontFamily: 'Courier',
                              height: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(width: 4),
                          Text(
                            currentLapTimeValue,
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 376 ? 20 : 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontFamily: 'Courier',
                              height: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Last two lap rows
                  if (lapEntries.isNotEmpty)
                    ...[
                      for (var i = 0; i < lapEntries.length && i < 2; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0), // <-- Add vertical padding
                          child: GestureDetector(
                            onTap: _showLapTimesDialog,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${lapEntries.length - i}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange[300], 
                                      fontFamily: 'Courier',
                                      height: 1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    lapEntries[i].lapTime,
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width < 376 ? 20 : 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Courier',
                                      height: 1,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
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
    List<int> lapMillis = lapEntries
        .map((e) => _parseDuration(e.lapTime).inMilliseconds)
        .toList();
    int? maxLap = lapMillis.isNotEmpty ? lapMillis.reduce((a, b) => a > b ? a : b) : null;
    int? minLap = lapMillis.isNotEmpty ? lapMillis.reduce((a, b) => a < b ? a : b) : null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$runnerName Lap Times',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
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
                  dense: true,
                  isThreeLine: false,
                  title: Text(
                    'Lap ${lapEntries.length - index}: ${entry.lapTime}   Split: ${entry.splitTime}',
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: lapMs == maxLap
                      ? Text('Min', style: TextStyle(color: Colors.red, fontSize: 14))
                      : lapMs == minLap
                          ? Text('Max', style: TextStyle(color: Colors.green, fontSize: 14))
                          : null,
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