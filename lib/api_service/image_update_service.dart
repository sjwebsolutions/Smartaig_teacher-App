import '../models/image_update_students_model.dart';
import '../models/image_update_classes_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';
import 'package:dio/dio.dart';

class ImageUpdateService {
  Future<ImageUpdateClassesModel> getImageUpdateClasses() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.studentImageUpdateClasses);
      return ImageUpdateClassesModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch image update classes";
    }
  }

  Future<ImageUpdateStudentsModel> getImageUpdateStudents(int classId, int sectionId, int? streamId) async {
    try {
      final response = await DioClient.dio.get(
        ApiUrls.studentImageUpdateStudents,
        queryParameters: {
          'class_id': classId,
          'section_id': sectionId,
          'stream_id': streamId ?? "",
        },
      );
      return ImageUpdateStudentsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch students";
    }
  }

  Future<bool> storeImageUpdate({
    required int studentId,
    String? profileImagePath,
    String? fatherImagePath,
    String? motherImagePath,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'student_id': studentId,
      };

      final formData = FormData.fromMap(data);

      if (profileImagePath != null) {
        formData.files.add(MapEntry(
          'profile_image',
          await MultipartFile.fromFile(profileImagePath),
        ));
      }

      if (fatherImagePath != null) {
        formData.files.add(MapEntry(
          'father_image',
          await MultipartFile.fromFile(fatherImagePath),
        ));
      }

      if (motherImagePath != null) {
        formData.files.add(MapEntry(
          'mother_image',
          await MultipartFile.fromFile(motherImagePath),
        ));
      }

      final response = await DioClient.dio.post(
        ApiUrls.studentImageUpdateStore,
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to submit request";
    }
  }
}
