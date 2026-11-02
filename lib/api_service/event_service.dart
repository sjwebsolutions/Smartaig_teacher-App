import 'package:dio/dio.dart';
import '../models/event_today_scans_model.dart';
import '../models/event_pass_scan_response_model.dart';
import '../models/event_check_in_response_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class EventService {
  Future<EventTodayScansModel> getEventTodayScans() async {
    try {
      print("--- START GET EVENT TODAY SCANS ---");
      print("URL: ${ApiUrls.eventTodayScans}");
      final response = await DioClient.dio.get(ApiUrls.eventTodayScans);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200) {
        return EventTodayScansModel.fromJson(response.data);
      } else {
        throw "Failed to load event today scans (Status: ${response.statusCode})";
      }
    } on DioException catch (e) {
      print("EVENT TODAY SCANS DIO ERROR: ${e.message}");
      print("EVENT TODAY SCANS DIO RESPONSE: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to fetch event today scans");
    } catch (e) {
      print("EVENT TODAY SCANS GENERAL ERROR: $e");
      throw "An unexpected error occurred while fetching event today scans: $e";
    }
  }

  Future<EventPassScanResponseModel> scanEventPass({
    String? qrPayload,
    String? qrCode,
    String? passNumber,
    String? token,
    String? gateName,
  }) async {
    try {
      print("--- START POST SCAN EVENT PASS ---");
      print("URL: ${ApiUrls.eventScanPass}");

      final Map<String, dynamic> body = {};
      if (qrPayload != null && qrPayload.isNotEmpty) {
        body["qr_payload"] = qrPayload;
      }
      if (qrCode != null && qrCode.isNotEmpty) {
        body["qr_code"] = qrCode;
      }
      if (passNumber != null && passNumber.isNotEmpty) {
        body["pass_number"] = passNumber;
      }
      if (token != null && token.isNotEmpty) {
        body["token"] = token;
      }
      if (gateName != null && gateName.isNotEmpty) {
        body["gate_name"] = gateName;
      }

      final response = await DioClient.dio.post(
        ApiUrls.eventScanPass,
        data: body,
      );
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");

      return EventPassScanResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print("SCAN EVENT PASS DIO ERROR: ${e.message}");
      print("SCAN EVENT PASS DIO RESPONSE: ${e.response?.data}");
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        return EventPassScanResponseModel.fromJson(e.response!.data);
      }
      throw DioClient.getErrorMessage(e, "Failed to scan pass");
    } catch (e) {
      print("SCAN EVENT PASS GENERAL ERROR: $e");
      throw "An unexpected error occurred while scanning pass: $e";
    }
  }

  Future<EventCheckInResponseModel> checkInEventPass({
    required int passId,
    required List<int> attendeeIds,
    String? gateName,
    String? remarks,
  }) async {
    try {
      print("--- START POST CHECK-IN EVENT PASS ---");
      print("URL: ${ApiUrls.eventCheckInPass}");

      final Map<String, dynamic> body = {
        "pass_id": passId,
        "attendee_ids": attendeeIds,
      };
      if (gateName != null && gateName.isNotEmpty) {
        body["gate_name"] = gateName;
      }
      if (remarks != null && remarks.isNotEmpty) {
        body["remarks"] = remarks;
      }

      print("BODY: $body");

      final response = await DioClient.dio.post(
        ApiUrls.eventCheckInPass,
        data: body,
      );
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");

      return EventCheckInResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print("CHECK-IN EVENT PASS DIO ERROR: ${e.message}");
      print("CHECK-IN EVENT PASS DIO RESPONSE: ${e.response?.data}");
      if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
        return EventCheckInResponseModel.fromJson(e.response!.data);
      }
      throw DioClient.getErrorMessage(e, "Failed to check in event pass");
    } catch (e) {
      print("CHECK-IN EVENT PASS GENERAL ERROR: $e");
      throw "An unexpected error occurred while checking in event pass: $e";
    }
  }
}
