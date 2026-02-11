import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

/// App Update Manager - Handles version checking and update prompts
class AppUpdateManager {
  // Platform-specific update check URLs
  static String get _updateCheckUrl {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'https://your-domain.com/rmac-ios-version.json';
    } else {
      return 'https://your-domain.com/rmac-android-version.json';
    }
  }

  // Store URLs for different platforms
  static const String _iosAppStoreUrl =
      'https://apps.apple.com/app/rmac-multitimer/id1234567890';
  static const String _androidPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.rmac.multitimer';

  /// Check for app updates and show appropriate dialog
  static Future<void> checkForUpdates(BuildContext context,
      {bool showNoUpdateDialog = false}) async {
    try {
      final updateInfo = await _fetchUpdateInfo();
      if (updateInfo != null) {
        final currentVersion = await _getCurrentVersion();

        if (_shouldShowUpdateDialog(currentVersion, updateInfo)) {
          if (context.mounted) {
            _showUpdateDialog(context, updateInfo);
          }
        } else if (showNoUpdateDialog && context.mounted) {
          _showNoUpdateDialog(context);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Update check failed: $e');
      }
      // Silently fail - don't interrupt user experience
    }
  }

  /// Fetch update information from your backend/API
  static Future<UpdateInfo?> _fetchUpdateInfo() async {
    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse(_updateCheckUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UpdateInfo.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch update info: $e');
      }
    }
    return null;
  }

  /// Get current app version
  static Future<String> _getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Determine if update dialog should be shown
  static bool _shouldShowUpdateDialog(
      String currentVersion, UpdateInfo updateInfo) {
    final current = _parseVersion(currentVersion);
    final latest = _parseVersion(updateInfo.latestVersion);

    // Show dialog if current version is less than latest
    return _compareVersions(current, latest) < 0;
  }

  /// Parse version string into comparable format
  static List<int> _parseVersion(String version) {
    return version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }

  /// Compare two version arrays
  static int _compareVersions(List<int> version1, List<int> version2) {
    final maxLength =
        [version1.length, version2.length].reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < maxLength; i++) {
      final v1 = i < version1.length ? version1[i] : 0;
      final v2 = i < version2.length ? version2[i] : 0;

      if (v1 < v2) return -1;
      if (v1 > v2) return 1;
    }
    return 0;
  }

  /// Show update dialog
  static void _showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    Future<String> currentVersionFuture = _getCurrentVersion();
    final isForceUpdate = _isForceUpdate(updateInfo);

    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (context) => PopScope(
        canPop: !isForceUpdate,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                isForceUpdate ? Icons.warning : Icons.system_update,
                color: isForceUpdate ? Colors.red : Colors.blue,
              ),
              SizedBox(width: 8),
              Text(isForceUpdate ? 'Update Required' : 'Update Available'),
            ],
          ),
          content: FutureBuilder<String>(
            future: currentVersionFuture,
            builder: (context, snapshot) {
              final currentVersion = snapshot.data ?? 'Unknown';
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isForceUpdate
                        ? 'A critical update is required to continue using the app.'
                        : 'A new version of RMAC MultiTimer is available!',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text('Current Version: $currentVersion'),
                  Text('Latest Version: ${updateInfo.latestVersion}'),
                  if (updateInfo.releaseNotes.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Text('What\'s New:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Container(
                      height: 100,
                      child: SingleChildScrollView(
                        child: Text(updateInfo.releaseNotes),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          actions: [
            if (!isForceUpdate)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Later'),
              ),
            ElevatedButton(
              onPressed: () => _openAppStore(),
              child: Text(isForceUpdate ? 'Update Now' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if this is a force update
  static bool _isForceUpdate(UpdateInfo updateInfo) {
    return updateInfo.forceUpdate;
  }

  /// Show no update available dialog
  static void _showNoUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Up to Date'),
          ],
        ),
        content: Text('You have the latest version of RMAC MultiTimer!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Open appropriate app store
  static Future<void> _openAppStore() async {
    final url = defaultTargetPlatform == TargetPlatform.iOS
        ? _iosAppStoreUrl
        : _androidPlayStoreUrl;

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

/// Update information model
class UpdateInfo {
  final String latestVersion;
  final String minimumVersion;
  final bool forceUpdate;
  final String releaseNotes;
  final String downloadUrl;

  UpdateInfo({
    required this.latestVersion,
    required this.minimumVersion,
    required this.forceUpdate,
    required this.releaseNotes,
    required this.downloadUrl,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latest_version'] ?? '',
      minimumVersion: json['minimum_version'] ?? '',
      forceUpdate: json['force_update'] ?? false,
      releaseNotes: json['release_notes'] ?? '',
      downloadUrl: json['download_url'] ?? '',
    );
  }
}
