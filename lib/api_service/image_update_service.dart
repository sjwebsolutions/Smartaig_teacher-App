import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/image_update_students_model.dart';
import '../models/image_update_classes_model.dart';
import '../models/image_update_form_options_model.dart';
import '../models/image_update_store_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';
import 'package:dio/dio.dart';

class ImageUpdateService {
  Future<ImageUpdateClassesModel> getImageUpdateClasses() async {
    try {
      debugPrint("--- START GET IMAGE UPDATE CLASSES ---");
      debugPrint("URL: ${ApiUrls.studentImageUpdateClasses}");
      final response = await DioClient.dio.get(ApiUrls.studentImageUpdateClasses);
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RESPONSE DATA: ${response.data}");

      if (response.data is Map<String, dynamic>) {
        return ImageUpdateClassesModel.fromJson(response.data);
      } else if (response.data is String) {
        return ImageUpdateClassesModel.fromJson(jsonDecode(response.data));
      }
      return ImageUpdateClassesModel(success: false, data: []);
    } on DioException catch (e) {
      debugPrint("DIO ERROR: ${e.message}");
      debugPrint("DIO RESPONSE: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to fetch image update classes");
    } catch (e) {
      debugPrint("GENERAL ERROR: $e");
      throw "An unexpected error occurred while fetching classes: $e";
    }
  }

  Future<ImageUpdateFormOptionsModel> getImageUpdateFormOptions() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.studentImageUpdateFormOptions);
      if (response.data is Map<String, dynamic>) {
        return ImageUpdateFormOptionsModel.fromJson(response.data);
      } else if (response.data is String) {
        return ImageUpdateFormOptionsModel.fromJson(jsonDecode(response.data));
      }
      return ImageUpdateFormOptionsModel(success: false);
    } on DioException catch (e) {
      throw DioClient.getErrorMessage(e, "Failed to fetch form options");
    } catch (e) {
      throw "Failed to fetch form options: $e";
    }
  }

  Future<ImageUpdateStudentsModel> getImageUpdateStudents(int classId, int sectionId, int? streamId) async {
    try {
      debugPrint("--- START GET IMAGE UPDATE STUDENTS ---");
      debugPrint("URL: ${ApiUrls.studentImageUpdateStudents}?class_id=$classId&section_id=$sectionId&stream_id=${streamId ?? ''}");
      final response = await DioClient.dio.get(
        ApiUrls.studentImageUpdateStudents,
        queryParameters: {
          'class_id': classId,
          'section_id': sectionId,
          if (streamId != null && streamId > 0) 'stream_id': streamId,
        },
      );
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RESPONSE DATA: ${response.data}");

      if (response.data is Map<String, dynamic>) {
        return ImageUpdateStudentsModel.fromJson(response.data);
      } else if (response.data is String) {
        return ImageUpdateStudentsModel.fromJson(jsonDecode(response.data));
      }
      return ImageUpdateStudentsModel(success: false, data: []);
    } on DioException catch (e) {
      debugPrint("DIO ERROR: ${e.message}");
      throw DioClient.getErrorMessage(e, "Failed to fetch students");
    } catch (e) {
      debugPrint("GENERAL ERROR: $e");
      throw "An unexpected error occurred while fetching students: $e";
    }
  }

  Future<ImageUpdateStoreResponse> storeImageUpdate(ImageUpdateStoreRequest request) async {
    try {
      final Map<String, dynamic> data = request.toMap();
      debugPrint("==========================================");
      debugPrint("🌐 [ImageUpdateService] POST Request to: ${ApiUrls.studentImageUpdateStore}");
      debugPrint("Payload Map: $data");
      debugPrint("Profile Image File: ${request.profileImage}");
      debugPrint("Father Image File: ${request.fatherImage}");
      debugPrint("Mother Image File: ${request.motherImage}");
      debugPrint("==========================================");

      final formData = FormData.fromMap(data);

      if (request.profileImage != null) {
        formData.files.add(MapEntry(
          'profile_image',
          await MultipartFile.fromFile(request.profileImage!),
        ));
      }

      if (request.fatherImage != null) {
        formData.files.add(MapEntry(
          'father_image',
          await MultipartFile.fromFile(request.fatherImage!),
        ));
      }

      if (request.motherImage != null) {
        formData.files.add(MapEntry(
          'mother_image',
          await MultipartFile.fromFile(request.motherImage!),
        ));
      }

      final response = await DioClient.dio.post(
        ApiUrls.studentImageUpdateStore,
        data: formData,
      );

      if (response.data is Map<String, dynamic>) {
        return ImageUpdateStoreResponse.fromJson(response.data);
      } else if (response.data is String) {
        return ImageUpdateStoreResponse.fromJson(jsonDecode(response.data));
      }
      return ImageUpdateStoreResponse(success: false, message: "Invalid response from server");
    } on DioException catch (e) {
      throw DioClient.getErrorMessage(e, "Failed to submit request");
    } catch (e) {
      throw "Failed to submit request: $e";
    }
  }
}
