import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/homework_form_data_model.dart';
import '../models/homework_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class HomeworkService {
  Future<HomeworkFormDataModel> getHomeworkFormData() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.homeworkFormData);
      return HomeworkFormDataModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch homework form data";
    }
  }

  Future<HomeworkResponseModel> postHomework({
    required String classId,
    required List<String> sectionIds,
    int? subjectId,
    String? streamId,
    required String content,
    bool isDiary = false,
    List<File>? attachments,
  }) async {
    try {
      final Map<String, dynamic> map = {
        "class_id": classId,
        "content": content,
        "is_diary": isDiary ? 1 : 0,
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      // Add sections as array keys (e.g., section_ids[0], section_ids[1])
      for (int i = 0; i < sectionIds.length; i++) {
        map["section_ids[$i]"] = sectionIds[i];
      }

      // ONLY send subject_id if it's NOT a diary
      if (!isDiary && subjectId != null && subjectId != -1) {
        map["subject_id"] = subjectId.toString();
      }
      
      if (streamId != null && streamId.isNotEmpty) {
        map["stream_id"] = streamId;
      }

      // Add attachments
      if (attachments != null && attachments.isNotEmpty) {
        for (int i = 0; i < attachments.length; i++) {
          map["attachments[$i]"] = await MultipartFile.fromFile(
            attachments[i].path,
            filename: attachments[i].path.split('/').last,
          );
        }
      }

      final formData = FormData.fromMap(map);

      print("POSTING HOMEWORK DATA: $map");

      final response = await DioClient.dio.post(
        ApiUrls.homework,
        data: formData,
      );
      return HomeworkResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print("HOMEWORK API ERROR RESPONSE: ${e.response?.data}");
      
      String errorMessage = "Validation Error";
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data;
        if (data['message'] != null) {
          errorMessage = data['message'];
        }
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          } else {
            errorMessage = firstError.toString();
          }
        }
      }
      throw errorMessage;
    }
  }

  Future<HomeworkListResponseModel> getHomeworkList() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.homework);
      return HomeworkListResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch homework list";
    }
  }

  Future<HomeworkResponseModel> getHomeworkById(int id) async {
    try {
      final response = await DioClient.dio.get("${ApiUrls.homework}/$id");
      return HomeworkResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch homework details";
    }
  }

  Future<HomeworkResponseModel> updateHomework({
    required int id,
    required String classId,
    required List<String> sectionIds,
    int? subjectId,
    String? streamId,
    required String content,
    String? date,
    bool isDiary = false,
    List<File>? attachments,
    List<dynamic>? existingAttachments,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        "id": id,
        "class_id": classId,
        "content": content,
        "is_diary": isDiary ? 1 : 0,
        "date": date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      // Add sections as array keys
      for (int i = 0; i < sectionIds.length; i++) {
        dataMap["section_ids[$i]"] = sectionIds[i];
      }

      // Add existing attachments to keep (optional, depends on API)
      if (existingAttachments != null) {
        for (int i = 0; i < existingAttachments.length; i++) {
          final attachment = existingAttachments[i];
          if (attachment is String) {
            dataMap["existing_attachments[$i]"] = attachment;
          } else if (attachment is Map) {
            dataMap["existing_attachments[$i]"] = attachment['file_url'] ?? attachment['url'] ?? attachment['id']?.toString();
          }
        }
      }

      // ONLY send subject_id if it's NOT a diary
      if (!isDiary && subjectId != null && subjectId != 0 && subjectId != -1) {
        dataMap["subject_id"] = subjectId.toString();
      }
      
      if (streamId != null && streamId.isNotEmpty) {
        dataMap["stream_id"] = streamId;
      }

      // Add attachments if any (Update might replace or add depending on API)
      if (attachments != null && attachments.isNotEmpty) {
        for (int i = 0; i < attachments.length; i++) {
          dataMap["attachments[$i]"] = await MultipartFile.fromFile(
            attachments[i].path,
            filename: attachments[i].path.split('/').last,
          );
        }
      }

      print("UPDATING HOMEWORK ID: $id WITH DATA: $dataMap");

      final formData = FormData.fromMap(dataMap);
      final response = await DioClient.dio.post(
        "${ApiUrls.homework}/$id",
        data: formData,
      );
      
      print("UPDATE RESPONSE FROM SERVER: ${response.data}");

      return HomeworkResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print("HOMEWORK UPDATE ERROR: ${e.response?.data}");
      throw e.response?.data["message"] ?? "Failed to update homework";
    }
  }

  Future<bool> deleteHomework(int id) async {
    try {
      final response = await DioClient.dio.delete("${ApiUrls.homework}/$id");
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to delete homework";
    }
  }
}
