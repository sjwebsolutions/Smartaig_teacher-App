
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";
  //static const _fcmTokenKey = "fcm_token";

  //SAVE TOKEN
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  //GET TOKEN
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  //DELETE TOKEN(LOGOUT)
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _bannerIdsKey);
  }

  static const _bannerIdsKey = "notified_banner_ids";

  static Future<void> saveNotifiedBannerIds(String ids) async {
    await _storage.write(key: _bannerIdsKey, value: ids);
  }

  static Future<String?> getNotifiedBannerIds() async {
    return await _storage.read(key: _bannerIdsKey);
  }




  // static Future<void> saveFcmToken(String token) async {
  //   await _storage.write(
  //     key: _fcmTokenKey,
  //     value: token,
  //   );
  // }
  //
  // static Future<String?> getFcmToken() async {
  //   return await _storage.read(
  //     key: _fcmTokenKey,
  //   );
  // }
}
