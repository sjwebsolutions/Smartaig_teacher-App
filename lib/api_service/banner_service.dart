import 'package:dio/dio.dart';
import 'package:teacher_app_attendance/models/banner_model.dart';
import 'package:teacher_app_attendance/utils/api_url.dart';
import 'package:teacher_app_attendance/utils/dio_client.dart';

class BannerServices {
  Future<BannerModel> getBanners() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.banners);
      return BannerModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Banners fetch fails";
    }
  }
}
