import 'package:dio/dio.dart';
import '../models/time_table_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class TimeTableService {
  Future<TimeTableModel> getTimeTable({String? date, Map<String, dynamic>? headers}) async {
    try {
      print("--- START GET TIME TABLE ---");
      print("URL: ${ApiUrls.timetable}");
      
      final Map<String, dynamic> queryParams = {};
      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final response = await DioClient.dio.get(
        ApiUrls.timetable,
        queryParameters: queryParams,
        options: headers != null ? Options(headers: headers) : null,
      );
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE DATA: ${response.data}");
      
      if (response.statusCode == 200) {
        return TimeTableModel.fromJson(response.data);
      } else {
        throw "Failed to load timetable (Status: ${response.statusCode})";
      }
    } on DioException catch (e) {
      print("TIMETABLE DIO ERROR: ${e.message}");
      print("TIMETABLE DIO RESPONSE: ${e.response?.data}");
      throw DioClient.getErrorMessage(e, "Failed to fetch timetable");
    } catch (e) {
      print("TIMETABLE GENERAL ERROR: $e");
      throw "An unexpected error occurred while fetching timetable: $e";
    }
  }
}
