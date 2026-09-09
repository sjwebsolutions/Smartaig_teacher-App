import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_service/support_service.dart';
import '../models/support_settings_model.dart';
import '../utils/app_snackbar.dart';

class SupportController extends GetxController {
  final SupportService _supportService = SupportService();

  final Rxn<SupportSettingsModel> supportSettings = Rxn<SupportSettingsModel>();
  final RxBool isLoading = false.obs;
  final RxBool isExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("SupportController INIT");
  }

  Future<void> fetchSupportSettings({bool force = false}) async {
    if (supportSettings.value != null && !force) return;

    try {
      isLoading.value = true;
      final response = await _supportService.getSupportSettings();
      if (response.success) {
        supportSettings.value = response;
      } else {
        AppSnackBar.error("Failed to load support contact details");
      }
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
    if (isExpanded.value) {
      fetchSupportSettings();
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        AppSnackBar.error("Could not launch phone dialer for $phoneNumber");
      }
    } catch (e) {
      AppSnackBar.error("Error opening phone dialer: $e");
    }
  }

  Future<void> sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        AppSnackBar.error("Could not launch email app for $email");
      }
    } catch (e) {
      AppSnackBar.error("Error opening email app: $e");
    }
  }

  Future<void> openWhatsApp(String number) async {
    String cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    String formattedNum = cleanNumber;
    if (cleanNumber.length == 10) {
      formattedNum = "91$cleanNumber";
    } else if (cleanNumber.startsWith("+")) {
      formattedNum = cleanNumber.replaceAll("+", "");
    }

    final Uri whatsappUri = Uri.parse("https://wa.me/$formattedNum");
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        AppSnackBar.error("Could not launch WhatsApp for $number");
      }
    } catch (e) {
      AppSnackBar.error("Error opening WhatsApp: $e");
    }
  }
}
