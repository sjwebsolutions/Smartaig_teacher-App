import 'package:get/get.dart';
import '../controller/time_table_controller.dart';

class TimeTableBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TimeTableController>(() => TimeTableController());
  }
}
