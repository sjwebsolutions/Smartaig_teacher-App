import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/invigilator_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class InvigilatorDutyDetailScreen extends GetView<InvigilatorController> {
  const InvigilatorDutyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int dutyId = Get.arguments;

    // Fetch details when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchInvigilatorDutyDetails(dutyId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const AppTopBar(
        title: "Duty Details",
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.dutyDetails.value?.data;
        if (data == null) {
          return const Center(child: Text("No details found"));
        }

        final duties = data.duties ?? [];

        return Column(
          children: [
            _buildHeader(data.seatingPlan),
            Expanded(
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
                            Text(
                              duty.formattedDate ?? "N/A",
                              style: AppTextStyles.h2.copyWith(fontSize: 16),
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
                        const SizedBox(height: 4),
                        Text(
                          duty.dayName ?? "N/A",
                          style: AppTextStyles.body.copyWith(color: AppColors.grey, fontSize: 13),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.access_time, "Timing", duty.timing ?? "N/A"),
                        _buildInfoRow(Icons.meeting_room_outlined, "Room", duty.room?.name ?? "N/A"),
                        _buildInfoRow(Icons.groups_outlined, "Classes", (duty.classes ?? []).join(", ")),
                        _buildInfoRow(Icons.person_outline, "Co-Invigilators", (duty.coInvigilators ?? []).isEmpty ? "None" : duty.coInvigilators!.join(", ")),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildRoomStat("Capacity", duty.room?.capacity?.toString() ?? "0"),
                              _buildRoomStat("Students", duty.room?.studentCount?.toString() ?? "0"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(dynamic seatingPlan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            seatingPlan?.name ?? "N/A",
            style: AppTextStyles.h2.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            "${seatingPlan?.datesheetName ?? "N/A"} | ${seatingPlan?.session ?? "N/A"}",
            style: AppTextStyles.body.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.body.copyWith(fontSize: 13, color: AppColors.grey),
                children: [
                  TextSpan(text: "$label: "),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.primary)),
        Text(label, style: AppTextStyles.body.copyWith(fontSize: 10, color: AppColors.grey)),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'today':
        return Colors.blue;
      case 'tomorrow':
        return Colors.orange;
      case 'upcoming':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
