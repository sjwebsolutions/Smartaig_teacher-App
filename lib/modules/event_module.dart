import 'package:get/get.dart';
import '../controller/event_controller.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventController>(() => EventController());
  }
}
