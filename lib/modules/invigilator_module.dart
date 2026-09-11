import 'package:get/get.dart';
import '../controller/invigilator_controller.dart';

class InvigilatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvigilatorController>(() => InvigilatorController());
  }
}
