import 'package:dio/dio.dart';
import 'package:teacher_app_attendance/models/attendance_model.dart';
import 'package:teacher_app_attendance/utils/api_url.dart';
import 'package:teacher_app_attendance/utils/dio_client.dart';

class AttendanceServices {
  Future<TeacherAttendanceModel> markAttendance({
    required String qrToken,
    required double latitude,
    required double longitude,
  }) async {
    try {
      print("Request:");
      print("OR: $qrToken");
      print("lat: $latitude");
      print("lng: $longitude");

      final response = await DioClient.dio.post(
        ApiUrls.attendance,
        data: {
          "qr_token": qrToken,
          "latitude": latitude,
          "longitude": longitude,
        },

      );
      print("response: ");
      print(response.data.toString());
      return TeacherAttendanceModel.fromJson(response.data);
    } on DioException catch (e) {
      print("STATUS: ${e.response?.statusCode}");
      print("BODY: ${e.response?.data}");

      throw e.response?.data["message"] ?? "Attendance failed";


    }catch (e) {
      throw "Something went wrong";
    }
  }
  Future<bool> deleteTodayAttendance() async {
    try {
      final response = await DioClient.dio.delete(
        ApiUrls.deleteattendance,
      );

      return response.data["success"] == true;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Delete attendance failed";
    }
  }



}
