import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/student_leave_controller.dart';
import '../models/class_list_model.dart';
import '../models/student_leave_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/app_bar/app_top_bar.dart';
import '../utils/app_snackbar.dart';

class StudentLeaveScreen extends GetView<StudentLeaveController> {
  const StudentLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.isRegistered<StudentLeaveController>()
        ? Get.find<StudentLeaveController>()
        : Get.put(StudentLeaveController());

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
          title: "Student Leave Requests",
          showBack: true,
          showDivider: false,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),

              // Class Selector Row
              _buildClassSelector(),

              Expanded(
                child: Obx(() {
                  if (controller.isClassesLoading.value ||
                      (controller.isLoading.value && controller.allLeavesList.isEmpty)) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  if (controller.errorMessage.isNotEmpty && controller.allLeavesList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.red),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Error Occurred",
                              style: TextStyle(color: AppColors.red, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => controller.fetchInchargeClasses(),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                              label: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final leaves = controller.leavesList;

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchStudentLeaves(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Leave Requests Summary Card
                          _buildSummaryCard(
                            controller.pendingCount.value,
                            controller.approvedCount.value,
                            controller.rejectedCount.value,
                            controller.totalCount.value,
                          ),

                          const SizedBox(height: 4),

                          // 2. Horizontal Status Filter Chips
                          _buildFilterChips(),

                          const SizedBox(height: 4),

                          // 3. Student Leave Cards List
                          if (leaves.isEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.rule_folder_outlined, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "No Student Leave Found",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "No leave requests match the selected filter.",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(top: 4, bottom: 16),
                              itemCount: leaves.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final leave = leaves[index];
                                return _buildStudentLeaveCard(context, leave);
                              },
                            ),
                        ],
                      ),
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

  // Class Selector Dropdown Bar
  Widget _buildClassSelector() {
    return Obx(() {
      final classes = controller.classes;
      final selected = controller.selectedClass.value;

      if (classes.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ClassData>(
              value: selected,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              menuMaxHeight: 320,
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              items: classes.map((cls) {
                final isCurrent = selected == cls;
                final label = cls.displayName ?? "${cls.className ?? ''}-${cls.sectionName ?? ''}";

                return DropdownMenuItem<ClassData>(
                  value: cls,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.class_rounded,
                          size: 16,
                          color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Class: $label",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                            color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.changeClass(val);
              },
            ),
          ),
        ),
      );
    });
  }

  // Card 1: Leave Requests Summary
  Widget _buildSummaryCard(int pending, int approved, int rejected, int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_bus_filled_rounded, color: Color(0xFF10B981), size: 18),
              SizedBox(width: 6),
              Text(
                "Leave Requests Summary",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSummaryStatBox(
                label: "Pending",
                count: "$pending",
                bgColor: const Color(0xFFFFFBEB),
                borderColor: const Color(0xFFFDE68A),
                textColor: const Color(0xFFD97706),
                icon: Icons.hourglass_top_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryStatBox(
                label: "Approved",
                count: "$approved",
                bgColor: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                textColor: const Color(0xFF059669),
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryStatBox(
                label: "Rejected",
                count: "$rejected",
                bgColor: const Color(0xFFFEF2F2),
                borderColor: const Color(0xFFFECACA),
                textColor: const Color(0xFFDC2626),
                icon: Icons.cancel_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryStatBox(
                label: "Total",
                count: "$total",
                bgColor: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFFBFDBFE),
                textColor: const Color(0xFF2563EB),
                icon: Icons.assignment_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatBox({
    required String label,
    required String count,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: textColor),
                const SizedBox(width: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: textColor.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter Chips Row
  Widget _buildFilterChips() {
    final filters = [
      {'label': 'Pending', 'value': 'pending', 'color': const Color(0xFFD97706)},
      {'label': 'Approved', 'value': 'approved', 'color': const Color(0xFF059669)},
      {'label': 'Rejected', 'value': 'rejected', 'color': const Color(0xFFDC2626)},
      {'label': 'All', 'value': 'all', 'color': const Color(0xFF2563EB)},
    ];

    return Obx(() {
      final currentStatus = controller.selectedStatus.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: filters.map((f) {
            final isSelected = currentStatus == f['value'];
            final filterColor = f['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => controller.changeStatusFilter(f['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? filterColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? filterColor : filterColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? filterColor.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        f['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : filterColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // Student Leave Card
  Widget _buildStudentLeaveCard(BuildContext context, StudentLeaveData leave) {
    final status = (leave.status ?? 'pending').toLowerCase();

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusTextColor = const Color(0xFFD97706);
    String statusText = leave.statusLabel ?? "Pending";

    if (status == 'approved') {
      statusBg = const Color(0xFFD1FAE5);
      statusTextColor = const Color(0xFF059669);
    } else if (status == 'rejected' || status == 'denied') {
      statusBg = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
    }

    final isPending = status == 'pending';
    final studentInitial = (leave.studentName != null && leave.studentName!.isNotEmpty)
        ? leave.studentName![0].toUpperCase()
        : 'A';

    final classNameFormatted = (leave.className != null && leave.sectionName != null)
        ? "${leave.className}-${leave.sectionName}"
        : (leave.className ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar, Name, Details, Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    studentInitial,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.studentName ?? "Student Name",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Adm: ${leave.admissionNumber ?? 'N/A'} • Roll: ${leave.rollNo ?? 'N/A'} • Class: $classNameFormatted",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 6),

          // Row 2: Date Range & Duration Badge
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xFF6366F1)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${leave.fromDateFormatted ?? leave.fromDate ?? ''} - ${leave.toDateFormatted ?? leave.toDate ?? ''} (${leave.totalDays ?? 1} Days)",
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  leave.dayTypeLabel ?? "Full Day",
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Row 3: Reason Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reason for Leave:",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (leave.reason != null && leave.reason!.isNotEmpty)
                      ? leave.reason!
                      : "N/A",
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (leave.approverRemarks != null && leave.approverRemarks!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "Remarks: ${leave.approverRemarks}",
              style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
          ],

          if (leave.rejectionReason != null && leave.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "Rejection Reason: ${leave.rejectionReason}",
              style: const TextStyle(fontSize: 10.5, color: AppColors.red, fontWeight: FontWeight.bold),
            ),
          ],

          // Row 4: Action Buttons (Approve & Reject)
          if (isPending && leave.id != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                // Approve Button (Green Solid)
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(context, leave.id!),
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 15),
                      label: const Text(
                        "Approve",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Reject Button (Red Solid)
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(context, leave.id!),
                      icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 15),
                      label: const Text(
                        "Reject",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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

  void _showApproveDialog(BuildContext context, int leaveId) {
    final remarksController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
            SizedBox(width: 8),
            Text("Approve Leave", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to approve this student leave request?",
              style: TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                hintText: "Optional remarks (Leave empty if none)...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                final remarks = remarksController.text.trim();
                final success = await controller.approveLeave(
                  leaveId, 
                  remarks.isNotEmpty ? remarks : null,
                );
                if (success) {
                  AppSnackBar.success("Student leave approved successfully!");
                } else {
                  AppSnackBar.error("Failed to approve leave");
                }
              } catch (e) {
                AppSnackBar.error(e.toString());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Approve Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text("Reject Leave", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444), fontSize: 17)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please enter a reason for rejecting this leave request:",
                style: TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                validator: (val) => (val == null || val.trim().isEmpty) ? "Reason is required" : null,
                decoration: InputDecoration(
                  hintText: "Reason for rejection...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Get.back();
                try {
                  final success = await controller.rejectLeave(leaveId, reasonController.text);
                  if (success) {
                    AppSnackBar.success("Student leave rejected successfully");
                  } else {
                    AppSnackBar.error("Failed to reject leave");
                  }
                } catch (e) {
                  AppSnackBar.error(e.toString());
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Reject Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
