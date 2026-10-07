import 'package:dio/dio.dart';
import '../models/leave_model.dart';
import '../models/leave_meta_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class LeaveService {
  Future<LeaveModel> getLeaves({
    String? status,
    String? date,
    int? month,
    int? year,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (date != null && date.isNotEmpty) queryParams['date'] = date;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await DioClient.dio.get(
        ApiUrls.leaves,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return LeaveModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioClient.getErrorMessage(e, "Failed to fetch leaves");
    } catch (e) {
      throw "An unexpected error occurred while fetching leaves: $e";
    }
  }

  Future<LeaveMetaModel> getLeavesMeta() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.leavesMeta);
      return LeaveMetaModel.fromJson(response.data);
    } on DioException catch (e) {
      throw DioClient.getErrorMessage(e, "Failed to fetch leave metadata");
    } catch (e) {
      throw "An unexpected error occurred while fetching leave metadata: $e";
    }
  }

  Future<bool> applyLeave({
    required String fromDate,
    required String toDate,
    required String leaveType,
    String dayType = "full_day",
    String? halfDayStartTime,
    String? halfDayEndTime,
    required String reason,
    String? attachmentPath,
  }) async {
    try {
      final Map<String, dynamic> map = {
        "from_date": fromDate,
        "to_date": toDate,
        "day_type": dayType,
        "leave_type": leaveType,
        "reason": reason,
      };

      if (dayType == "half_day") {
        if (halfDayStartTime != null && halfDayStartTime.isNotEmpty) {
          map["half_day_start_time"] = halfDayStartTime;
        }
        if (halfDayEndTime != null && halfDayEndTime.isNotEmpty) {
          map["half_day_end_time"] = halfDayEndTime;
        }
      }

      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        map["attachment"] = await MultipartFile.fromFile(
          attachmentPath,
          filename: attachmentPath.split('/').last,
        );
      }

      final formData = FormData.fromMap(map);

      final response = await DioClient.dio.post(
        ApiUrls.leaves,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data["success"] ?? true;
      } else {
        throw response.data["message"] ?? "Failed to apply leave";
      }
    } on DioException catch (e) {
      throw DioClient.getErrorMessage(e, "Failed to apply leave");
    } catch (e) {
      throw "An unexpected error occurred while applying leave: $e";
    }
  }
}
