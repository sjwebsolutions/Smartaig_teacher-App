import 'package:get/get.dart';
import '../controller/main_controller.dart';
import '../controller/dashboard_controller_v2.dart';
import '../controller/marks_controller.dart';
import '../controller/homework_controller.dart';
import '../controller/auth_controller.dart';
import '../controller/banner_controller.dart';
import '../controller/announcement_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<NewDashboardController>(() => NewDashboardController());
    Get.lazyPut<MarksController>(() => MarksController());
    Get.lazyPut<HomeworkController>(() => HomeworkController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<BannerController>(() => BannerController());
    Get.lazyPut<AnnouncementController>(() => AnnouncementController());
  }
}
