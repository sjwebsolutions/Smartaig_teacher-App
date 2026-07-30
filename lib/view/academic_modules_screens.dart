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
          color: const Color(0xFF6366F1), // Indigo
          isEnabled: true,
          onTap: () {
            Get.toNamed('/classList');
          }),
      ModuleItem(
          title: "Homework",
          icon: Icons.menu_book_rounded,
          color: const Color(0xFFF59E0B), // Amber
          isEnabled: true,
          onTap: () {
            mainController.changeIndex(1);
          }),
      ModuleItem(
          title: "Marks Entry",
          icon: Icons.edit_note_rounded,
          color: const Color(0xFF10B981), // Emerald
          isEnabled: true,
          onTap: () {
            mainController.changeIndex(2);
          }),
      ModuleItem(
          title: "Banners",
          icon: Icons.image_rounded,
          color: const Color(0xFFEC4899), // Pink
          isEnabled: true,
          onTap: () {
            if (Get.isRegistered<BannerController>()) {
              Get.find<BannerController>().fetchBanners();
            }
            Get.toNamed('/banners');
          }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final item = modules[index];
        
        return Column(
          children: [
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                  border: Border.all(
                    color: item.color.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      },
    );
  }
}
