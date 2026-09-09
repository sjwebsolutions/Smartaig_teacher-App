import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teacher_app_attendance/themes/app_bar/app_top_bar.dart';
import 'package:teacher_app_attendance/view/app_blocked_screen.dart';
import 'package:teacher_app_attendance/view/profile_screen.dart';
import 'package:teacher_app_attendance/view/screens/setting_screen.dart';
import 'package:teacher_app_attendance/view/upload_homework_screen.dart';
import 'package:teacher_app_attendance/view/view_marks_screen.dart';
import '../controller/main_controller.dart';
import 'screens/dashboard/dashboard_screen_v2.dart';

import '../themes/appColors_&_styles/app_Colors.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());

    final List<Widget> screens = [
      const NewTeacherDashboardScreen(),
      UploadHomeworkScreen(onBack: () => controller.changeIndex(0)),
      ViewMarksScreen(onBack: () => controller.changeIndex(0)),
      const SettingScreen()
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Obx(() => PopScope(
      canPop: !controller.isBlocked.value,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: controller.isBlocked.value
            ? const AppTopBar(
                title: "Dashboard",
                showBack: false,
                backgroundColor: AppColors.bgColor,
              )
            : null,
        body: controller.isBlocked.value
            ? AppBlockedScreen(
                message: controller.blockedMessage.value,
                isEmbedded: true,
              )
            : IndexedStack(
                index: controller.selectedIndex.value,
                children: screens,
              ),
        bottomNavigationBar: controller.isBlocked.value
            ? null
            : _buildCustomBottomBar(controller),
    ))));
  }

  Widget _buildCustomBottomBar(MainController controller) {
    return SafeArea(
      child: Container( /// android phone ke liye SafeArea dena ios ke liye SafeArea nahi dena h
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),  /// android ke liye  bottom: 0 ios ke liye bottom: 15
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(controller, 0, Icons.home_rounded, Icons.home_outlined, "Home"),
              _buildNavItem(controller, 1, Icons.menu_book_rounded, Icons.menu_book_outlined, "Homework"),
              _buildNavItem(controller, 2, Icons.assignment_rounded, Icons.assignment_outlined, "Marks"),
              _buildNavItem(controller, 3, Icons.settings, Icons.settings, "Setting"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(MainController controller, int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : AppColors.black.withValues(alpha: 0.4),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.black.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            // Line indicator at the BOTTOM
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
