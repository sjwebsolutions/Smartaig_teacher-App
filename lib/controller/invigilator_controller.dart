import 'package:get/get.dart';
import '../api_service/invigilator_service.dart';
import '../models/invigilator_duty_model.dart';
import '../models/invigilator_duty_detail_model.dart';

class InvigilatorController extends GetxController {
  final InvigilatorService _service = InvigilatorService();

  final duties = Rxn<InvigilatorDutyModel>();
  final isLoading = false.obs;

  final dutyDetails = Rxn<InvigilatorDutyDetailModel>();
  final isDetailLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvigilatorDuties();
  }

  Future<void> fetchInvigilatorDuties() async {
    try {
      isLoading.value = true;
      final result = await _service.getInvigilatorDuties();
      duties.value = result;
    } catch (e) {
      print("Error fetching invigilator duties: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInvigilatorDutyDetails(int id) async {
    try {
      isDetailLoading.value = true;
      dutyDetails.value = null; // Clear previous details
      final result = await _service.getInvigilatorDutyDetails(id);
      dutyDetails.value = result;
    } catch (e) {
      print("Error fetching duty details: $e");
    } finally {
      isDetailLoading.value = false;
    }
  }
}
