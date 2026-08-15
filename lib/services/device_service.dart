import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceService {
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    Map<String, String> info = {
      "device_name": "Unknown",
      "device_os": "Unknown",
      "device_uuid": "unknown",
    };

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      info = {
        "device_name": android.model,
        "device_os": "Android ${android.version.release}",
        "device_uuid": android.id,
      };
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      // iOS identifierForVendor has hyphens and is 36 chars.
      final rawUuid = ios.identifierForVendor ?? "";
      // Clean UUID by removing hyphens and lowercasing
      final cleanUuid = rawUuid.replaceAll('-', '').toLowerCase();
      
      // We'll use the full cleaned UUID (32 chars) instead of truncating to 16.
      // Truncating might cause collisions or backend validation failures on iOS.
      final formattedUuid = cleanUuid;

      info = {
        "device_name": ios.name,
        "device_os": "iOS ${ios.systemVersion}",
        "device_uuid": formattedUuid,
      };
    }

    print("GET_DEVICE_INFO: $info");
    return info;
  }
}