
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/dashboard_controller_v2.dart';
import '../controller/banner_controller.dart';

class TeacherDashboardBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<NewDashboardController>(()=> NewDashboardController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<BannerController>(() => BannerController());
  }

}