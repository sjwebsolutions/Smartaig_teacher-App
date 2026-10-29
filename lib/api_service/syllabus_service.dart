import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/syllabus_model.dart';
import '../models/syllabus_form_data_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class SyllabusService {
  Future<SyllabusModel> getSyllabus(int studentId) async {
    try {
      final url = ApiUrls.syllabus(studentId);
      final response = await DioClient.dio.get(url);
      
      if (response.statusCode == 200) {
        return SyllabusModel.fromJson(response.data);
      } else {
        throw "Failed to load syllabus";
      }
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch syllabus";
    } catch (e) {
      throw "An unexpected error occurred while fetching syllabus";
    }
  }

  Future<SyllabusModel> getTeacherSyllabus({int? termId, int? classId, int? subjectId}) async {
    try {
      print("--- FETCHING TEACHER SYLLABUS ---");
      final response = await DioClient.dio.get(
        ApiUrls.teacherSyllabus,
        queryParameters: {
          if (termId != null) 'term_id': termId,
          if (classId != null) 'class_id': classId,
          if (subjectId != null) 'subject_id': subjectId,
        },
      );
      
      if (response.statusCode == 200) {
        return SyllabusModel.fromJson(response.data);
      } else {
        throw "Failed to load teacher syllabus";
      }
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch teacher syllabus";
    } catch (e) {
      throw "An unexpected error occurred while fetching teacher syllabus";
    }
  }

  Future<SyllabusModel> getSyllabusById(int id) async {
    try {
      final response = await DioClient.dio.get("${ApiUrls.teacherSyllabus}/$id");
      if (response.statusCode == 200) {
        return SyllabusModel.fromJson(response.data);
      } else {
        throw "Failed to load specific syllabus";
      }
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch specific syllabus";
    } catch (e) {
      throw "An unexpected error occurred while fetching specific syllabus";
    }
  }

  Future<SyllabusFormDataModel> getSyllabusFormData() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.syllabusFormData);
      if (response.statusCode == 200) {
        return SyllabusFormDataModel.fromJson(response.data);
      } else {
        throw "Failed to load syllabus form data";
      }
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch syllabus form data";
    } catch (e) {
      throw "An unexpected error occurred while fetching syllabus form data";
    }
  }

  Future<SyllabusModel> storeSyllabus({
    required String title,
    required int termId,
    String? description,
    String? content,
    required String targetsJson, // JSON string of targets
    int? subjectId,
    List<File>? attachments,
  }) async {
    try {
      debugPrint("🚀 [SyllabusService] STORE SYLLABUS REQUEST:");
      debugPrint("📍 URL: ${ApiUrls.teacherSyllabus}");
      debugPrint("📝 Title: $title");
      debugPrint("📅 Term ID: $termId");
      debugPrint("📚 Subject ID: $subjectId");
      debugPrint("🎯 Targets JSON: $targetsJson");
      debugPrint("📄 Description: $description");
      debugPrint("📎 Attachments Count: ${attachments?.length ?? 0}");

      final Map<String, dynamic> body = {
        "title": title,
        "term_id": termId,
        "description": description,
        "content": content,
        "targets": targetsJson,
        "subject_id": subjectId,
      };

      final formData = FormData.fromMap(body);

      if (attachments != null && attachments.isNotEmpty) {
        for (var file in attachments) {
          debugPrint("📎 Attaching File: ${file.path}");
          formData.files.add(MapEntry(
            "attachments[]",
            await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ));
        }
      }

      final response = await DioClient.dio.post(
        ApiUrls.teacherSyllabus,
        data: formData,
      );

      debugPrint("✅ [SyllabusService] STORE RESPONSE (${response.statusCode}): ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return SyllabusModel.fromJson(response.data);
      } else {
        throw "Failed to upload syllabus";
      }
    } on DioException catch (e) {
      debugPrint("❌ [SyllabusService] DioError: ${e.response?.statusCode} - ${e.response?.data}");
      throw e.response?.data["message"] ?? "Failed to store syllabus";
    } catch (e) {
      debugPrint("❌ [SyllabusService] Exception: $e");
      throw "An unexpected error occurred while storing syllabus";
    }
  }

  Future<SyllabusModel> updateSyllabus({
    required int id,
    required String title,
    required int termId,
    String? description,
    String? content,
    required String targetsJson,
    int? subjectId,
    List<File>? attachments,
    List<String>? deleteAttachmentPaths,
  }) async {
    try {
      final url = "${ApiUrls.teacherSyllabus}/$id";
      debugPrint("🚀 [SyllabusService] UPDATE SYLLABUS REQUEST:");
      debugPrint("📍 URL: $url");
      debugPrint("🆔 ID: $id");
      debugPrint("📝 Title: $title");
      debugPrint("📅 Term ID: $termId");
      debugPrint("📚 Subject ID: $subjectId");
      debugPrint("🎯 Targets JSON: $targetsJson");
      debugPrint("🗑️ Delete Attachments: $deleteAttachmentPaths");
      debugPrint("📎 New Attachments Count: ${attachments?.length ?? 0}");

      final Map<String, dynamic> body = {
        "title": title,
        "term_id": termId,
        "description": description,
        "content": content,
        "targets": targetsJson,
        "subject_id": subjectId,
      };

      final formData = FormData.fromMap(body);

      if (attachments != null && attachments.isNotEmpty) {
        for (var file in attachments) {
          formData.files.add(MapEntry(
            "attachments[]",
            await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ));
        }
      }

      if (deleteAttachmentPaths != null && deleteAttachmentPaths.isNotEmpty) {
        for (var path in deleteAttachmentPaths) {
          formData.fields.add(MapEntry("delete_attachments[]", path));
        }
      }

      final response = await DioClient.dio.post(
        url,
        data: formData,
      );

      debugPrint("✅ [SyllabusService] UPDATE RESPONSE (${response.statusCode}): ${response.data}");

      if (response.statusCode == 200) {
        return SyllabusModel.fromJson(response.data);
      } else {
        throw "Failed to update syllabus";
      }
    } on DioException catch (e) {
      debugPrint("❌ [SyllabusService] DioError: ${e.response?.statusCode} - ${e.response?.data}");
      throw e.response?.data["message"] ?? "Failed to update syllabus";
    } catch (e) {
      debugPrint("❌ [SyllabusService] Exception: $e");
      throw "An unexpected error occurred while updating syllabus";
    }
  }

  Future<Map<String, dynamic>> toggleSyllabusStatus(int id) async {
    try {
      final response = await DioClient.dio.post("${ApiUrls.teacherSyllabus}/$id/toggle-status");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw "Failed to toggle status";
      }
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to toggle status";
    } catch (e) {
      throw "An unexpected error occurred while toggling syllabus status";
    }
  }
}
