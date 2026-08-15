import 'package:get/get.dart';
import '../controller/banner_controller.dart';
import '../controller/announcement_controller.dart';

class BannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BannerController>(() => BannerController());
    Get.lazyPut<AnnouncementController>(() => AnnouncementController());
  }
}
