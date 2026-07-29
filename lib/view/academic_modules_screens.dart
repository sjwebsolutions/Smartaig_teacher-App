import 'package:flutter/material.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import 'grid_module_item.dart';
import 'package:get/get.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../controller/main_controller.dart';
import '../controller/banner_controller.dart';

class AcademicModuleGrid extends StatelessWidget {
  const AcademicModuleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();

    final modules = [
      ModuleItem(
          title: "Attendance",
          icon: Icons.assignment_turned_in_rounded,
          color: AppColors.primary,
          isEnabled: true,
          onTap: () {
            Get.toNamed('/classList');
          }),
      ModuleItem(
          title: "Homework",
          icon: Icons.menu_book_rounded,
          color: AppColors.primary,
          isEnabled: true,
          onTap: () {
            mainController.changeIndex(1);
          }),
      ModuleItem(
          title: "Marks Entry",
          icon: Icons.edit_note_rounded,
          color: AppColors.primary,
          isEnabled: true,
          onTap: () {
            Get.toNamed('/viewMarks');
          }),
      ModuleItem(
          title: "Banners",
          icon: Icons.image_rounded,
          color: AppColors.primary,
          isEnabled: true,
          onTap: () {
            if (Get.isRegistered<BannerController>()) {
              Get.find<BannerController>().fetchBanners();
            }
            Get.toNamed('/banners');
          }),
      ModuleItem(
          title: "Performance",
          icon: Icons.analytics_rounded,
          color: AppColors.primary.withValues(alpha: 0.08),
          isEnabled: false,
          onTap: () {}),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 0,
        crossAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final item = modules[index];
        
        return Column(
          children: [
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: item.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
