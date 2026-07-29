import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/dashboard_controller_v2.dart';
import '../controller/profile_controller.dart';
import '../controller/auth_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<NewDashboardController>();
    final profileController = Get.put(ProfileController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppTopBar(
        title: "Profile",
        showBack: false,
        backgroundColor: Colors.transparent,
        showDivider: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'setting') {
                // Navigate to setting index in main screen or setting screen
              } else if (value == 'logout') {
                _showLogoutDialog(context, authController);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'setting',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 20, color: AppColors.black),





                    SizedBox(width: 12),
                    Text("Settings", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20, color: AppColors.red),
                    const SizedBox(width: 12),
                    Text("Logout", style: TextStyle(fontSize: 14, color: AppColors.red, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Obx(() {
        final teacher = dashboardController.dashboard.value?.data?.teacher;

        if (teacher == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section with Gradient
              Stack(
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: Column(
                        children: [
                          // Profile Image with Edit option
                          Stack(
                            children: [
                              Obx(() => Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white, width: 5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: profileController.isImageUpdating.value
                                    ? const Center(child: CircularProgressIndicator())
                                    : (profileController.selectedImagePath.isNotEmpty)
                                        ? Image.file(File(profileController.selectedImagePath.value), fit: BoxFit.cover)
                                        : (teacher.image != null && teacher.image!.isNotEmpty)
                                            ? CachedNetworkImage(
                                                imageUrl: teacher.image!,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const Icon(Icons.person, color: AppColors.primary, size: 80),
                                                errorWidget: (context, url, error) => const Icon(Icons.person, color: AppColors.primary, size: 80),
                                              )
                                            : const Icon(Icons.person, color: AppColors.primary, size: 80),
                              )),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () => _showImageSourceDialog(context, profileController),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            teacher.name ?? "No Name",
                            style: AppTextStyles.body.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            teacher.staffType ?? "Teacher",
                            style: AppTextStyles.body.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Info Section
              _buildInfoSection(teacher),
              
              const SizedBox(height: 50),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoSection(var teacher) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.email_rounded, "Email Address", teacher.email ?? "Not Available"),
          _divider(),
          _buildInfoTile(Icons.phone_android_rounded, "Phone Number", teacher.phone ?? "Not Available"),
          _divider(),
          _buildInfoTile(Icons.badge_rounded, "Designation", teacher.staffType ?? "Not Available"),
          _divider(),
          _buildInfoTile(Icons.school_rounded, "School ID", teacher.schoolId?.toString() ?? "Not Available"),
          _divider(),
          _buildInfoTile(Icons.fingerprint_rounded, "Teacher ID", teacher.teacherUniqueId?.toString() ?? "Not Available"),
          _divider(),
          _buildInfoTile(Icons.person_outline_rounded, "Employee ID", teacher.id?.toString() ?? "Not Available"),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.grey.withValues(alpha: 0.03),
      indent: 75,
      endIndent: 20,
    );
  }

  void _showImageSourceDialog(BuildContext context, ProfileController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Update Profile Photo",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout from your account?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: AppColors.black.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: const Text("Logout", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
