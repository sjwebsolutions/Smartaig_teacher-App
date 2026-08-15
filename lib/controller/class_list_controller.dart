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
      print("Fetching classes... Time: ${DateTime.now()}");
      final response = await _service.getInchargeClasses();
      print("Response success: ${response.success}");
      
      if (response.success == true) {
        classList.value = response.data ?? [];
        print("Data updated. Class count: ${classList.length}");
        if (classList.isNotEmpty) {
          final firstClass = classList.first;
          print("First class details -> P: ${firstClass.present}, A: ${firstClass.absent}, L: ${firstClass.leave}, Pending: ${firstClass.pending}");
        }
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
