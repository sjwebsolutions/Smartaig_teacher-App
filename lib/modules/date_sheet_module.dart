import 'package:get/get.dart';
import '../controller/date_sheet_controller.dart';

class DateSheetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DateSheetController>(() => DateSheetController());
  }
}
