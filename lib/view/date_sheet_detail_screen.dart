import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/date_sheet_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class DateSheetDetailScreen extends StatelessWidget {
  const DateSheetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DateSheetController>();
    final int id = Get.arguments['id'];
    final String name = Get.arguments['name'];

    // Fetch details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDateSheetDetails(id);
    });

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppTopBar(
          title: name,
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: Obx(() {
          if (controller.isDetailLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = controller.dateSheetDetailWrapper.value;
          if (detail == null || detail.entries == null || detail.entries!.isEmpty) {
            return const Center(child: Text("No examination entries found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: detail.entries!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = detail.entries![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getDay(entry.examDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            _getMonth(entry.examDate),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.subjectName ?? "N/A",
                            style: AppTextStyles.body.copyWith(
                              fontSize: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.school_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                "Class: ${entry.className ?? "N/A"}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.greensuccess.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (entry.examType ?? "exam").toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.greensuccess,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  String _getDay(String? dateStr) {
    if (dateStr == null) return "??";
    try {
      final date = DateTime.parse(dateStr);
      return date.day.toString().padLeft(2, '0');
    } catch (e) {
      return "??";
    }
  }

  String _getMonth(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      final months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
      return months[date.month - 1];
    } catch (e) {
      return "N/A";
    }
  }
}
