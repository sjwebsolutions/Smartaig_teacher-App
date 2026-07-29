import 'package:dio/dio.dart';
import '../models/marks_entry_model.dart';
import '../models/marks_entry_classes_model.dart';
import '../models/marks_save_model.dart';
import '../models/marks_student_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class MarksService {
  Future<MarksEntryResponse> getMarksEntries() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.marksEntries);
      return MarksEntryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch marks entries";
    }
  }

  Future<MarksEntryClassesResponse> getMarksEntryClasses(int id) async {
    try {
      final response = await DioClient.dio.get(ApiUrls.marksEntryClasses(id));
      return MarksEntryClassesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch marks entry classes";
    }
  }

  Future<MarksStudentResponse> getStudentsForMarks(int entryId, Map<String, dynamic> params) async {
    try {
      final response = await DioClient.dio.get(
        ApiUrls.marksEntryStudents(entryId),
        queryParameters: params,
      );
      return MarksStudentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch students";
    }
  }

  Future<bool> saveMarks(MarksSaveRequest request) async {
    try {
      final response = await DioClient.dio.post(
        ApiUrls.saveMarks,
        data: request.toJson(),
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to save marks";
    }
  }

  Future<bool> submitMarks(Map<String, dynamic> data) async {
    try {
      final response = await DioClient.dio.post(
        ApiUrls.submitMarks,
        data: data,
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to submit marks";
    }
  }
}
