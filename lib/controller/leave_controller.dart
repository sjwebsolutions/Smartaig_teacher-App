import 'package:get/get.dart';
import '../api_service/leave_service.dart';
import '../models/leave_model.dart';

class LeaveController extends GetxController {
  final LeaveService _service = LeaveService();

  var isLoading = false.obs;
  var hasFetched = false.obs;
  var errorMessage = "".obs;
  var leaves = <LeaveData>[].obs;

  @override
  void onInit() {
    print("LeaveController Initialized");
    super.onInit();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    try {
      print("Controller: fetchLeaves() called");
      isLoading.value = true;
      errorMessage.value = "";
      final response = await _service.getLeaves();
      if (response.data != null) {
        leaves.assignAll(response.data!);
      }
      hasFetched.value = true;
    } catch (e) {
      print("Controller: catch error = $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print("Controller: fetchLeaves() finished. isLoading = ${isLoading.value}");
    }
  }

  Future<bool> applyLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      isLoading.value = true;
      final success = await _service.applyLeave(
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      if (success) {
        await fetchLeaves();
        return true;
      }
      return false;
    } catch (e) {
      print("Controller applyLeave error: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
