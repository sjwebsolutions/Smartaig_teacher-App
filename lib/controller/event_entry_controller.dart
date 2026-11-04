import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../api_service/event_service.dart';
import '../models/active_event_model.dart';

class EventEntryController extends GetxController {
  final EventService _eventService = EventService();

  final isLoading = false.obs;
  final activeEvents = <ActiveEventItem>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveEvents();
  }

  Future<void> fetchActiveEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _eventService.getActiveEvents();
      if (result.success == true && result.data != null) {
        activeEvents.assignAll(result.data!);
      } else {
        activeEvents.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("Error fetching active events: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
