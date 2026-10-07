import 'package:dio/dio.dart';
import '../models/student_leave_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class StudentLeaveService {
  Future<StudentLeaveModel> getStudentLeaves({
    required dynamic classId,
    required dynamic sectionId,
    dynamic streamId,
    String? status,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'student_class_id': classId,
        'student_section_id': sectionId,
      };

      if (streamId != null && streamId.toString().isNotEmpty && streamId.toString() != "null") {
        queryParams['student_stream_id'] = streamId;
      } else {
        queryParams['student_stream_id'] = "";
      }

      if (status != null && status.isNotEmpty && status != "all") {
        queryParams['status'] = status;
      }

      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      print("--- START GET STUDENT LEAVE ---");
      print("URL: ${ApiUrls.studentLeaves}");
      print("PARAMS: $queryParams");

      final response = await DioClient.dio.get(
        ApiUrls.studentLeaves,
        queryParameters: queryParams,
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200) {
        return StudentLeaveModel.fromJson(response.data);
      } else {
        throw "Failed to load student leave (Status: ${response.statusCode})";
      }
    } on DioException catch (e) {
      print("STUDENT LEAVE DIO ERROR: ${e.message}");
      print("STUDENT LEAVE DIO RESPONSE: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to fetch student leave");
    } catch (e) {
      print("STUDENT LEAVE GENERAL ERROR: $e");
      throw "An unexpected error occurred while fetching student leave: $e";
    }
  }

  Future<bool> approveLeave({required int leaveId, String? remarks}) async {
    try {
      final Map<String, dynamic> body = {
        'leave_id': leaveId,
        'remarks': remarks ?? "",
      };

      Response response;
      try {
        response = await DioClient.dio.post(ApiUrls.approveStudentLeave(leaveId), data: body);
      } on DioException {
        response = await DioClient.dio.post(ApiUrls.approveStudentLeavePost, data: body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      print("APPROVE LEAVE DIO ERROR: ${e.message}");
      throw DioClient.getErrorMessage(e, "Failed to approve leave");
    } catch (e) {
      throw "Error approving leave: $e";
    }
  }

  Future<bool> rejectLeave({required int leaveId, required String rejectionReason}) async {
    try {
      final Map<String, dynamic> body = {
        'leave_id': leaveId,
        'rejection_reason': rejectionReason,
        'reason': rejectionReason,
      };

      Response response;
      try {
        response = await DioClient.dio.post(ApiUrls.rejectStudentLeave(leaveId), data: body);
      } on DioException {
        response = await DioClient.dio.post(ApiUrls.rejectStudentLeavePost, data: body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      print("REJECT LEAVE DIO ERROR: ${e.message}");
      throw DioClient.getErrorMessage(e, "Failed to reject leave");
    } catch (e) {
      throw "Error rejecting leave: $e";
    }
  }
}
