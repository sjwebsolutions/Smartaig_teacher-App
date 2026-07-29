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

  Future<StudentListModel> getStudentList(String classId, String sectionId) async {
    try {
      final response = await DioClient.dio.get(
        ApiUrls.studentList,
        queryParameters: {
          'class_id': classId,
          'section_id': sectionId,
        },
      );
      return StudentListModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch students";
    }
  }

  Future<bool> submitAttendance({
    required String classId,
    required String sectionId,
    required Map<String, dynamic> attendance,
  }) async {
    try {
      final response = await DioClient.dio.post(
        ApiUrls.storeAttendance,
        data: {
          'class_id': classId,
          'section_id': sectionId,
          'attendance': attendance,
        },
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to submit attendance";
    }
  }
}

