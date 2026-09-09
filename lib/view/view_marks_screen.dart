import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import '../controller/marks_controller.dart';
import '../models/marks_entry_classes_model.dart';
import '../themes/app_bar/app_top_bar.dart';

class ViewMarksScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ViewMarksScreen({super.key, this.onBack});

  @override
  State<ViewMarksScreen> createState() => _ViewMarksScreenState();
}

class _ViewMarksScreenState extends State<ViewMarksScreen> {
  final MarksController marksController = Get.find<MarksController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB0D7FE),
            Color(0xFFE8D8FD),
            Color(0xFFD3E1FD),
            Color(0xFFD7E5FD),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Light greyish background for the screen
        appBar: AppTopBar(
          backgroundColor: Colors.transparent,
          showBack: true,
          onBack: widget.onBack,
          showDivider: false,
          customTitle: Text("Marks Screen", style: AppTextStyles.appbarh4),
        ),
      body: Obx(() {
        if (marksController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async => marksController.fetchMarksEntries(),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: _buildExamCategoryDropdown(),
                ),
              ),
              marksController.isClassesLoading.value
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _buildSliverClassList(),
            ],
          ),
        );
      }),
    ));
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
                value: marksController.marksEntries.any((e) => e.id == marksController.selectedExamTypeId.value)
                    ? marksController.selectedExamTypeId.value
                    : null,
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

  Widget _buildSliverClassList() {
    final classes = marksController.uniqueClasses;

    if (classes.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("No classes found")),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final classData = classes[index];
            final classId = classData.classId ?? "";
            final className = classData.className ?? "N/A";
            
            final allEntriesForClass = marksController.marksEntryClasses.where((s) => s.classId == classId).toList();
            
            // Stream logic
            final streamEntries = allEntriesForClass.where((s) => 
                s.streamId != null && s.streamId != "null" && s.streamId!.isNotEmpty).toList();
            
            final uniqueStreamIds = streamEntries.map((s) => s.streamId).toSet();
            bool hasStreams = uniqueStreamIds.isNotEmpty;
            
            int totalStreams = uniqueStreamIds.length;
            int addedStreams = 0;
            if (hasStreams) {
              for (var sId in uniqueStreamIds) {
                final streamSections = streamEntries.where((s) => s.streamId == sId).toList();
                if (streamSections.every((s) => s.isLocked == true)) {
                  addedStreams++;
                }
              }
            }
            int pendingStreams = totalStreams - addedStreams;

            // Section logic
            int totalSections = allEntriesForClass.length;
            int addedSections = allEntriesForClass.where((s) => s.isLocked == true).length;
            int pendingSections = totalSections - addedSections;

            int totalStudents = 0;
            int markedStudents = 0;
            for (var s in allEntriesForClass) {
              markedStudents += s.added ?? 0;
              totalStudents += s.totalStudents ?? 0;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
                  // If class has streams, we don't pre-select streamId here as there are multiple
                  marksController.selectedStreamId.value = null; 
                  Get.toNamed('/marksEntry', arguments: {'fromViewMarks': true});
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Class: $className",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F2F8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hasStreams ? "Streams: $totalStreams" : "Sections: $totalSections",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5C6BC0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 12),
                      
                      // Section Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("Added Section", addedSections.toString(), const Color(0xFF4CAF50)),
                          _buildStatItem("Pending Section", pendingSections.toString(), const Color(0xFFE53935)),
                          _buildStatItem("Total Section", totalSections.toString(), const Color(0xFFFFA000)),
                        ],
                      ),
                      
                      if (hasStreams) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 20, endIndent: 20),
                        const SizedBox(height: 12),
                        // Stream Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("Added Stream", addedStreams.toString(), const Color(0xFF4CAF50)),
                            _buildStatItem("Pending Stream", pendingStreams.toString(), const Color(0xFFE53935)),
                            _buildStatItem("Total Stream", totalStreams.toString(), const Color(0xFF2196F3)),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                              children: [
                                const TextSpan(text: "Overall Marked: ", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                fontSize: 10,
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
          childCount: classes.length,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
