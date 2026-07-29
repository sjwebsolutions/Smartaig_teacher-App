import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teacher_app_attendance/controller/class_list_controller.dart';
import 'package:teacher_app_attendance/themes/appColors_&_styles/app_Colors.dart';
import 'package:teacher_app_attendance/themes/appColors_&_styles/text_styles.dart';
import 'package:teacher_app_attendance/themes/app_bar/app_top_bar.dart';

class ClassListScreen extends StatelessWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClassListController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppTopBar(
        backgroundColor: Colors.transparent,
        showBack: true,
        showDivider: true,
        customTitle: Text("Incharge Classes", style: AppTextStyles.appbarh4),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                ElevatedButton(
                  onPressed: controller.fetchClasses,
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }

        if (controller.classList.isEmpty) {
          return const Center(child: Text("No classes found"));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchClasses,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.classList.length,
            itemBuilder: (context, index) {
              final classData = controller.classList[index];
              return _buildClassCard(classData);
            },
          ),
        );
      }),
    );
  }

  Widget _buildClassCard(dynamic classData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to Attendance Screen with class details
          Get.toNamed('/attendance', arguments: classData);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Class: ${classData.className} - ${classData.sectionName?.toUpperCase()}",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Students: ${classData.totalStudents}",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (classData.streamName != null) ...[
                const SizedBox(height: 4),
                Text(
                  "Stream: ${classData.streamName}",
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    color: AppColors.black.withOpacity(0.6),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statusItem("Present", classData.present ?? "0", AppColors.green),
                  _statusItem("Absent", classData.absent ?? "0", AppColors.red),
                  _statusItem("Leave", classData.leave ?? "0", Colors.orange),
                  _statusItem("Pending", classData.pending?.toString() ?? "0", Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Marked: ${classData.marked}/${classData.totalStudents}",
                    style: AppTextStyles.body.copyWith(fontSize: 12),
                  ),
                  Text(
                    "Last updated: ${classData.lastUpdated ?? 'N/A'}",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      color: AppColors.black.withOpacity(0.4),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 10,
            color: AppColors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
