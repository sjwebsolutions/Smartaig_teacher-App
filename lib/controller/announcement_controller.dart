import 'package:get/get.dart';
import '../api_service/announcement_service.dart';
import '../models/announcement_model.dart';

class AnnouncementController extends GetxController {
  final AnnouncementService _service = AnnouncementService();

  final announcements = Rxn<AnnouncementModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      final result = await _service.getAnnouncements();
      announcements.value = result;
    } catch (e) {
      print("Error fetching announcements: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
