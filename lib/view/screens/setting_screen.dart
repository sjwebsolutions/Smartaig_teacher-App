import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../controller/dashboard_controller_v2.dart';
import '../../controller/auth_controller.dart';
import '../../controller/support_controller.dart';
import '../../controller/policy_controller.dart';
import '../../models/policy_model.dart';
import '../../themes/appColors_&_styles/app_Colors.dart';
import '../../themes/appColors_&_styles/text_styles.dart';
import '../../utils/app_snackbar.dart';
import '../profile_screen.dart';
import 'policy_detail_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final dashboardController = Get.find<NewDashboardController>();
  final authController = Get.find<AuthController>();
  final supportController = Get.find<SupportController>();
  final policyController = Get.find<PolicyController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB0D7FE),
            Color(0xFFE8D8FD),
            Color(0xFFD3E1FD),
            Color(0xFFD7E5FD),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Settings",
            style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 24),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
        ),
        body: Obx(() {
          final teacher = dashboardController.dashboard.value?.data?.teacher;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // Profile Item
              _buildSettingCard(
                icon: Icons.person_outline_rounded,
                title: "Profile",
                subtitle: "View and edit your profile info",
                onTap: () => Get.to(() => const ProfileScreen()),
              ),
              const SizedBox(height: 12),

              // Mobile Number Item
              _buildSettingCard(
                icon: Icons.phone_android_rounded,
                title: "Registered Mobile",
                subtitle: teacher?.phone ?? "Not Available",
                onTap: () {},
              ),
              const SizedBox(height: 12),

              // App Version Item
              _buildSettingCard(
                icon: Icons.info_outline_rounded,
                title: "App Version",
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "3.0.1",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {},
              ),
              const SizedBox(height: 12),

              // Privacy Policy Item
              _buildSettingCard(
                icon: Icons.alternate_email_rounded,
                title: "Privacy Policy",
                onTap: () => _handlePolicyTap("Privacy Policy", (data) => data.privacyPolicy),
              ),
              const SizedBox(height: 12),

              // Terms of Use Item
              _buildSettingCard(
                icon: Icons.assignment_outlined,
                title: "Terms of Use",
                onTap: () => _handlePolicyTap("Terms of Use", (data) => data.termsOfUse),
              ),
              const SizedBox(height: 12),

              // Contact Support Item
              _buildSettingCard(
                icon: Icons.headset_mic_outlined,
                title: "Contact Support",
                onTap: () => _showContactSupportDialog(context),
              ),
              const SizedBox(height: 12),

              // Logout Item
              _buildSettingCard(
                icon: Icons.logout_rounded,
                title: "Logout",
                subtitle: "Sign out from this device",
                titleColor: Colors.redAccent,
                iconColor: Colors.redAccent,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          );
        }),
    ),
  );
}

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? AppColors.primary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 10,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40), // Reduces dialog width
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with soft red background
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                "Confirm Logout",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Are you sure you want to log out?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons (Cancel & Confirm)
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        authController.logout();
                      },
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    supportController.fetchSupportSettings();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFF1EEF6), // Light lavender/purple color as seen in the image
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          child: Obx(() {
            if (supportController.isLoading.value) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final supportData = supportController.supportSettings.value?.data;
            if (supportData == null) {
              return SizedBox(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Failed to load details.",
                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => supportController.fetchSupportSettings(force: true),
                      child: const Text("Retry", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.headset_mic_outlined,
                      color: Color(0xFF5E65C5),
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Contact Support",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2746),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (supportData.name != null && supportData.name!.isNotEmpty) ...[
                  Text(
                    supportData.name!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2746),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (supportData.mobile != null && supportData.mobile!.isNotEmpty)
                  _buildDialogActionCard(
                    icon: const Icon(Icons.call_rounded, color: Colors.blue, size: 20),
                    title: "Call Us",
                    subtitle: supportData.mobile!,
                    iconBgColor: Colors.blue.withValues(alpha: 0.1),
                    onTap: () => supportController.makePhoneCall(supportData.mobile!),
                  ),
                if (supportData.whatsapp != null && supportData.whatsapp!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDialogActionCard(
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                    title: "WhatsApp",
                    subtitle: supportData.whatsapp!,
                    iconBgColor: Colors.green.withValues(alpha: 0.1),
                    onTap: () => supportController.openWhatsApp(supportData.whatsapp!),
                  ),
                ],
                if (supportData.email != null && supportData.email!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDialogActionCard(
                    icon: const Icon(Icons.mail_rounded, color: Colors.orange, size: 20),
                    title: "Email Support",
                    subtitle: supportData.email!,
                    iconBgColor: Colors.orange.withValues(alpha: 0.1),
                    onTap: () => supportController.sendEmail(supportData.email!),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Color(0xFF5E65C5),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDialogActionCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2746),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePolicyTap(String title, String? Function(PolicyData) selector) async {
    // Show a loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      barrierDismissible: false,
    );

    try {
      await policyController.fetchPolicies();
      Get.back(); // Dismiss loading dialog

      final policyData = policyController.policy.value?.data;
      if (policyData != null) {
        final content = selector(policyData);
        if (content != null && content.isNotEmpty) {
          Get.to(() => PolicyDetailScreen(title: title, htmlContent: content));
        } else {
          AppSnackBar.error("$title content is empty");
        }
      } else {
        AppSnackBar.error("Failed to load policy data");
      }
    } catch (e) {
      Get.back(); // Dismiss loading dialog if error occurs
      AppSnackBar.error("Error: $e");
    }
  }
}
