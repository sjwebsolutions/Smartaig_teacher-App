import 'package:dio/dio.dart';
import '../models/leave_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class LeaveService {
  Future<LeaveModel> getLeaves() async {
    try {
      print("--- START GET LEAVES ---");
      print("URL: ${ApiUrls.leaves}");
      final response = await DioClient.dio.get(ApiUrls.leaves);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200) {
        return LeaveModel.fromJson(response.data);
      } else {
        throw "Failed to load leaves (Status: ${response.statusCode})";
      }
    } on DioException catch (e) {
      print("LEAVES DIO ERROR: ${e.message}");
      print("LEAVES DIO RESPONSE: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to fetch leaves");
    } catch (e) {
      print("LEAVES GENERAL ERROR: $e");
      throw "An unexpected error occurred while fetching leaves: $e";
    }
  }

  Future<bool> applyLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      print("--- START POST APPLY LEAVE ---");
      print("URL: ${ApiUrls.applyLeave}");
      final Map<String, dynamic> body = {
        "leave_type": leaveType,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
      };
      final response = await DioClient.dio.post(ApiUrls.applyLeave, data: body);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["success"] ?? true;
      } else {
        throw response.data["message"] ?? "Failed to apply leave";
      }
    } on DioException catch (e) {
      print("APPLY LEAVE DIO ERROR: ${e.message}");
      print("APPLY LEAVE DIO RESPONSE: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to apply leave");
    } catch (e) {
      print("APPLY LEAVE GENERAL ERROR: $e");
      throw "An unexpected error occurred while applying leave: $e";
    }
  }
}
