import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/dashboard_controller_v2.dart';
import '../../controller/auth_controller.dart';
import '../../themes/appColors_&_styles/app_Colors.dart';
import '../../themes/appColors_&_styles/text_styles.dart';
import '../profile_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final dashboardController = Get.find<NewDashboardController>();
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
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
            _buildSettingItem(
              icon: Icons.person_outline_rounded,
              title: "Profile",
              subtitle: "View and edit your profile info",
              onTap: () => Get.to(() => const ProfileScreen()),
            ),
            const SizedBox(height: 10),

            // Mobile Number Item
            _buildSettingItem(
              icon: Icons.phone_android_rounded,
              title: "Mobile Number",
              subtitle: teacher?.phone ?? "Not Available",
              onTap: () {},
            ),
            const SizedBox(height: 10),

            // Others Group
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildListTile(
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
                  ),
                  const Divider(height: 1, indent: 50, endIndent: 20),
                  _buildListTile(
                    icon: Icons.alternate_email_rounded,
                    title: "Privacy Policy",
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50, endIndent: 20),
                  _buildListTile(
                    icon: Icons.assignment_outlined,
                    title: "Terms of Use",
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 50, endIndent: 20),
                  _buildListTile(
                    icon: Icons.headset_mic_outlined,
                    title: "Contact Support",
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Logout Item
            _buildSettingItem(
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

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
          borderRadius: BorderRadius.circular(10),
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
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
