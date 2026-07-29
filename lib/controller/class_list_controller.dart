import 'package:get/get.dart';
import 'package:teacher_app_attendance/api_service/student_attendance_service.dart';
import 'package:teacher_app_attendance/models/class_list_model.dart';

class ClassListController extends GetxController {
  final StudentAttendanceService _service = StudentAttendanceService();
  
  var isLoading = false.obs;
  var classList = <ClassData>[].obs;
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      isLoading(true);
      errorMessage("");
      print("Fetching classes...");
      final response = await _service.getInchargeClasses();
      print("Response success: ${response.success}");
      print("Response Data Length: ${response.data?.length ?? 0}");
      
      if (response.success == true) {
        classList.value = response.data ?? [];
        if (classList.isEmpty) {
          errorMessage.value = "No classes assigned to you.";
        }
      } else {
        errorMessage("Failed to load classes");
      }
    } catch (e) {
      print("Error fetching classes: $e");
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
