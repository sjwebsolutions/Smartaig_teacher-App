import 'package:dio/dio.dart';
import '../models/invigilator_duty_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class InvigilatorService {
  Future<InvigilatorDutyModel> getInvigilatorDuties() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.invigilatorDuties);
      return InvigilatorDutyModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch invigilator duties";
    }
  }
}
