import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/date_sheet_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class DateSheetScreen extends StatelessWidget {
  const DateSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DateSheetController>();

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
          title: "Date Sheet",
          showBack: true,
          backgroundColor: Colors.transparent,
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
                      onPressed: () => controller.fetchDateSheets(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text("Retry", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          }

          if (controller.dateSheets.isEmpty && controller.hasFetched.value) {
            return RefreshIndicator(
              onRefresh: () => controller.fetchDateSheets(),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "No Date Sheet Available",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchDateSheets(),
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: controller.dateSheets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = controller.dateSheets[index];
                return InkWell(
                  onTap: () {
                    Get.toNamed('/dateSheetDetail', arguments: {
                      'id': item.id,
                      'name': item.name,
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.name ?? "No Name",
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.primary, 
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateBox("START DATE", item.startDate),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildDateBox("END DATE", item.endDate),
                            ),
                          ],
                        ),
                        if (item.instruction != null && item.instruction!.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Divider(height: 1, thickness: 0.5),
                          ),
                          Text(
                            "Instructions:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.instruction!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateBox(String label, String? dateStr) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                _formatDate(dateStr),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr;
    }
  }
}
