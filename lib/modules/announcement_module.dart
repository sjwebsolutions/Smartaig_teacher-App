import 'package:get/get.dart';
import '../controller/announcement_controller.dart';

class AnnouncementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnnouncementController>(() => AnnouncementController());
  }
}
