import 'package:dio/dio.dart';
import '../models/date_sheet_model.dart';
import '../models/date_sheet_detail_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class DateSheetService {
  Future<DateSheetModel> getDateSheets() async {
    try {
      print("--- START GET DATE SHEETS ---");
      print("URL: ${ApiUrls.dateSheets}");
      final response = await DioClient.dio.get(ApiUrls.dateSheets);
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");
      
      if (response.statusCode == 200) {
        return DateSheetModel.fromJson(response.data);
      } else {
        throw "Failed to load date sheets (Status: ${response.statusCode})";
      }
    } on DioException catch (e) {
      print("DIO ERROR: ${e.message}");
      print("DIO RESPONSE: ${e.response?.data}");
      throw e.response?.data["message"] ?? "Failed to fetch date sheets";
    } catch (e) {
      print("GENERAL ERROR: $e");
      throw "An unexpected error occurred while fetching date sheets: $e";
    }
  }

  Future<DateSheetDetailModel> getDateSheetDetails(int id) async {
    try {
      final url = ApiUrls.dateSheetDetails(id);
      print("GET Request to Details: $url");
      final response = await DioClient.dio.get(url);
      if (response.statusCode == 200) {
        return DateSheetDetailModel.fromJson(response.data);
      } else {
        throw "Failed to load date sheet details";
      }
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch date sheet details";
    } catch (e) {
      throw "An unexpected error occurred while fetching date sheet details";
    }
  }
}
