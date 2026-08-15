import 'package:get/get.dart';
import '../controller/image_update_controller.dart';

class ImageUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageUpdateController>(() => ImageUpdateController());
  }
}
