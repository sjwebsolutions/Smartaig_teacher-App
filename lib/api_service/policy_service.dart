import 'package:dio/dio.dart';
import 'package:teacher_app_attendance/models/policy_model.dart';
import 'package:teacher_app_attendance/utils/api_url.dart';
import 'package:teacher_app_attendance/utils/dio_client.dart';

class PolicyService {
  Future<PolicyModel> getPolicies() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.policies);
      print("POLICIES RESPONSE: ${response.data}");
      return PolicyModel.fromJson(response.data);
    } on DioException catch (e) {
      print("POLICIES DIO ERROR: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to fetch policies");
    } catch (e) {
      print("POLICIES GENERAL ERROR: $e");
      throw "Failed to fetch policies";
    }
  }
}
