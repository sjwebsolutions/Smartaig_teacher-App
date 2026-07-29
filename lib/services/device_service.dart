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
      // Many backends only support 16-char alphanumeric UUIDs (Android format).
      // We clean it by removing hyphens, lowercasing, and taking the first 16 chars.
      final rawUuid = ios.identifierForVendor ?? "";
      final cleanUuid = rawUuid.replaceAll('-', '').toLowerCase();
      final formattedUuid = cleanUuid.length > 16 ? cleanUuid.substring(0, 16) : cleanUuid;

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