import 'dart:io';

void main() {
  print('Testing Timer Format Conversion...\n');

  // Test the corrected _formatTime function
  String formatTime(int milliseconds) {
    // Convert to centiseconds (1/100 second) format: MM:SS:CC
    final int centiseconds = (milliseconds / 10).truncate();
    final int seconds = (centiseconds / 100).truncate();
    final int minutes = (seconds / 60).truncate();
    final String centisecondsStr =
        (centiseconds % 100).toString().padLeft(2, '0');
    final String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    final String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr:$centisecondsStr';
  }

  // Test cases
  print('Testing various time values:');
  print('0 ms = ${formatTime(0)}         (should be 00:00:00)');
  print(
      '100 ms = ${formatTime(100)}     (should be 00:00:10 - 10 centiseconds)');
  print('1000 ms = ${formatTime(1000)}   (should be 00:01:00 - 1 second)');
  print('10000 ms = ${formatTime(10000)} (should be 00:10:00 - 10 seconds)');
  print('60000 ms = ${formatTime(60000)} (should be 01:00:00 - 1 minute)');
  print(
      '65432 ms = ${formatTime(65432)} (should be 01:05:43 - 1 min 5.43 sec)');

  print('\n✅ Timer format verification complete!');
  print('Format: MM:SS:CC (Minutes:Seconds:Centiseconds)');
  print('Update interval: 10ms (1 centisecond)');
}
