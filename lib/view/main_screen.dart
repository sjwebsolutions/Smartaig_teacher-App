import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher_app_attendance/themes/app_bar/app_top_bar.dart';
import 'package:teacher_app_attendance/view/app_blocked_screen.dart';
import 'package:teacher_app_attendance/view/profile_screen.dart';
import 'package:teacher_app_attendance/view/setting_screen.dart';
import 'package:teacher_app_attendance/view/upload_homework_screen.dart';
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
      const UploadHomeworkScreen(),
      const ProfileScreen(),
      const SettingScreen(),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.black.withValues(alpha: 0.5),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Homework',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Setting',
            ),
          ],
        ),
    )));
  }
}
