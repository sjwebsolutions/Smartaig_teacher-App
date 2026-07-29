import 'package:get/get.dart';

import '../controller/auth_controller.dart';
class AuthBinding extends Bindings{
  @override
  void dependencies() {
    // TODO: implement dependencies
  Get.lazyPut<AuthController>(()=>AuthController());

  }

}