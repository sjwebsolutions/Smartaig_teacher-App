import 'package:get/get.dart';
import '../api_service/gate_pass_service.dart';
import '../models/gate_pass_model.dart';

class GatePassController extends GetxController {
  final GatePassService _service = GatePassService();

  var isLoading = false.obs;
  var hasFetched = false.obs;
  var errorMessage = "".obs;
  var gatePasses = <GatePassData>[].obs;

  @override
  void onInit() {
    print("GatePassController Initialized");
    super.onInit();
    fetchGatePasses();
  }

  Future<void> fetchGatePasses() async {
    try {
      print("Controller: fetchGatePasses() called");
      isLoading.value = true;
      errorMessage.value = "";
      final response = await _service.getGatePasses();
      print("Controller: success = ${response.success}");
      if (response.success == true) {
        gatePasses.assignAll(response.data);
      } else {
        print("Controller: response.success is false");
      }
      hasFetched.value = true;
    } catch (e) {
      print("Controller: catch error = $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print("Controller: fetchGatePasses() finished. isLoading = ${isLoading.value}");
    }
  }

  Future<bool> requestGatePass({
    required String reason,
    required String exitTime,
  }) async {
    try {
      isLoading.value = true;
      final success = await _service.requestGatePass(reason: reason, exitTime: exitTime);
      if (success) {
        await fetchGatePasses();
        return true;
      }
      return false;
    } catch (e) {
      print("Controller requestGatePass error: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
