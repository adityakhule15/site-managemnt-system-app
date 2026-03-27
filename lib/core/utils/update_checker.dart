import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../theme/app_palette.dart';

class UpdateChecker {
  static Future<void> checkForUpdate(
      BuildContext context,
      String latestVersion,
      String latestBuildNumber,
      ) async {
    try {
      // Validate inputs
      if (!_isValidVersion(latestVersion) || !_isValidBuildNumber(latestBuildNumber)) {
        return;
      }

      final packageInfo = await PackageInfo.fromPlatform();

      if (isUpdateAvailable(
        packageInfo.version,
        latestVersion,
        packageInfo.buildNumber,
        latestBuildNumber,
      )) {
        if (context.mounted) {
          showCustomUpdateDialog(context, packageInfo.packageName);
        }
      }
    } on PlatformException catch (e) {
    } catch (e) {
    }
  }

  static bool _isValidVersion(String version) {
    return version.isNotEmpty && RegExp(r'^\d+(\.\d+)*$').hasMatch(version);
  }

  static bool _isValidBuildNumber(String build) {
    return build.isNotEmpty && int.tryParse(build) != null;
  }

  static bool isUpdateAvailable(String currentVersion, String latestVersion, String currentBuild, String latestBuild) {
    // Split versions into parts (e.g., 1.2.3 -> [1,2,3])
    List<int> currentVer = currentVersion.split('.').map(int.parse).toList();
    List<int> latestVer = latestVersion.split('.').map(int.parse).toList();

    // Compare versions
    for (int i = 0; i < latestVer.length; i++) {
      if (i >= currentVer.length || latestVer[i] > currentVer[i]) {
        return true;
      } else if (latestVer[i] < currentVer[i]) {
        return false;
      }
    }

    // If versions are the same, compare build numbers
    return int.parse(latestBuild) > int.parse(currentBuild);
  }

  static void showCustomUpdateDialog(BuildContext context, String packageName) {
    final isIOS = Platform.isIOS;
    final storeName = isIOS ? 'App Store' : 'Google Play';
    final iconAsset = isIOS
        ? 'assets/images/app_store_icon.png' // iOS App Store icon
        : 'assets/images/icons8-google-play-store-48.png'; // Google Play icon

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false, // This is the key property
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
          contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 10),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          title: const Text("Update Required", style: TextStyle(fontFamily: 'MuktaMedium')),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                "A new version of the app is available. Please update to continue.",
                style: TextStyle(fontFamily: 'MuktaMedium', fontSize: 16),
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      launchAppStore(packageName, context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF255F38),
                      shape: BeveledRectangleBorder(),
                    ),
                    child: const Text(
                      "UPDATE",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    iconAsset,
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    storeName,
                    style: const TextStyle(fontSize: 18, color: Palette.greyColor),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  static void showUpdateDialog(BuildContext context, String packageName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        surfaceTintColor: Palette.whiteColor,
        backgroundColor: Palette.whiteColor,
        title: const Text("Update Required", style: TextStyle(fontFamily: 'MuktaMedium')),
        content: const Text(
          "A new version of the app is available. Please update to continue.",
          style: TextStyle(fontFamily: 'MuktaMedium', fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              launchAppStore(packageName, context);
            },
            child: const Text(
              "Update",
              style: TextStyle(fontFamily: 'MuktaBold', color: Palette.gradient2, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> launchAppStore(String packageName, BuildContext context) async {
    String url;

    if (Platform.isIOS) {
      // For iOS App Store
      url = 'https://apps.apple.com/app/id$packageName'; // Use your actual App Store ID
      // If you have the app name instead of ID, use: 'https://apps.apple.com/us/app/app-name/id$packageName'
    } else {
      // For Android Play Store
      url = 'https://play.google.com/store/apps/details?id=$packageName';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }
}