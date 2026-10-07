import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teacher_app_attendance/themes/app_bar/app_top_bar.dart';
import 'package:teacher_app_attendance/utils/app_update_util.dart';
import 'package:teacher_app_attendance/view/app_blocked_screen.dart';
import 'package:teacher_app_attendance/view/screens/setting_screen.dart';
import 'package:teacher_app_attendance/view/upload_homework_screen.dart';
import 'package:teacher_app_attendance/view/view_marks_screen.dart';
import '../controller/main_controller.dart';
import 'screens/dashboard/dashboard_screen_v2.dart';
import '../themes/appColors_&_styles/app_Colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateUtil.checkForUpdate(context);
      }
    });
  }

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
        systemNavigationBarColor: Color(0xFFD7E5FD),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Obx(() {
        final bodyContent = controller.isBlocked.value
            ? AppBlockedScreen(
                message: controller.blockedMessage.value,
                isEmbedded: true,
              )
            : IndexedStack(
                index: controller.selectedIndex.value,
                children: screens,
              );

        return PopScope(
          canPop: !controller.isBlocked.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.mainGradient,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: controller.isBlocked.value
                  ? const AppTopBar(
                      title: "Dashboard",
                      showBack: false,
                      backgroundColor: Colors.transparent,
                    )
                  : null,
              body: Platform.isAndroid ? SafeArea(child: bodyContent) : bodyContent,
              bottomNavigationBar: controller.isBlocked.value
                  ? null
                  : _buildCustomBottomBar(controller),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCustomBottomBar(MainController controller) {
    final bool isIOS = Platform.isIOS;
    final bool isAndroid = Platform.isAndroid;
    Widget bottomBar = Padding(
      padding: EdgeInsets.only(right: 10, left: 10, bottom: isIOS ? 25 : 0, top: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: const Color(0xFF233263),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 4,
          ).copyWith(bottom: isIOS ? 6 : 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(controller, 0, Icons.dashboard_rounded, Icons.dashboard_outlined, "Dashboard"),
              _buildNavItem(controller, 1, Icons.menu_book_rounded, Icons.menu_book_outlined, "Homework"),
              _buildNavItem(controller, 2, Icons.assignment_rounded, Icons.assignment_outlined, "Marks"),
              _buildNavItem(controller, 3, Icons.settings_rounded, Icons.settings_outlined, "Setting"),
            ],
          ),
        ),
      ),
    );

    if (isAndroid) {
      return SafeArea(
        top: false,
        child: bottomBar,
      );
    }
    return bottomBar;
  }

  Widget _buildNavItem(MainController controller, int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = controller.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? AppColors.white : Colors.white.withValues(alpha: 0.55),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : Colors.white.withValues(alpha: 0.55),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
