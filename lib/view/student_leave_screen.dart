import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/student_leave_controller.dart';
import '../models/class_list_model.dart';
import '../models/student_leave_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';
import '../utils/app_snackbar.dart';

class StudentLeaveScreen extends GetView<StudentLeaveController> {
  const StudentLeaveScreen({super.key});

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
        backgroundColor: Colors.transparent,
        appBar: const AppTopBar(
          title: "Student Leave Requests",
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top Filters Section
              _buildTopHeaderFilters(context),

              // Main Content Body
              Expanded(
                child: Obx(() {
                  if (controller.isClassesLoading.value ||
                      (controller.isLoading.value && controller.leavesList.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage.isNotEmpty && controller.leavesList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.red),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Error Occurred",
                              style: AppTextStyles.h2.copyWith(color: AppColors.red, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => controller.fetchInchargeClasses(),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                              label: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final leaves = controller.leavesList;

                  if (leaves.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => controller.fetchStudentLeaves(),
                      child: ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.event_note_rounded, size: 54, color: Colors.grey[400]),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No Student Leaves Found",
                                  style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.primary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "There are no leave requests for the selected filter.",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchStudentLeaves(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: leaves.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final leave = leaves[index];
                        return _buildStudentLeaveCard(context, leave);
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

  Widget _buildTopHeaderFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Dropdown Row
          Obx(() {
            final classes = controller.classes;
            final selected = controller.selectedClass.value;

            if (classes.isEmpty) return const SizedBox.shrink();

            return Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ClassData>(
                        value: selected,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                        items: classes.map((cls) {
                          final label = cls.displayName ?? "${cls.className ?? ''} - ${cls.sectionName ?? ''}";
                          return DropdownMenuItem<ClassData>(
                            value: cls,
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.changeClass(val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _pickDateFilter(context),
                  style: IconButton.styleFrom(
                    backgroundColor: controller.selectedDate.value.isNotEmpty
                        ? AppColors.primary
                        : Colors.white,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(
                    Icons.calendar_month_rounded,
                    color: controller.selectedDate.value.isNotEmpty ? Colors.white : AppColors.primary,
                  ),
                ),
              ],
            );
          }),

          if (controller.selectedDate.value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Date: ${controller.selectedDate.value}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => controller.clearDateFilter(),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Filter Chips (All, Pending, Approved, Rejected)
          Obx(() {
            final currentStatus = controller.selectedStatus.value;
            final filters = [
              {'label': 'All', 'value': 'all'},
              {'label': 'Pending', 'value': 'pending'},
              {'label': 'Approved', 'value': 'approved'},
              {'label': 'Rejected', 'value': 'rejected'},
            ];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((f) {
                  final isSelected = currentStatus == f['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        f['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      onSelected: (val) {
                        if (val) {
                          controller.changeStatusFilter(f['value']!);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStudentLeaveCard(BuildContext context, StudentLeaveData leave) {
    final status = (leave.status ?? 'pending').toLowerCase();
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.hourglass_bottom_rounded;

    if (status == 'approved') {
      statusColor = AppColors.greensuccess;
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'rejected' || status == 'denied') {
      statusColor = AppColors.red;
      statusIcon = Icons.cancel_rounded;
    }

    final canAction = (controller.canApprove.value || status == 'pending') && status == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Student Name & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.studentName ?? "Student",
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (leave.className != null && leave.className!.isNotEmpty)
                          Text(
                            "${leave.className} - ${leave.sectionName ?? ''}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        if (leave.rollNo != null && leave.rollNo!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            "• Roll: ${leave.rollNo}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                        if (leave.admissionNumber != null && leave.admissionNumber!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            "• Adm: ${leave.admissionNumber}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      (leave.statusLabel ?? leave.status ?? "PENDING").toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 14),

          // Dates & Duration Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem("From Date", leave.fromDateFormatted ?? leave.fromDate ?? "N/A", Icons.calendar_today_rounded),
              _buildInfoItem("To Date", leave.toDateFormatted ?? leave.toDate ?? "N/A", Icons.event_rounded),
              _buildInfoItem("Duration", "${leave.totalDays ?? 1} Day(s) (${leave.dayTypeLabel ?? 'Full Day'})", Icons.timelapse_rounded),
            ],
          ),

          if (leave.reason != null && leave.reason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reason for leave:",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    leave.reason!,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],

          if (leave.approverRemarks != null && leave.approverRemarks!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Remarks: ${leave.approverRemarks}",
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
          ],

          if (leave.rejectionReason != null && leave.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Rejection Reason: ${leave.rejectionReason}",
              style: const TextStyle(fontSize: 11, color: AppColors.red, fontWeight: FontWeight.w500),
            ),
          ],

          // Approve / Reject Action Buttons if allowed
          if (canAction && leave.id != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, leave.id!),
                    icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.red),
                    label: const Text("Reject", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(context, leave.id!),
                    icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                    label: const Text("Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greensuccess,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  void _pickDateFilter(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      controller.setDateFilter(formatted);
    }
  }

  void _showApproveDialog(BuildContext context, int leaveId) {
    final remarksController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Approve Leave", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to approve this student leave request?", style: TextStyle(fontSize: 13)),
            const SizedBox(height: 14),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                hintText: "Optional remarks...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                final success = await controller.approveLeave(leaveId, remarksController.text);
                if (success) {
                  AppSnackBar.success("Leave approved successfully!");
                } else {
                  AppSnackBar.error("Failed to approve leave");
                }
              } catch (e) {
                AppSnackBar.error(e.toString());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.greensuccess),
            child: const Text("Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, int leaveId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Reject Leave", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.red)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Please enter a reason for rejecting this leave request:", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 14),
              TextFormField(
                controller: reasonController,
                validator: (val) => (val == null || val.trim().isEmpty) ? "Reason is required" : null,
                decoration: InputDecoration(
                  hintText: "Reason for rejection...",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Get.back();
                try {
                  final success = await controller.rejectLeave(leaveId, reasonController.text);
                  if (success) {
                    AppSnackBar.success("Leave rejected successfully");
                  } else {
                    AppSnackBar.error("Failed to reject leave");
                  }
                } catch (e) {
                  AppSnackBar.error(e.toString());
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text("Reject", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
