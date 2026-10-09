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
import '../controller/invigilator_controller.dart';
import '../controller/leave_controller.dart';
import '../controller/student_leave_controller.dart';
import '../controller/dashboard_controller_v2.dart';
import 'grid_module_item.dart';
import '../themes/appColors_&_styles/text_styles.dart';

class ModuleCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<ModuleItem> items;

  ModuleCategory({
    required this.title,
    required this.icon,
    this.color = AppColors.primary,
    required this.items,
  });
}

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
    final invigilatorController = Get.isRegistered<InvigilatorController>() ? Get.find<InvigilatorController>() : Get.put(InvigilatorController());
    final leaveController = Get.isRegistered<LeaveController>() ? Get.find<LeaveController>() : Get.put(LeaveController());
    final studentLeaveController = Get.isRegistered<StudentLeaveController>() ? Get.find<StudentLeaveController>() : Get.put(StudentLeaveController());

    return Obx(() {
      final categories = [
        ModuleCategory(
          title: "Attendance Management",
          icon: Icons.school_rounded,
          color: const Color(0xFF6366F1), // Indigo
          items: [
            ModuleItem(
              title: "Attendance",
              icon: Icons.assignment_turned_in_rounded,
              color: const Color(0xFF6366F1),
              isEnabled: true,
              onTap: () {
                Get.toNamed('/classList');
              },
            ),
            ModuleItem(
              title: "Scan Attendance",
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF059669),
              isEnabled: true,
              onTap: () {
                Get.toNamed('/studentQrScanner');
              },
            ),
            ModuleItem(
              title: "Student Leave",
              icon: Icons.event_note_rounded,
              color: const Color(0xFFE11D48),
              isEnabled: true,
              badgeCount: studentLeaveController.leavesList.isNotEmpty
                  ? studentLeaveController.leavesList.where((l) => (l.status ?? '').toLowerCase() == 'pending').length
                  : (Get.isRegistered<NewDashboardController>()
                      ? (Get.find<NewDashboardController>().dashboard.value?.data?.studentLeaves?.totalPendingCount ?? 0)
                      : 0),
              onTap: () {
                Get.toNamed('/studentLeave');
              },
            ),
            ModuleItem(
              title: "Teacher Leave",
              icon: Icons.time_to_leave_rounded,
              color: const Color(0xFFD97706),
              isEnabled: true,
              badgeCount: leaveController.leaves.where((l) => (l.status ?? '').toLowerCase() == 'pending').length,
              onTap: () {
                Get.toNamed('/teacherLeave');
              },
            ),
          ],
        ),
        ModuleCategory(
          title: "Academic Management",
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF0D9488), // Teal
          items: [
            ModuleItem(
              title: "Syllabus",
              icon: Icons.library_books_rounded,
              color: const Color(0xFF8B5CF6),
              isEnabled: true,
              badgeCount: syllabusController.teacherSyllabusList.length,
              onTap: () {
                Get.toNamed('/syllabus');
              },
            ),
            ModuleItem(
              title: "Homework",
              icon: Icons.menu_book_rounded,
              color: const Color(0xFFF59E0B),
              isEnabled: true,
              badgeCount: homeworkController.homeworkList.length,
              onTap: () {
                mainController.changeIndex(1);
              },
            ),
            ModuleItem(
              title: "Marks Entry",
              icon: Icons.edit_note_rounded,
              color: const Color(0xFF10B981),
              isEnabled: true,
              badgeCount: marksController.marksEntries.length,
              onTap: () {
                mainController.changeIndex(2);
              },
            ),
            ModuleItem(
              title: "Time Table",
              icon: Icons.schedule_rounded,
              color: const Color(0xFF8B5CF6),
              isEnabled: true,
              badgeCount: timeTableController.timeTables.length,
              onTap: () {
                Get.toNamed('/timeTable');
              },
            ),
            ModuleItem(
              title: "Date Sheet",
              icon: Icons.calendar_month_rounded,
              color: const Color(0xFF0EA5E9),
              isEnabled: true,
              badgeCount: dateSheetController.dateSheets.length,
              onTap: () {
                Get.toNamed('/dateSheet');
              },
            ),
          ],
        ),
        ModuleCategory(
          title: "Exam & Administration",
          icon: Icons.manage_accounts_rounded,
          color: const Color(0xFF8B5CF6), // Violet
          items: [
            ModuleItem(
              title: "Update Student Data",
              icon: Icons.manage_accounts_rounded,
              color: const Color(0xFFF43F5E),
              isEnabled: true,
              onTap: () {
                Get.toNamed('/updateStudentData');
              },
            ),
            ModuleItem(
              title: "Invigilator Duties",
              icon: Icons.assignment_ind_rounded,
              color: const Color(0xFF475569),
              isEnabled: true,
              badgeCount: invigilatorController.duties.value?.data?.fold<int>(0, (sum, item) => sum + (item.upcomingDuties ?? 0)) ?? 0,
              onTap: () {
                Get.toNamed('/invigilatorDuties');
              },
            ),
            ModuleItem(
              title: "Admit Card Scan",
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF0284C7),
              isEnabled: true,
              onTap: () {
                Get.toNamed('/admitCardScanner');
              },
            ),
            ModuleItem(
              title: "Get Pass",
              icon: Icons.badge_rounded,
              color: const Color(0xFF14B8A6),
              isEnabled: true,
              badgeCount: gatePassController.gatePasses.length,
              onTap: () {
                Get.toNamed('/getPass');
              },
            ),
          ],
        ),
        ModuleCategory(
          title: "Communication & Media",
          icon: Icons.campaign_rounded,
          color: const Color(0xFFEC4899), // Pink
          items: [
            ModuleItem(
              title: "Announcement",
              icon: Icons.campaign_rounded,
              color: Colors.blue,
              isEnabled: true,
              badgeCount: announcementController.announcements.value?.data?.length ?? 0,
              onTap: () {
                Get.toNamed('/announcements');
              },
            ),
            ModuleItem(
              title: "Banners",
              icon: Icons.image_rounded,
              color: const Color(0xFFEC4899),
              isEnabled: true,
              badgeCount: bannerController.banners.value?.banners?.length ?? 0,
              onTap: () {
                bannerController.fetchBanners();
                Get.toNamed('/banners');
              },
            ),
          ],
        ),
      ];

      final double screenWidth = MediaQuery.of(context).size.width;
      final bool isTablet = screenWidth >= 600;

      return Column(
        children: categories.map((category) => _buildCategoryCard(context, category, isTablet)).toList(),
      );
    });
  }

  Widget _buildCategoryCard(BuildContext context, ModuleCategory category, bool isTablet) {
    if (category.items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.black.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 4 : 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: isTablet ? 1.5 : 1.32,
            ),
            itemBuilder: (context, index) {
              final item = category.items[index];
              return _buildModuleItemCard(item, isTablet: isTablet);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItemCard(ModuleItem item, {required bool isTablet}) {
    final bool isEnabled = item.isEnabled;
    final int badgeCount = item.badgeCount;
    final bool showBadge = badgeCount > 0;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: GestureDetector(
        onTap: isEnabled ? item.onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: (isEnabled ? item.color : AppColors.grey).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isEnabled ? item.color : AppColors.grey).withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: isTablet ? 32 : 28,
                        width: isTablet ? 32 : 28,
                        decoration: BoxDecoration(
                          color: (isEnabled ? item.color : AppColors.grey).withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: isEnabled ? item.color : AppColors.grey,
                          size: isTablet ? 18 : 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: FontWeight.w700,
                          color: isEnabled
                              ? AppColors.black.withValues(alpha: 0.85)
                              : AppColors.grey,
                          height: 1.08,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showBadge)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      "$badgeCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
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
  }
}
