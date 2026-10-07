import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../api_service/leave_service.dart';
import '../models/leave_model.dart';
import '../models/leave_meta_model.dart';

class LeaveController extends GetxController {
  final LeaveService _service = LeaveService();

  var isLoading = false.obs;
  var hasFetched = false.obs;
  var errorMessage = "".obs;
  var leaves = <LeaveData>[].obs;
  var leaveMeta = Rxn<LeaveMetaData>();

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
    fetchLeavesMeta();
  }

  Future<void> fetchLeaves({String? status}) async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final response = await _service.getLeaves(status: status);
      if (response.data != null) {
        leaves.assignAll(response.data!);
      }
      hasFetched.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLeavesMeta() async {
    try {
      final response = await _service.getLeavesMeta();
      if (response.success == true && response.data != null) {
        leaveMeta.value = response.data;
      }
    } catch (e) {
      debugPrint("Error fetching leave meta: $e");
    }
  }

  Future<bool> applyLeave({
    required String fromDate,
    required String toDate,
    required String leaveType,
    String dayType = "full_day",
    String? halfDayStartTime,
    String? halfDayEndTime,
    required String reason,
    String? attachmentPath,
  }) async {
    try {
      isLoading.value = true;
      final success = await _service.applyLeave(
        fromDate: fromDate,
        toDate: toDate,
        leaveType: leaveType,
        dayType: dayType,
        halfDayStartTime: halfDayStartTime,
        halfDayEndTime: halfDayEndTime,
        reason: reason,
        attachmentPath: attachmentPath,
      );
      if (success) {
        await fetchLeaves();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
