import 'package:dio/dio.dart';
import 'package:teacher_app_attendance/models/dashboard_model.dart';
import 'package:teacher_app_attendance/utils/api_url.dart';
import 'package:teacher_app_attendance/utils/dio_client.dart';

class DashboardServices {
  Future<DashboardTeacherModel> getDashboard() async{
    try{
      final response = await DioClient.dio.get(ApiUrls.dashboard);
      return DashboardTeacherModel.fromJson(response.data);
    }on DioException catch (e) {
      throw e.response?.data["message"] ?? "Dashboard fetch fails";
    }
  }
}