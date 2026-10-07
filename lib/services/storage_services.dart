
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";
  static String? _cachedToken;
  //static const _fcmTokenKey = "fcm_token";

  //SAVE TOKEN
  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  //GET TOKEN
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  //DELETE TOKEN(LOGOUT)
  static Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _bannerIdsKey);
    await _storage.delete(key: _dashboardKey);
  }

  static const _bannerIdsKey = "notified_banner_ids";
  static const _sortTypeKey = "marks_sort_type";
  static const _sortOrderKey = "marks_sort_order";
  static const _dashboardKey = "cached_dashboard_data";

  static Future<void> saveDashboardData(String jsonString) async {
    await _storage.write(key: _dashboardKey, value: jsonString);
  }

  static Future<String?> getDashboardData() async {
    return await _storage.read(key: _dashboardKey);
  }

  static Future<void> saveNotifiedBannerIds(String ids) async {
    await _storage.write(key: _bannerIdsKey, value: ids);
  }

  static Future<String?> getNotifiedBannerIds() async {
    return await _storage.read(key: _bannerIdsKey);
  }

  static Future<void> saveMarksSortType(String type) async {
    await _storage.write(key: _sortTypeKey, value: type);
  }

  static Future<String?> getMarksSortType() async {
    return await _storage.read(key: _sortTypeKey);
  }

  static Future<void> saveMarksSortOrder(bool isAscending) async {
    await _storage.write(key: _sortOrderKey, value: isAscending.toString());
  }

  static Future<bool?> getMarksSortOrder() async {
    String? val = await _storage.read(key: _sortOrderKey);
    if (val == null) return null;
    return val == "true";
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
