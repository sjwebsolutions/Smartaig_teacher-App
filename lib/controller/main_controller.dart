import 'package:get/get.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;
  var isBlocked = false.obs;
  var blockedMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      if (Get.arguments['isBlocked'] == true) {
        isBlocked.value = true;
        blockedMessage.value = Get.arguments['message'] ?? "";
      }
    }
  }

  void changeIndex(int index) {
    if (!isBlocked.value) {
      selectedIndex.value = index;
    }
  }
}
