import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../controller/main_controller.dart';
import '../controller/banner_controller.dart';
import 'grid_module_item.dart';
import 'syllabus_screen.dart';

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
      ModuleItem(
          title: "Syllabus",
          icon: Icons.library_books_rounded,
          color: const Color(0xFF8B5CF6), // Violet
          isEnabled: true,
          onTap: () {
            Get.to(() => const SyllabusScreen());
          }),
      ModuleItem(
          title: "Upload Image",
          icon: Icons.camera_alt_rounded,
          color: const Color(0xFFF43F5E), // Rose
          isEnabled: true,
          onTap: () {
            Get.toNamed('/studentImageUpdate');
          }),
      ModuleItem(
          title: "Date Sheet",
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF0EA5E9), // Sky Blue
          isEnabled: true,
          onTap: () {
            Get.toNamed('/dateSheet');
          }),
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 6 : 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 12,
        childAspectRatio: isTablet ? 1.1 : 0.85,
      ),
      itemBuilder: (context, index) {
        final item = modules[index];
        
        return Column(
          children: [
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: item.color.withValues(alpha: 0.04),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 22,
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
