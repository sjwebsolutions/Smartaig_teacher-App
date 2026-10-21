import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/dashboard_controller.dart';
import '../controller/banner_controller.dart';

class TeacherDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<BannerController>(() => BannerController());
  }
}
