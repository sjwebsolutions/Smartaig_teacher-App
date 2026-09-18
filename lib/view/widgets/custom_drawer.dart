import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controller/dashboard_controller_v2.dart';
import '../../controller/auth_controller.dart';
import '../../themes/appColors_&_styles/app_Colors.dart';
import '../../themes/appColors_&_styles/text_styles.dart';
import '../profile_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<NewDashboardController>();
    final authController = Get.find<AuthController>();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(dashboardController),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_rounded,
                    title: "Dashboard",
                    onTap: () => Get.back(),
                  ),
                  _buildMenuItem(
                    icon: Icons.person_rounded,
                    title: "My Profile",
                    onTap: () {
                      Get.back();
                      Get.to(() => const ProfileScreen());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_today_rounded,
                    title: "Time Table",
                    onTap: () {
                      Get.back();
                      Get.toNamed('/timeTable');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.how_to_reg_rounded,
                    title: "Attendance History",
                    onTap: () {
                      Get.back();
                      Get.toNamed('/attendance');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.assignment_turned_in_rounded,
                    title: "Examination Duties",
                    onTap: () {
                      Get.back();
                      Get.toNamed('/invigilatorDuties');
                    },
                  ),
                  const Divider(indent: 20, endIndent: 20, height: 30),
                  _buildSectionHeader("Academic Management"),
                  _buildMenuItem(
                    icon: Icons.book_rounded,
                    title: "Homework",
                    onTap: () {
                      Get.back();
                      Get.toNamed('/uploadHomework');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.list_alt_rounded,
                    title: "Syllabus Tracker",
                    onTap: () {
                      Get.back();
                      Get.toNamed('/syllabus');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.grade_rounded,
                    title: "Marks Entry",
                    onTap: () {
                      Get.back();
                      Get.toNamed('/marksEntry');
                    },
                  ),
                  const Divider(indent: 20, endIndent: 20, height: 30),
                  _buildMenuItem(
                    icon: Icons.settings_rounded,
                    title: "Settings",
                    onTap: () {
                      Get.back();
                      Get.toNamed('/dashboard', arguments: 3); // Assuming 3 is settings in MainScreen
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: "About App",
                    onTap: () {
                      Get.back();
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildLogoutButton(authController),
          const SizedBox(height: 10),
          const Text(
            "Version 2.0.11",
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(NewDashboardController controller) {
    return Obx(() {
      final teacher = controller.dashboard.value?.data?.teacher;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF3D4E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: (teacher?.image != null && teacher!.image!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: teacher.image!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(Icons.person, color: AppColors.primary, size: 35),
                      )
                    : const Icon(Icons.person, color: AppColors.primary, size: 35),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher?.name ?? "Teacher Name",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (teacher?.staffType ?? "Staff").toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: () => _showLogoutDialog(Get.context!, authController),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.red.withOpacity(0.1)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              SizedBox(width: 10),
              Text(
                "Logout",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded, size: 50, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text("Logout", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Are you sure you want to logout?", textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Get.back();
                        authController.logout();
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/images/app_logo.jpg', width: 80, height: 80),
              ),
              const SizedBox(height: 20),
              const Text("Smart AIG Teacher", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("Version 2.0.11", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text(
                "Designed to simplify daily tasks and improve school-teacher communication.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
