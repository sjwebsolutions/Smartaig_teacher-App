import 'package:get/get.dart';
import '../controller/admit_card_scanner_controller.dart';

class AdmitCardScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdmitCardScannerController>(() => AdmitCardScannerController());
  }
}
