import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

class ShareService {
  static Future<void> shareBanner(String url, String? title, String? message) async {
    try {
      Get.showOverlay(
        asyncFunction: () async {
          // 1. Download image to temp directory
          final tempDir = await getTemporaryDirectory();
          final path = "${tempDir.path}/shared_banner.png";
          
          await Dio().download(url, path);

          // 2. Prepare text content
          String shareText = "";
          if (title != null) shareText += "$title\n";
          if (message != null) shareText += "$message\n";
          shareText += "Shared via Teacher App";

          // 3. Share file
          await Share.shareXFiles(
            [XFile(path)],
            text: shareText,
          );
        },
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to share banner: $e");
    }
  }
}
