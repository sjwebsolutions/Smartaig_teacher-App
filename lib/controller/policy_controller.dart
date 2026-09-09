import 'package:get/get.dart';
import '../api_service/policy_service.dart';
import '../models/policy_model.dart';
import '../utils/app_snackbar.dart';

class PolicyController extends GetxController {
  final PolicyService _policyService = PolicyService();

  final Rxn<PolicyModel> policy = Rxn<PolicyModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("PolicyController INIT");
  }

  Future<void> fetchPolicies({bool force = false}) async {
    if (policy.value != null && !force) return;

    try {
      isLoading.value = true;
      final response = await _policyService.getPolicies();
      if (response.success) {
        policy.value = response;
      } else {
        AppSnackBar.error("Failed to load policy details");
      }
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
