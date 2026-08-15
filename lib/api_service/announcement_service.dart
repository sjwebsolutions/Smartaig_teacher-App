import 'package:dio/dio.dart';
import '../models/announcement_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class AnnouncementService {
  Future<AnnouncementModel> getAnnouncements() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.announcements);
      return AnnouncementModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch announcements";
    }
  }

  Future<void> createAnnouncement(Map<String, dynamic> data, {String? imagePath}) async {
    try {
      FormData formData = FormData.fromMap(data);
      if (imagePath != null) {
        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(imagePath),
        ));
      }
      await DioClient.dio.post(ApiUrls.announcements, data: formData);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to create announcement";
    }
  }
}
