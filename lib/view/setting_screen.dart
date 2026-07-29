import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppTopBar(
        backgroundColor: Colors.transparent,
        showBack: false,
        showDivider: true,
        customTitle: Text("Settings", style: AppTextStyles.appbarh4),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingItem(
            icon: Icons.logout,
            title: "Logout",
            color: AppColors.red,
            onTap: () => _showLogoutConfirmation(context, authController),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthController authController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Icon(Icons.logout, size: 50, color: AppColors.red),
            const SizedBox(height: 16),
            Text("Logout", style: AppTextStyles.appbarh4.copyWith(color: AppColors.red)),
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to logout from the app?",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.grey),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text("Cancel", style: TextStyle(color: AppColors.black)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Get.back(); // Close sheet
                      authController.logout();
                    },
                    child: const Text("Logout", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: AppTextStyles.body.copyWith(color: color == AppColors.red ? color : AppColors.black)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        onTap: onTap,
      ),
    );
  }
}
