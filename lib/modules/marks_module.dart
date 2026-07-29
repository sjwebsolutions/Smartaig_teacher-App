import 'package:get/get.dart';
import '../controller/marks_controller.dart';

class MarksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarksController>(() => MarksController());
  }
}
