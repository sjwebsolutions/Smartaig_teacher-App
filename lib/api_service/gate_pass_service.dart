import 'package:dio/dio.dart';
import '../models/gate_pass_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class GatePassService {
  Future<GatePassModel> getGatePasses() async {
    try {
      print("--- START GET GATE PASSES ---");
      print("URL: ${ApiUrls.gatePasses}");
      final response = await DioClient.dio.get(ApiUrls.gatePasses);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");
      
      if (response.statusCode == 200) {
        return GatePassModel.fromJson(response.data);
      } else {
        throw "Failed to load gate passes (Status: ${response.statusCode})";
      }
    } on DioException catch (e) {
      print("GATE PASSES DIO ERROR: ${e.message}");
      print("GATE PASSES DIO RESPONSE: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to fetch gate passes");
    } catch (e) {
      print("GATE PASSES GENERAL ERROR: $e");
      throw "An unexpected error occurred while fetching gate passes: $e";
    }
  }

  Future<bool> requestGatePass({
    required String reason,
    required String exitTime,
  }) async {
    try {
      print("--- START POST REQUEST GATE PASS ---");
      print("URL: ${ApiUrls.gatePasses}");
      final Map<String, dynamic> body = {
        "reason": reason,
        "exit_time": exitTime,
      };
      final response = await DioClient.dio.post(ApiUrls.gatePasses, data: body);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["success"] ?? false;
      } else {
        throw response.data["message"] ?? "Failed to request gate pass";
      }
    } on DioException catch (e) {
      print("POST GATE PASS DIO ERROR: ${e.message}");
      print("POST GATE PASS DIO RESPONSE: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to request gate pass");
    } catch (e) {
      print("POST GATE PASS GENERAL ERROR: $e");
      throw "An unexpected error occurred while requesting gate pass: $e";
    }
  }
}
