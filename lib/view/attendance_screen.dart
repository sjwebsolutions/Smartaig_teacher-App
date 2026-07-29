import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/attendance_controller.dart';
import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AttendanceController>();

    // Get arguments from ClassListScreen
    final dynamic args = Get.arguments;
    if (args != null) {
      controller.setIds(args.classId.toString(), args.sectionId.toString());
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppTopBar(
        backgroundColor: AppColors.bgColor,
        showBack: true,
        showDivider: true,
        customTitle: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Class Attendance", style: AppTextStyles.appbarh4),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Student Roster",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.black.withValues(alpha: 0.60),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ListView.builder(
                  itemCount: controller.students.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final student = controller.students[index];
                    final studentId = student.id ?? 0;

                    return Obx(() {
                      final status = controller.studentStatuses[studentId] ?? '';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              student.rollNo ?? "0",
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 19,
                              backgroundColor: AppColors.grey.withValues(alpha: 0.3),
                              child: const Icon(Icons.person, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.studentName ?? "N/A",
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "ID: ${student.studentUniqueId}",
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _attendanceButton("P", AppColors.green, status == 'P', () => controller.updateStatus(studentId, 'P')),
                                const SizedBox(width: 6),
                                _attendanceButton("A", AppColors.red, status == 'A', () => controller.updateStatus(studentId, 'A')),
                                const SizedBox(width: 6),
                                _attendanceButton("L", Colors.orange, status == 'L', () => controller.updateStatus(studentId, 'L')),
                              ],
                            ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 45,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                controller.submitAttendance();
              },
              child: Text(
                "Submit Report",
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _attendanceButton(String text, Color color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: isSelected ? color : AppColors.grey.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.black.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
