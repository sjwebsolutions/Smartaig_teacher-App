import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/student_leave_controller.dart';
import '../models/class_list_model.dart';
import '../models/student_leave_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../utils/app_snackbar.dart';

class LeavesScreen extends GetView<StudentLeaveController> {
  const LeavesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    Get.isRegistered<StudentLeaveController>()
        ? Get.find<StudentLeaveController>()
        : Get.put(StudentLeaveController());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0EAFC),
            Color(0xFFCFDEF3),
            Color(0xFFF3E8FF),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header Bar
              _buildAppBar(context),

              // Class Selector Row
              _buildClassSelector(),

              Expanded(
                child: Obx(() {
                  if (controller.isClassesLoading.value ||
                      (controller.isLoading.value && controller.leavesList.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage.isNotEmpty && controller.leavesList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.red),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Error Occurred",
                              style: TextStyle(color: AppColors.red, fontSize: 18, fontWeight: FontWeight.bold),
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
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                              label: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final leaves = controller.leavesList;
                  final total = leaves.length;
                  final pending = leaves.where((l) => (l.status ?? '').toLowerCase() == 'pending').length;
                  final approved = leaves.where((l) => (l.status ?? '').toLowerCase() == 'approved').length;
                  final rejected = leaves.where((l) => (l.status ?? '').toLowerCase() == 'rejected' || (l.status ?? '').toLowerCase() == 'denied').length;

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchStudentLeaves(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Leave Requests Summary Card
                          _buildSummaryCard(total, pending, approved, rejected),

                          // 2. Horizontal Status Filter Chips
                          _buildFilterChips(),

                          // 3. Student Leave Cards List
                          if (leaves.isEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.rule_folder_outlined, size: 54, color: Colors.grey[400]),
                                  const SizedBox(height: 14),
                                  const Text(
                                    "No Student Leave Found",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 6),
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
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: leaves.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
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

  // Header Bar
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              "STUDENT LEAVE REQUESTS",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ClassData>(
              value: selected,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E293B)),
              items: classes.map((cls) {
                final label = cls.displayName ?? "${cls.className ?? ''}-${cls.sectionName ?? ''}";
                return DropdownMenuItem<ClassData>(
                  value: cls,
                  child: Row(
                    children: [
                      const Icon(Icons.class_rounded, size: 16, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Text(
                        "Class: $label",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
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
  Widget _buildSummaryCard(int total, int pending, int approved, int rejected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_bus_filled_rounded, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text(
                "Leave Requests Summary",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem(
                icon: Icons.assignment_rounded,
                iconBg: const Color(0xFF3B82F6),
                count: "$total",
                label: "Total",
              ),
              _buildVerticalDivider(),
              _buildSummaryItem(
                icon: Icons.history_rounded,
                iconBg: const Color(0xFFF59E0B),
                count: "$pending",
                label: "Pending",
              ),
              _buildVerticalDivider(),
              _buildSummaryItem(
                icon: Icons.check_rounded,
                iconBg: const Color(0xFF10B981),
                count: "$approved",
                label: "Approved",
              ),
              _buildVerticalDivider(),
              _buildSummaryItem(
                icon: Icons.close_rounded,
                iconBg: const Color(0xFFEF4444),
                count: "$rejected",
                label: "Rejected",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconBg,
    required String count,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 10, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Text(
                count,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: iconBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.grey[200],
    );
  }

  // Card 2: Filter Chips Row
  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all', 'color': const Color(0xFF2563EB)},
      {'label': 'Pending', 'value': 'pending', 'color': const Color(0xFFF59E0B)},
      {'label': 'Approved', 'value': 'approved', 'color': const Color(0xFF10B981)},
      {'label': 'Rejected', 'value': 'rejected', 'color': const Color(0xFFEF4444)},
    ];

    return Obx(() {
      final currentStatus = controller.selectedStatus.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: filters.map((f) {
            final isSelected = currentStatus == f['value'];
            final filterColor = f['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => controller.changeStatusFilter(f['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? filterColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? filterColor : filterColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? filterColor.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        f['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : filterColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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

  // Card 3: Student Leave Card
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar, Name, Details, Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    studentInitial,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.studentName ?? "Student Name",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Adm No: ${leave.admissionNumber ?? 'N/A'} • Roll: ${leave.rollNo ?? 'N/A'} • Class: $classNameFormatted",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 14),

          // Row 2: Date Range & Duration Badge
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${leave.fromDateFormatted ?? leave.fromDate ?? ''} - ${leave.toDateFormatted ?? leave.toDate ?? ''} (${leave.totalDays ?? 1} Days)",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  leave.dayTypeLabel ?? "Full Day",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 3: Reason Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reason for Leave:",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (leave.reason != null && leave.reason!.isNotEmpty)
                      ? leave.reason!
                      : "N/A",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

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
              style: const TextStyle(fontSize: 11, color: AppColors.red, fontWeight: FontWeight.bold),
            ),
          ],

          // Row 4: Action Buttons (Approve & Reject)
          if (isPending && leave.id != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                // Approve Button (Green Solid)
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(context, leave.id!),
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        "Approve",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Reject Button (Red Solid)
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(context, leave.id!),
                      icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        "Reject",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
            SizedBox(width: 8),
            Text("Approve Leave", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to approve this student leave request?",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                hintText: "Optional remarks (Leave empty if none)...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
            Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 8),
            Text("Reject Leave", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444), fontSize: 18)),
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
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: reasonController,
                validator: (val) => (val == null || val.trim().isEmpty) ? "Reason is required" : null,
                decoration: InputDecoration(
                  hintText: "Reason for rejection...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text("Reject Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
