import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_x;

import '../services/storage_services.dart';
import 'api_url.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiUrls.baseUrl,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();

        if (token != null && token.isNotEmpty) {
          // Splitting the token if it contains '|' (e.g., Laravel Sanctum format: id|token)
          final actualToken = token.contains('|') ? token.split('|').last : token;
          options.headers["Authorization"] = "Bearer $actualToken";
        }

        handler.next(options);
      },

      onError: (error, handler) {
        if (error.response?.statusCode == 403) {
          final data = error.response?.data;
          if (data is Map && data['blocked'] == true) {
            String message = data['message'] ?? "Access Blocked";

            // Check if it's NOT a login request to perform redirect
            final path = error.requestOptions.path;
            final isLoginRequest = path.contains('/auth/otp/request') ||
                                  path.contains('/auth/otp/verify');

            if (!isLoginRequest) {
              get_x.Get.offAllNamed('/dashboard', arguments: {
                'isBlocked': true,
                'message': message,
              });
            }
          }
        }
        handler.next(error);
      },
    ),
  );
}