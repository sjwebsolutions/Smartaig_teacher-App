import 'package:dio/dio.dart';
import 'package:teacher_app_attendance/utils/api_url.dart';
import 'package:teacher_app_attendance/utils/dio_client.dart';

import '../models/login_models.dart';
import '../services/device_service.dart';


import '../services/storage_services.dart';

class AuthService {

  Future<bool> sendOtp({required String mobile}) async {
    try {
      final url = ApiUrls.otpRequest;
      final device = await DeviceService.getDeviceInfo();

      final requestData = {
        "whatsapp_number": mobile,
        "device_uuid": device["device_uuid"],
        "device_name": device["device_name"],
        "device_os": device["device_os"],
      };

      print("SEND OTP REQUEST: $url");
      print("PAYLOAD: $requestData");

      final response = await DioClient.dio.post(
        url,
        data: requestData,
      );

      print("SEND OTP RESPONSE: ${response.data}");
      return response.data["success"] == true;
    } on DioException catch (e) {
      print("SEND OTP DIO ERROR: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to send OTP");
    } catch (e) {
      print("SEND OTP GENERAL ERROR: $e");
      throw "Failed to send OTP";
    }
  }

  Future<LoginModel> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      final url = ApiUrls.verifyOtp;
      final device = await DeviceService.getDeviceInfo();

      final requestData = {
        "whatsapp_number": mobile,
        "otp_code": otp,
        "device_uuid": device["device_uuid"],
        "device_name": device["device_name"],
        "device_os": device["device_os"],
      };

      print("VERIFY OTP REQUEST: $url");
      print("PAYLOAD: $requestData");

      final response = await DioClient.dio.post(
        url,
        data: requestData,
      );

      print("VERIFY OTP RESPONSE: ${response.data}");
      return LoginModel.fromJson(response.data);
    } on DioException catch (e) {
      print("VERIFY OTP DIO ERROR: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "OTP verification failed");
    } catch (e) {
      print("VERIFY OTP GENERAL ERROR: $e");
      throw "An unexpected error occurred during verification";
    }
  }

  Future<bool> logout() async {
    try {
      final url = "${ApiUrls.baseUrl}/auth/logout";

      final response = await DioClient.dio.post(url);

      if (response.statusCode == 200) {
        await StorageService.clearToken();
        return true;
      }

      return false;
    } catch (e) {
      throw "Logout failed";
    }
  }}