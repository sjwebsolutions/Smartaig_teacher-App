import 'package:get/get.dart';
import '../controller/student_leave_controller.dart';

class StudentLeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentLeaveController>(() => StudentLeaveController());
  }
}
