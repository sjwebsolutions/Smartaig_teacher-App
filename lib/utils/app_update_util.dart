import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import 'app_snackbar.dart';

class AppUpdateUtil {
  static const String androidPackageName = "com.smartaig.teachers.app";
  static const String iOSAppId = "6740880352";
  static const String defaultPlayStoreUrl =
      "https://play.google.com/store/apps/details?id=$androidPackageName";
  static const String defaultAppStoreUrl =
      "https://apps.apple.com/app/id$iOSAppId";

  /// Checks store for new app version and opens update dialog if available.
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool showToastIfLatest = false,
    bool forceUpdate = false,
  }) async {
    // Skip update check in debug mode
    if (kDebugMode) {
      debugPrint("AppUpdateUtil -> Skipping update check in debug mode.");
      if (showToastIfLatest) {
        try {
          final PackageInfo packageInfo = await PackageInfo.fromPlatform();
          final cleanVersion =
              packageInfo.version.replaceAll(RegExp(r'^[vV]'), '').trim();
          AppSnackBar.success(
              "Debug mode: App update check is disabled ($cleanVersion)");
        } catch (_) {}
      }
      return;
    }

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      bool updateAvailable = false;
      String? latestVersion;
      String? storeUrl;
      bool useInAppUpdateNative = false;

      if (Platform.isAndroid) {
        // 1. Try Official Google Play In-App Update API first
        try {
          final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
          debugPrint(
              "AppUpdateUtil -> InAppUpdate check result: ${updateInfo.updateAvailability}");
          if (updateInfo.updateAvailability ==
              UpdateAvailability.updateAvailable) {
            updateAvailable = true;
            useInAppUpdateNative = true;
            storeUrl = defaultPlayStoreUrl;
          }
        } catch (e) {
          debugPrint(
              "AppUpdateUtil -> InAppUpdate check exception (fallback to scraping): $e");
        }

        // 2. Fetch Android store version for version string display or fallback check
        final androidResult = await _fetchAndroidStoreVersion();
        if (androidResult['version'] != null) {
          latestVersion = androidResult['version'];
          if (!updateAvailable &&
              isVersionNewer(latestVersion!, currentVersion)) {
            updateAvailable = true;
          }
        } else if (updateAvailable) {
          latestVersion = "New Version";
        }
      } else if (Platform.isIOS) {
        final iosResult = await _fetchIosStoreVersion();
        latestVersion = iosResult['version'];
        storeUrl = iosResult['url'];
        if (latestVersion != null &&
            isVersionNewer(latestVersion, currentVersion)) {
          updateAvailable = true;
        }
      }

      debugPrint("AppUpdateUtil -> Current Version: $currentVersion");
      debugPrint("AppUpdateUtil -> Latest Store Version: $latestVersion");

      if (updateAvailable) {
        if (context.mounted) {
          showUpdateDialog(
            context,
            currentVersion: currentVersion,
            latestVersion: latestVersion ?? "New Version",
            storeUrl: storeUrl,
            forceUpdate: forceUpdate,
            useInAppUpdateNative: useInAppUpdateNative,
          );
        }
      } else {
        if (showToastIfLatest) {
          final cleanVersion =
              currentVersion.replaceAll(RegExp(r'^[vV]'), '').trim();
          AppSnackBar.success("Your app is up to date ($cleanVersion)");
        }
      }
    } catch (e) {
      debugPrint("AppUpdateUtil -> Error checking for update: $e");
    }
  }

  /// Fetches latest version from Apple App Store using iTunes Lookup API
  static Future<Map<String, String?>> _fetchIosStoreVersion() async {
    try {
      final dio = Dio();
      // Try by App Store ID first
      var response = await dio.get(
        "https://itunes.apple.com/lookup?id=$iOSAppId",
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['resultCount'] > 0) {
        final result = response.data['results'][0];
        final String? version = result['version']?.toString();
        final String? trackViewUrl = result['trackViewUrl']?.toString();
        return {
          'version': version,
          'url': trackViewUrl ?? defaultAppStoreUrl,
        };
      }

      // Fallback by bundleId
      response = await dio.get(
        "https://itunes.apple.com/lookup?bundleId=$androidPackageName&country=in",
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['resultCount'] > 0) {
        final result = response.data['results'][0];
        final String? version = result['version']?.toString();
        final String? trackViewUrl = result['trackViewUrl']?.toString();
        return {
          'version': version,
          'url': trackViewUrl ?? defaultAppStoreUrl,
        };
      }
    } catch (e) {
      debugPrint("AppUpdateUtil -> Error fetching iOS store version: $e");
    }
    return {'version': null, 'url': defaultAppStoreUrl};
  }

  /// Fetches latest version from Google Play Store detail page using robust patterns
  static Future<Map<String, String?>> _fetchAndroidStoreVersion() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        "https://play.google.com/store/apps/details?id=$androidPackageName&hl=en",
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
          headers: {
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final String htmlContent = response.data.toString();

        final List<RegExp> regexes = [
          RegExp(r'\[\[\["([0-9]+\.[0-9]+\.[0-9]+)"\]'),
          RegExp(r'"version":\s*"([0-9]+\.[0-9]+\.[0-9]+)"'),
          RegExp(r'\["([0-9]+\.[0-9]+\.[0-9]+)",\s*\['),
          RegExp(r'AF_initDataCallback.*?([0-9]+\.[0-9]+\.[0-9]+)'),
        ];

        for (final reg in regexes) {
          final match = reg.firstMatch(htmlContent);
          if (match != null && match.group(1) != null) {
            return {
              'version': match.group(1),
              'url': defaultPlayStoreUrl,
            };
          }
        }
      }
    } catch (e) {
      debugPrint("AppUpdateUtil -> Error fetching Android store version: $e");
    }
    return {'version': null, 'url': defaultPlayStoreUrl};
  }

  /// Compares store version and installed current version.
  /// Returns true if store version is higher than current installed version.
  static bool isVersionNewer(String storeVersion, String currentVersion) {
    try {
      final cleanStore = storeVersion.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanCurrent = currentVersion.replaceAll(RegExp(r'[^0-9.]'), '');

      List<int> storeParts =
          cleanStore.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> currentParts =
          cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      int maxLength = storeParts.length > currentParts.length
          ? storeParts.length
          : currentParts.length;

      for (int i = 0; i < maxLength; i++) {
        int storePart = i < storeParts.length ? storeParts[i] : 0;
        int currentPart = i < currentParts.length ? currentParts[i] : 0;

        if (storePart > currentPart) return true;
        if (storePart < currentPart) return false;
      }
    } catch (e) {
      debugPrint("AppUpdateUtil -> Version comparison error: $e");
    }
    return false;
  }

  /// Redirects user to Google Play Store or Apple App Store
  static Future<void> launchStore({
    String? customUrl,
    bool useInAppUpdateNative = false,
  }) async {
    if (Platform.isAndroid && useInAppUpdateNative) {
      try {
        await InAppUpdate.performImmediateUpdate();
        return;
      } catch (e) {
        debugPrint(
            "AppUpdateUtil -> performImmediateUpdate failed, opening Play Store URL: $e");
      }
    }

    String url = customUrl ?? "";
    if (url.isEmpty) {
      url = Platform.isIOS ? defaultAppStoreUrl : defaultPlayStoreUrl;
    }

    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final Uri fallbackUri = Uri.parse(
          Platform.isIOS ? defaultAppStoreUrl : defaultPlayStoreUrl,
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("AppUpdateUtil -> Error launching store: $e");
    }
  }

  /// Displays the modern Update Dialog with Update & Cancel buttons
  static void showUpdateDialog(
    BuildContext context, {
    required String currentVersion,
    required String latestVersion,
    String? storeUrl,
    bool forceUpdate = false,
    bool useInAppUpdateNative = false,
  }) {
    final String formattedCurrent =
        currentVersion.replaceAll(RegExp(r'^[vV]'), '').trim();
    final String formattedLatest =
        latestVersion.replaceAll(RegExp(r'^[vV]'), '').trim();

    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: !forceUpdate,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 10,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Banner with Rocket/Update Icon
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF233263),
                          Color(0xFF1B264F),
                          Color(0xFF141C3A),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.system_update_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "New Version Available! 🚀",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "A new version is available! Please update the app to get the latest features and better performance.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5563),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Version Comparison Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Current: $formattedCurrent",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  "Latest: $formattedLatest",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons: Update & Cancel
                        Row(
                          children: [
                            // Cancel / Later Button (Hidden if forceUpdate = true)
                            if (!forceUpdate) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    if (Get.isDialogOpen ?? false) {
                                      Get.back();
                                    } else {
                                      Navigator.of(dialogContext).pop();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                      horizontal: 8,
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Update Now Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  launchStore(
                                    customUrl: storeUrl,
                                    useInAppUpdateNative:
                                        useInAppUpdateNative,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                    horizontal: 8,
                                  ),
                                  elevation: 2,
                                  shadowColor:
                                      AppColors.primary.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.system_update_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "Update Now",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
