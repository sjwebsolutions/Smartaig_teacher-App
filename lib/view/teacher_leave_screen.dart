import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/leave_controller.dart';
import '../models/leave_model.dart';
import '../themes/appColors_&_styles/text_styles.dart';

class TeacherLeaveScreen extends StatelessWidget {
  const TeacherLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LeaveController>()
        ? Get.find<LeaveController>()
        : Get.put(LeaveController());

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
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showApplyLeaveBottomSheet(context, controller),
          backgroundColor: const Color(0xFF2563EB),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "Apply Leave",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF1E293B),
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "TEACHER LEAVES",
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E293B)),
                      onPressed: () => controller.fetchLeaves(),
                    ),
                  ],
                ),
              ),

              // Leaves List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.leaves.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.leaves.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No Leave Applications Found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap '+ Apply Leave' to submit a new leave request",
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchLeaves(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.leaves.length,
                      itemBuilder: (context, index) {
                        final item = controller.leaves[index];
                        return _buildLeaveCard(item);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveData item) {
    final status = (item.status ?? 'Pending').toLowerCase();
    Color statusBgColor;
    Color statusTextColor;

    if (status == 'approved') {
      statusBgColor = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF16A34A);
    } else if (status == 'rejected' || status == 'denied') {
      statusBgColor = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
    } else {
      statusBgColor = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFD97706);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                item.leaveType ?? "Casual Leave",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status ?? "Pending",
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                "${item.startDate} to ${item.endDate}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              if (item.totalDays != null)
                Text(
                  "${item.totalDays} Day(s)",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
            ],
          ),
          if (item.reason != null && item.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Reason: ${item.reason}",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
          if (item.remarks != null && item.remarks!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Remarks: ${item.remarks}",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  void _showApplyLeaveBottomSheet(BuildContext context, LeaveController controller) {
    final reasonController = TextEditingController();
    String selectedType = "Casual Leave";
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Apply Leave",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: "Leave Type",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Casual Leave", child: Text("Casual Leave")),
                      DropdownMenuItem(value: "Medical Leave", child: Text("Medical Leave")),
                      DropdownMenuItem(value: "Earned Leave", child: Text("Earned Leave")),
                      DropdownMenuItem(value: "Duty Leave", child: Text("Duty Leave")),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                startDate = picked;
                                if (endDate.isBefore(startDate)) endDate = startDate;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 18),
                          label: Text(formatter.format(startDate)),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => endDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 18),
                          label: Text(formatter.format(endDate)),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Reason",
                      hintText: "Enter reason for leave...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final reason = reasonController.text.trim();
                        if (reason.isEmpty) {
                          Get.snackbar("Required", "Please enter a reason",
                              backgroundColor: Colors.red, colorText: Colors.white);
                          return;
                        }

                        Navigator.pop(context);
                        try {
                          final success = await controller.applyLeave(
                            leaveType: selectedType,
                            startDate: formatter.format(startDate),
                            endDate: formatter.format(endDate),
                            reason: reason,
                          );

                          if (success) {
                            Get.snackbar(
                              "Success",
                              "Leave application submitted successfully",
                              backgroundColor: const Color(0xFF16A34A),
                              colorText: Colors.white,
                            );
                          }
                        } catch (e) {
                          Get.snackbar(
                            "Error",
                            e.toString(),
                            backgroundColor: const Color(0xFFDC2626),
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Submit Leave Request",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
