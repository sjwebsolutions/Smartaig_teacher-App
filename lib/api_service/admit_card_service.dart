import 'package:dio/dio.dart';
import '../models/admit_card_verify_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class AdmitCardService {
  Future<AdmitCardVerifyModel> verifyAdmitCard({
    String? qrCode,
    int? studentId,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (qrCode != null && qrCode.isNotEmpty) {
        data['qr_code'] = qrCode;
      }
      if (studentId != null) {
        data['student_id'] = studentId;
      }

      final response = await DioClient.dio.post(
        ApiUrls.admitCardScanVerify,
        data: data,
      );

      return AdmitCardVerifyModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? e.message ?? "Failed to verify admit card";
    } catch (e) {
      throw e.toString();
    }
  }
}
