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
import '../controller/time_table_controller.dart';
import '../controller/gate_pass_controller.dart';
import 'grid_module_item.dart';
import 'syllabus_screen.dart';
import '../themes/appColors_&_styles/text_styles.dart';

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
    final timeTableController = Get.isRegistered<TimeTableController>() ? Get.find<TimeTableController>() : Get.put(TimeTableController());
    final gatePassController = Get.isRegistered<GatePassController>() ? Get.find<GatePassController>() : Get.put(GatePassController());

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
              Get.toNamed('/syllabus');
            }),
        ModuleItem(
            title: "Update Image",
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
        ModuleItem(
          title: "Time Table",
          icon: Icons.schedule_rounded,
          color: const Color(0xFF8B5CF6), // Purple
          isEnabled: true,
          badgeCount: timeTableController.timeTables.length,
          onTap: () {
            Get.toNamed('/timeTable');
          },
        ),
        ModuleItem(
          title: "Get Pass",
          icon: Icons.badge_rounded,
          color: const Color(0xFF14B8A6), // Teal
          isEnabled: true,
          badgeCount: gatePassController.gatePasses.length,
          onTap: () {
            Get.toNamed('/getPass');
          },
        ),
      ];

      final double screenWidth = MediaQuery.of(context).size.width;
      final bool isTablet = screenWidth >= 600;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: modules.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 6 : 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: isTablet ? 1.0 : 0.88,
        ),
        itemBuilder: (context, index) {
          final item = modules[index];
          final bool isEnabled = item.isEnabled;
          final int badgeCount = item.badgeCount;
          final bool showBadge = badgeCount > 0;
          
          return Opacity(
            opacity: isEnabled ? 1.0 : 0.6,
            child: GestureDetector(
              onTap: isEnabled ? item.onTap : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: (isEnabled ? item.color : AppColors.grey).withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  (isEnabled ? item.color : AppColors.grey).withValues(alpha: 0.2),
                                  (isEnabled ? item.color : AppColors.grey).withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: isEnabled ? item.color : AppColors.grey,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              item.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isEnabled 
                                    ? AppColors.primary.withValues(alpha: 0.9)
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showBadge)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(
                            "$badgeCount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
