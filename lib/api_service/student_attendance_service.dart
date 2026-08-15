import 'package:dio/dio.dart';
import 'package:teacher_app_attendance/models/class_list_model.dart';
import 'package:teacher_app_attendance/models/student_list_model.dart';
import 'package:teacher_app_attendance/utils/api_url.dart';
import 'package:teacher_app_attendance/utils/dio_client.dart';

class StudentAttendanceService {
  Future<ClassListModel> getInchargeClasses() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.inchargeClasses);
      return ClassListModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch classes";
    }
  }

  Future<StudentListModel> getStudentList({
    String? streamId,
    required String classId,
    required String sectionId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'class_id': classId,
        'section_id': sectionId,
      };
      if (streamId != null && streamId.isNotEmpty && streamId != "null") {
        queryParams['stream_id'] = streamId;
      }

      final response = await DioClient.dio.get(
        ApiUrls.studentList,
        queryParameters: queryParams,
      );
      return StudentListModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch students";
    }
  }

  Future<bool> submitAttendance({
    String? streamId,
    required String classId,
    required String sectionId,
    required Map<String, dynamic> attendance,
  }) async {
    try {
      final Map<String, dynamic> bodyData = {
        'class_id': classId,
        'section_id': sectionId,
        'attendance': attendance,
      };

      if (streamId != null && streamId.isNotEmpty && streamId != "null") {
        bodyData['stream_id'] = streamId;
      }

      final response = await DioClient.dio.post(
        ApiUrls.storeAttendance,
        data: bodyData,
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to submit attendance";
    }
  }
}
