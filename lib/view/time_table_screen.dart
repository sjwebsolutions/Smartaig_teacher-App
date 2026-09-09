import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/time_table_controller.dart';
import '../models/time_table_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class TimeTableScreen extends StatelessWidget {
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TimeTableController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const AppTopBar(
        title: "Time Table",
        showBack: true,
        backgroundColor: const Color(0xFFF8F9FE),
        showDivider: false,
      ),
        body: Obx(() {
          if (controller.isLoading.value && !controller.hasFetched.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Error Occurred",
                      style: AppTextStyles.h2.copyWith(color: AppColors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => controller.fetchTimeTable(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Retry", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          }

          final data = controller.timeTableModel.value?.data;

          return RefreshIndicator(
            onRefresh: () => controller.fetchTimeTable(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Date and Day Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.04)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatFullDate(data?.selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data?.selectedDay ?? "",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.greensuccess.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Today's Schedule",
                          style: TextStyle(
                            color: AppColors.greensuccess,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Period List View
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final periods = data?.dailySchedule ?? [];

                      if (periods.isEmpty) {
                        return ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy_rounded,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No periods scheduled for today",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        itemCount: periods.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final period = periods[index];
                          final isBreak = period.type?.toLowerCase() == 'break';
                          
                          if (isBreak) {
                            return _buildBreakCard(period);
                          } else {
                            return _buildClassCard(period);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      );
  }

  // Visual widget for Lunch/Breaks
  Widget _buildBreakCard(TimeTablePeriod period) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.creamWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.creamWhiteborder.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.creamWhiteborder.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.brownattention,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.periodName ?? "Break",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brownattention,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Rest and Re-energize",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.attentiontheory.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                period.startTime ?? "",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brownattention,
                ),
              ),
              const Icon(
                Icons.arrow_downward_rounded,
                size: 12,
                color: AppColors.attentiontheory,
              ),
              Text(
                period.endTime ?? "",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brownattention,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Visual widget for Class Lectures
  Widget _buildClassCard(TimeTablePeriod period) {
    final lectures = period.lectures;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Header (Time & Period Title)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period.periodName ?? "Period",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${period.startTime ?? ''} - ${period.endTime ?? ''}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (lectures.isEmpty) ...[
            const SizedBox(height: 12),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "No lectures assigned for this period",
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 0.5, color: AppColors.grey),
            ),
            
            // List of lectures in this period
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lectures.length,
              separatorBuilder: (context, index) => const Divider(height: 16, thickness: 0.5),
              itemBuilder: (context, index) {
                final lecture = lectures[index];
                final subjectsStr = lecture.subjects.map((s) => s.name).join(", ");
                final subjectCodesStr = lecture.subjects.map((s) => s.code).where((c) => c != null).join(", ");
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Class/Section/Stream details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.school_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Class: ${lecture.classInfo?.name ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (lecture.section != null) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      "(${lecture.section})",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.book_rounded,
                                    size: 16,
                                    color: AppColors.greensuccess,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      subjectsStr.isNotEmpty ? subjectsStr : "No Subject",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.greensuccess,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (subjectCodesStr.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Padding(
                                  padding: const EdgeInsets.only(left: 22.0),
                                  child: Text(
                                    "Code: $subjectCodesStr",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Status badge (Regular vs Proxy/Substitution)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: lecture.type?.toLowerCase() == 'proxy'
                                    ? Colors.orange.withValues(alpha: 0.1)
                                    : AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (lecture.type ?? "Regular").toUpperCase(),
                                style: TextStyle(
                                  color: lecture.type?.toLowerCase() == 'proxy'
                                      ? Colors.orange[800]
                                      : AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Proxy details or substitutions if any
                    if (lecture.isSubstitutedOut) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.red.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "This lecture has been substituted out.",
                                style: TextStyle(
                                  color: AppColors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    if (lecture.proxyDetails != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Proxy Details: ${lecture.proxyDetails.toString()}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatFullDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr;
    }
  }
}
