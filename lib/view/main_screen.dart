import 'package:flutter/material.dart';
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

    return Obx(() => PopScope(
      canPop: !controller.isBlocked.value,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: controller.isBlocked.value
            ? const AppTopBar(
                title: "Dashboard",
                showBack: false,
                backgroundColor: Colors.transparent,
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
    )));
  }

  Widget _buildCustomBottomBar(MainController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(controller, 0, Icons.home_rounded, Icons.home_outlined, "Home"),
            _buildNavItem(controller, 1, Icons.menu_book_rounded, Icons.menu_book_outlined, "Homework"),
            _buildNavItem(controller, 2, Icons.assignment_rounded, Icons.assignment_outlined, "Marks"),
            // _buildNavItem(controller, 3, Icons.person_rounded, Icons.person_outline_rounded, "Setting"),
            _buildNavItem(controller, 3, Icons.settings, Icons.settings, "Setting"),
          ],
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
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Radio button style dot indicator (Moved to TOP)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 8 : 0,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: isSelected 
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2)
                  : null,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ] : null,
              ),
              child: isSelected ? Center(
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ) : null,
            ),
            const SizedBox(height: 2),
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : AppColors.black.withValues(alpha: 0.4),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.black.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
