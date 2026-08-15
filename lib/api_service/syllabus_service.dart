import 'package:dio/dio.dart';
import '../models/syllabus_model.dart';
import '../utils/api_url.dart';
import '../utils/dio_client.dart';

class SyllabusService {
  Future<SyllabusModel> getSyllabus(int studentId) async {
    try {
      final url = ApiUrls.syllabus(studentId);
      final response = await DioClient.dio.get(url);
      
      if (response.statusCode == 200) {
        // Note: The new SyllabusModel expects a list in 'data', 
        // if student syllabus returns a single object, we might need to adjust.
        return SyllabusModel.fromJson(response.data);
      } else {
        throw "Failed to load syllabus";
      }
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch syllabus";
    } catch (e) {
      throw "An unexpected error occurred while fetching syllabus";
    }
  }

  Future<SyllabusModel> getTeacherSyllabus() async {
    try {
      final response = await DioClient.dio.get(ApiUrls.teacherSyllabus);
      if (response.statusCode == 200) {
        return SyllabusModel.fromJson(response.data);
      } else {
        throw "Failed to load teacher syllabus";
      }
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Failed to fetch teacher syllabus";
    } catch (e) {
      throw "An unexpected error occurred while fetching teacher syllabus";
    }
  }
}
