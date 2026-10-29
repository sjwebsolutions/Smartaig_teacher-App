
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";
  static String? _cachedToken;
  static String? _cachedProfileImagePath;
  static String? _cachedDashboardData;
  static String? _cachedProfileImageUrl;
  static String? _cachedBannersData;
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
    _cachedProfileImagePath = null;
    _cachedDashboardData = null;
    _cachedProfileImageUrl = null;
    _cachedBannersData = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _bannerIdsKey);
    await _storage.delete(key: _dashboardKey);
    await _storage.delete(key: _profileImageUrlKey);
    await _storage.delete(key: _profileImagePathKey);
    await _storage.delete(key: _bannersKey);
  }

  static const _bannerIdsKey = "notified_banner_ids";
  static const _sortTypeKey = "marks_sort_type";
  static const _sortOrderKey = "marks_sort_order";
  static const _dashboardKey = "cached_dashboard_data";
  static const _bannersKey = "cached_banners_data";
  static const _profileImageUrlKey = "cached_profile_image_url";
  static const _profileImagePathKey = "cached_profile_image_path";

  static Future<void> saveBannerData(String jsonString) async {
    _cachedBannersData = jsonString;
    await _storage.write(key: _bannersKey, value: jsonString);
  }

  static Future<String?> getBannerData() async {
    if (_cachedBannersData != null) return _cachedBannersData;
    _cachedBannersData = await _storage.read(key: _bannersKey);
    return _cachedBannersData;
  }

  static Future<void> saveProfileImageUrl(String url) async {
    _cachedProfileImageUrl = url;
    await _storage.write(key: _profileImageUrlKey, value: url);
  }

  static Future<String?> getProfileImageUrl() async {
    if (_cachedProfileImageUrl != null) return _cachedProfileImageUrl;
    _cachedProfileImageUrl = await _storage.read(key: _profileImageUrlKey);
    return _cachedProfileImageUrl;
  }

  static Future<void> saveProfileImagePath(String path) async {
    _cachedProfileImagePath = path;
    await _storage.write(key: _profileImagePathKey, value: path);
  }

  static Future<String?> getProfileImagePath() async {
    if (_cachedProfileImagePath != null) return _cachedProfileImagePath;
    _cachedProfileImagePath = await _storage.read(key: _profileImagePathKey);
    return _cachedProfileImagePath;
  }

  static Future<void> saveDashboardData(String jsonString) async {
    _cachedDashboardData = jsonString;
    await _storage.write(key: _dashboardKey, value: jsonString);
  }

  static Future<String?> getDashboardData() async {
    if (_cachedDashboardData != null) return _cachedDashboardData;
    _cachedDashboardData = await _storage.read(key: _dashboardKey);
    return _cachedDashboardData;
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
