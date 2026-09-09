import 'package:dio/dio.dart';
import 'package:teacher_app_attendance/models/support_settings_model.dart';
import 'package:teacher_app_attendance/utils/api_url.dart';
import 'package:teacher_app_attendance/utils/dio_client.dart';

class SupportService {
  Future<SupportSettingsModel> getSupportSettings() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.supportSettings);
      print("SUPPORT SETTINGS RESPONSE: ${response.data}");
      return SupportSettingsModel.fromJson(response.data);
    } on DioException catch (e) {
      print("SUPPORT SETTINGS DIO ERROR: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to fetch support settings");
    } catch (e) {
      print("SUPPORT SETTINGS GENERAL ERROR: $e");
      throw "Failed to fetch support settings";
    }
  }
}
