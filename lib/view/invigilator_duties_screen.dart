import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/invigilator_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class InvigilatorDutiesScreen extends GetView<InvigilatorController> {
  const InvigilatorDutiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const AppTopBar(
        title: "Invigilator Duties",
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final duties = controller.duties.value?.data ?? [];

        if (duties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text("No invigilator duties found", style: AppTextStyles.body),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchInvigilatorDuties(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: duties.length,
            itemBuilder: (context, index) {
              final duty = duties[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            duty.name ?? "N/A",
                            style: AppTextStyles.h3.copyWith(fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(duty.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (duty.status ?? "N/A").toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(duty.status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today_outlined, "Datesheet", duty.datesheet?.name ?? "N/A"),
                    _buildInfoRow(Icons.history_toggle_off, "Session", duty.session ?? "N/A"),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _buildStatItem("Total", duty.totalDuties?.toString() ?? "0", Colors.blue),
                        _buildStatItem("Upcoming", duty.upcomingDuties?.toString() ?? "0", Colors.orange),
                        _buildStatItem("Completed", duty.completedDuties?.toString() ?? "0", Colors.green),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateInfo("First Duty", duty.firstDutyDate),
                        _buildDateInfo("Last Duty", duty.lastDutyDate),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text("$label: ", style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.grey)),
          Text(value, style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: color, fontSize: 18)),
          Text(label, style: AppTextStyles.body.copyWith(fontSize: 10, color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 11, color: AppColors.grey)),
        const SizedBox(height: 2),
        Text(date ?? "N/A", style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'upcoming':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
