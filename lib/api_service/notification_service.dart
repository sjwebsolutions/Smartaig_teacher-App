import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class NotificationService {
  Future<NotificationResponseModel> getNotifications({int page = 1, int perPage = 30}) async {
    try {
      final response = await DioClient.dio.get(
        ApiUrls.notifications,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      return NotificationResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch notifications";
    } catch (e) {
      throw "Failed to fetch notifications: $e";
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.unreadNotificationsCount);
      final model = UnreadCountResponseModel.fromJson(response.data);
      return model.data?.unreadCount ?? 0;
    } catch (e) {
      print("Error fetching unread count: $e");
      return 0;
    }
  }

  Future<bool> markAllRead() async {
    try {
      await DioClient.dio.post("${ApiUrls.notifications}/mark-all-read");
      return true;
    } catch (_) {
      try {
        await DioClient.dio.post("${ApiUrls.notifications}/read-all");
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<bool> markAsRead(dynamic id) async {
    try {
      await DioClient.dio.post("${ApiUrls.notifications}/$id/mark-as-read");
      return true;
    } catch (_) {
      try {
        await DioClient.dio.post("${ApiUrls.notifications}/$id/read");
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}
