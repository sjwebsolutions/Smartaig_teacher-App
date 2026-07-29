import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import '../controller/marks_controller.dart';
import '../models/marks_entry_classes_model.dart';
import '../themes/app_bar/app_top_bar.dart';

class ViewMarksScreen extends StatefulWidget {
  const ViewMarksScreen({super.key});

  @override
  State<ViewMarksScreen> createState() => _ViewMarksScreenState();
}

class _ViewMarksScreenState extends State<ViewMarksScreen> {
  final MarksController marksController = Get.find<MarksController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light greyish background for the screen
      appBar: AppTopBar(
        backgroundColor: Colors.white,
        showBack: true,
        showDivider: true,
        customTitle: Text("View Marks ", style: AppTextStyles.appbarh4.copyWith(color: const Color(0xFF1A237E))),
      ),
      body: Obx(() {
        if (marksController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildExamCategoryDropdown(),
            ),
            Expanded(
              child: marksController.isClassesLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _buildClassList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildExamCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "EXAM CATEGORY",
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary.withValues(alpha: 0.7),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (marksController.marksEntries.isEmpty) {
            return const Text("No Exam Categories found");
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: marksController.selectedExamTypeId.value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                items: marksController.marksEntries.map((entry) => DropdownMenuItem(
                  value: entry.id,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.assignment_outlined, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.datesheetName ?? "",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.black.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                onChanged: (value) {
                  marksController.selectedExamTypeId.value = value;
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildClassList() {
    final classes = marksController.uniqueClasses;

    if (classes.isEmpty) {
      return const Center(child: Text("No classes found"));
    }

    return RefreshIndicator(
      onRefresh: () async => marksController.fetchMarksEntries(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final classData = classes[index];
          final classId = classData.classId ?? "";
          final sections = marksController.marksEntryClasses.where((s) => s.classId == classId).toList();
          final className = classData.className ?? "N/A";
          
          int totalSections = sections.length;
          int addedSections = sections.where((s) => s.isLocked == true).length;
          int pendingSections = totalSections - addedSections;

          int totalStudents = 0;
          int markedStudents = 0;
          for (var s in sections) {
            markedStudents += s.added ?? 0;
            totalStudents += s.totalStudents ?? 0;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: const Color(0xFFE0E4EC)),
            ),
            child: InkWell(
              onTap: () {
                marksController.selectedClassId.value = classId;
                Get.toNamed('/marksEntry');
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
                          "Class: $className",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Total Section: $totalSections",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5C6BC0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Added", addedSections.toString(), const Color(0xFF4CAF50)),
                        _buildStatItem("Pending", pendingSections.toString(), const Color(0xFFE53935)),
                        _buildStatItem("Total", totalSections.toString(), const Color(0xFFFFA000)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                            children: [
                              const TextSpan(text: "Marked: ", style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: "$markedStudents/$totalStudents"),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (addedSections == totalSections && totalSections > 0) ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            addedSections == totalSections && totalSections > 0 ? 'Completed' : 'In Progress',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: (addedSections == totalSections && totalSections > 0) ? Colors.green : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
