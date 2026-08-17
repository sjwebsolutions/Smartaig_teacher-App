import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../controller/main_controller.dart';
import '../controller/banner_controller.dart';
import '../controller/homework_controller.dart';
import '../controller/marks_controller.dart';
import '../controller/announcement_controller.dart';
import '../controller/syllabus_controller.dart';
import '../controller/date_sheet_controller.dart';
import 'grid_module_item.dart';
import 'syllabus_screen.dart';

class AcademicModuleGrid extends StatelessWidget {
  const AcademicModuleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();
    
    // Ensure controllers are registered (if not already)
    final homeworkController = Get.isRegistered<HomeworkController>() ? Get.find<HomeworkController>() : Get.put(HomeworkController());
    final marksController = Get.isRegistered<MarksController>() ? Get.find<MarksController>() : Get.put(MarksController());
    final bannerController = Get.isRegistered<BannerController>() ? Get.find<BannerController>() : Get.put(BannerController());
    final announcementController = Get.isRegistered<AnnouncementController>() ? Get.find<AnnouncementController>() : Get.put(AnnouncementController());
    final syllabusController = Get.isRegistered<SyllabusController>() ? Get.find<SyllabusController>() : Get.put(SyllabusController());
    final dateSheetController = Get.isRegistered<DateSheetController>() ? Get.find<DateSheetController>() : Get.put(DateSheetController());

    return Obx(() {
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
            badgeCount: homeworkController.homeworkList.length,
            onTap: () {
              mainController.changeIndex(1);
            }),
        ModuleItem(
            title: "Marks Entry",
            icon: Icons.edit_note_rounded,
            color: const Color(0xFF10B981), // Emerald
            isEnabled: true,
            badgeCount: marksController.marksEntries.length,
            onTap: () {
              mainController.changeIndex(2);
            }),
        ModuleItem(
            title: "Banners",
            icon: Icons.image_rounded,
            color: const Color(0xFFEC4899), // Pink
            isEnabled: true,
            badgeCount: bannerController.banners.value?.banners?.length ?? 0,
            onTap: () {
              bannerController.fetchBanners();
              Get.toNamed('/banners');
            }),
        ModuleItem(
            title: "Announcement",
            icon: Icons.campaign_rounded,
            color: Colors.blue, // Blue
            isEnabled: true,
            badgeCount: announcementController.announcements.value?.data?.length ?? 0,
            onTap: () {
              Get.toNamed('/announcements');
            }),
        ModuleItem(
            title: "Syllabus",
            icon: Icons.library_books_rounded,
            color: const Color(0xFF8B5CF6), // Violet
            isEnabled: true,
            badgeCount: syllabusController.teacherSyllabusList.length,
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
            badgeCount: dateSheetController.dateSheets.length,
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
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
                    if (item.badgeCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '${item.badgeCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
    });
  }
}
