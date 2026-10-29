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

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppTopBar(
          title: "Incharge Classes",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (controller.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(controller.errorMessage.value),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: controller.fetchClasses,
                      child: const Text("Retry", style: TextStyle(color: Colors.white)),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: controller.classList.length,
                itemBuilder: (context, index) {
                  final classData = controller.classList[index];
                  return _buildClassCard(classData);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildClassCard(dynamic classData) {
    final controller = Get.find<ClassListController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            var result = await Get.toNamed('/attendance', arguments: classData);
            controller.fetchClasses();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Class: ${classData.className} - ${classData.sectionName?.toUpperCase()}",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
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
                      fontSize: 12,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusItem("Present", (classData.present == null || classData.present == "") ? "0" : classData.present!, AppColors.green),
                    _statusItem("Absent", (classData.absent == null || classData.absent == "") ? "0" : classData.absent!, AppColors.red),
                    _statusItem("Leave", (classData.leave == null || classData.leave == "") ? "0" : classData.leave!, Colors.orange),
                    _statusItem("Pending", classData.pending?.toString() ?? "0", Colors.grey),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Marked: ${classData.marked}/${classData.totalStudents}",
                      style: AppTextStyles.body.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Last updated: ${classData.lastUpdated ?? 'N/A'}",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 10,
                        color: AppColors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                )
              ],
            ),
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
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 10,
            color: AppColors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
