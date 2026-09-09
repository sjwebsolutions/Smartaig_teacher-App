import 'package:get/get.dart';
import '../controller/gate_pass_controller.dart';

class GatePassBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GatePassController>(() => GatePassController());
  }
}
