import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../controller/leave_controller.dart';
import '../services/fcm_services.dart';
import '../themes/appColors_&_styles/text_styles.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _reasonController = TextEditingController();
  final LeaveController controller = Get.find<LeaveController>();

  String selectedLeaveType = "casual";
  String selectedDayType = "full_day"; // "full_day" or "half_day"
  String fullDayOption = "1_day"; // "1_day" or "more_days"

  TimeOfDay? halfDayStart;
  TimeOfDay? halfDayEnd;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  String? selectedAttachmentPath;
  String? selectedAttachmentName;

  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final meta = controller.leaveMeta.value;
    final categories = meta?.leaveCategories ?? [];

    if (categories.isNotEmpty) {
      selectedLeaveType = categories.first.key ?? "casual";
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedAttachmentPath = result.files.single.path;
          selectedAttachmentName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  void _submitForm() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter a reason for leave",
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final finalStartDate = (selectedDayType == "half_day" || fullDayOption == "1_day")
        ? DateTime.now()
        : startDate;

    final finalEndDate = (selectedDayType == "half_day" || fullDayOption == "1_day")
        ? finalStartDate
        : endDate;

    try {
      final success = await controller.applyLeave(
        fromDate: apiFormatter.format(finalStartDate),
        toDate: apiFormatter.format(finalEndDate),
        leaveType: selectedLeaveType,
        dayType: selectedDayType,
        halfDayStartTime: (selectedDayType == "half_day" && halfDayStart != null)
            ? "${halfDayStart!.hour.toString().padLeft(2, '0')}:${halfDayStart!.minute.toString().padLeft(2, '0')}"
            : null,
        halfDayEndTime: (selectedDayType == "half_day" && halfDayEnd != null)
            ? "${halfDayEnd!.hour.toString().padLeft(2, '0')}:${halfDayEnd!.minute.toString().padLeft(2, '0')}"
            : null,
        reason: reason,
        attachmentPath: selectedAttachmentPath,
      );

      if (success) {
        final meta = controller.leaveMeta.value;
        final categories = meta?.leaveCategories ?? [];
        final categoryLabel = categories.firstWhereOrNull((c) => c.key == selectedLeaveType)?.label ?? selectedLeaveType.capitalizeFirst ?? "Leave";
        final formattedFrom = DateFormat('dd MMM, yyyy').format(finalStartDate);
        final formattedTo = DateFormat('dd MMM, yyyy').format(finalEndDate);

        final dateStr = (fullDayOption == "1_day" || selectedDayType == "half_day")
            ? formattedFrom
            : "$formattedFrom to $formattedTo";

        FcmService.showLocalNotification(
          title: "Leave Application Submitted",
          body: "Your $categoryLabel request for $dateStr has been submitted successfully and is pending approval.",
          payload: "teacher_leave",
        );

        Get.back();
        Get.snackbar(
          "Success",
          "Leave application submitted successfully!",
          backgroundColor: const Color(0xFF16A34A),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Widget _buildDateSelectorTile({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onDatePicked,
  }) {
    final displayFormatted = DateFormat('dd MMM, yyyy').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              onDatePicked(picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayFormatted,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String key) {
    final lower = key.toLowerCase();
    if (lower.contains('sick')) {
      return Icons.local_hospital_rounded;
    } else if (lower.contains('casual')) {
      return Icons.beach_access_rounded;
    } else {
      return Icons.event_note_rounded;
    }
  }

  Color _getCategoryColor(String key) {
    final lower = key.toLowerCase();
    if (lower.contains('sick')) {
      return const Color(0xFFDC2626); // Red
    } else if (lower.contains('casual')) {
      return const Color(0xFFD97706); // Amber
    } else {
      return const Color(0xFF2563EB); // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = controller.leaveMeta.value;
    final categories = meta?.leaveCategories ?? [];

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
                          "APPLY LEAVE",
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),

              // Form Scroll Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Policy Note (Only shown when Full Day is selected)
                      if (selectedDayType == "full_day" && meta?.policyNote != null && meta!.policyNote!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  meta.policyNote!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Form Container Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. TOP SEGMENTED BUTTONS: Full Day vs Half Day
                            const Text(
                              "Leave Duration",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => selectedDayType = "full_day"),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: selectedDayType == "full_day"
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selectedDayType == "full_day"
                                              ? const Color(0xFF2563EB)
                                              : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.wb_sunny_rounded,
                                            size: 18,
                                            color: selectedDayType == "full_day"
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Full Day",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: selectedDayType == "full_day"
                                                  ? Colors.white
                                                  : Colors.grey.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => selectedDayType = "half_day"),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: selectedDayType == "half_day"
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selectedDayType == "half_day"
                                              ? const Color(0xFF2563EB)
                                              : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.contrast_rounded,
                                            size: 18,
                                            color: selectedDayType == "half_day"
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Half Day",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: selectedDayType == "half_day"
                                                  ? Colors.white
                                                  : Colors.grey.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 2. IF FULL DAY IS SELECTED: Dropdown for "1 Day" vs "More Days"
                            if (selectedDayType == "full_day") ...[
                              const Text(
                                "Day Option",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: fullDayOption,
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                elevation: 4,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2563EB)),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: "1_day",
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.today_rounded, size: 18, color: Color(0xFF2563EB)),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text("1 Day", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "more_days",
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3E8FF),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.date_range_rounded, size: 18, color: Color(0xFF7C3AED)),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text("More Days", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => fullDayOption = val);
                                },
                              ),
                              const SizedBox(height: 16),

                              // Date Selection for Full Day ONLY if "more_days" is selected!
                              if (fullDayOption == "more_days") ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateSelectorTile(
                                        label: "From Date",
                                        date: startDate,
                                        onDatePicked: (picked) {
                                          setState(() {
                                            startDate = picked;
                                            if (endDate.isBefore(startDate)) endDate = startDate;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildDateSelectorTile(
                                        label: "To Date",
                                        date: endDate,
                                        onDatePicked: (picked) {
                                          setState(() => endDate = picked);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],

                            // 3. IF HALF DAY IS SELECTED
                            if (selectedDayType == "half_day") ...[
                              const Text(
                                "Half Day Hours",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: halfDayStart ?? const TimeOfDay(hour: 9, minute: 0),
                                        );
                                        if (picked != null) {
                                          setState(() => halfDayStart = picked);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              halfDayStart != null
                                                  ? "Start: ${halfDayStart!.format(context)}"
                                                  : "Start Time",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: halfDayStart != null ? FontWeight.w600 : FontWeight.normal,
                                                color: halfDayStart != null ? const Color(0xFF0F172A) : Colors.grey.shade500,
                                              ),
                                            ),
                                            const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF2563EB)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: halfDayEnd ?? const TimeOfDay(hour: 13, minute: 0),
                                        );
                                        if (picked != null) {
                                          setState(() => halfDayEnd = picked);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              halfDayEnd != null
                                                  ? "End: ${halfDayEnd!.format(context)}"
                                                  : "End Time",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: halfDayEnd != null ? FontWeight.w600 : FontWeight.normal,
                                                color: halfDayEnd != null ? const Color(0xFF0F172A) : Colors.grey.shade500,
                                              ),
                                            ),
                                            const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF2563EB)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],

                            // 4. Leave Category Dropdown
                            const Text(
                              "Leave Category",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: selectedLeaveType,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              elevation: 4,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2563EB)),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                              ),
                              items: categories.isNotEmpty
                                  ? categories
                                      .map((c) => DropdownMenuItem(
                                            value: c.key ?? "casual",
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: _getCategoryColor(c.key ?? "casual").withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    _getCategoryIcon(c.key ?? "casual"),
                                                    size: 18,
                                                    color: _getCategoryColor(c.key ?? "casual"),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  c.label ?? "Casual Leave",
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList()
                                  : [
                                      DropdownMenuItem(
                                        value: "casual",
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEF3C7),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.beach_access_rounded, size: 18, color: Color(0xFFD97706)),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text("Casual Leave", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "sick",
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEE2E2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.local_hospital_rounded, size: 18, color: Color(0xFFDC2626)),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text("Sick Leave", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "other",
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.event_note_rounded, size: 18, color: Color(0xFF2563EB)),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text("Other / Special Leave", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                          ],
                                        ),
                                      ),
                                    ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedLeaveType = val);
                              },
                            ),
                            const SizedBox(height: 16),

                            // 5. Reason Field
                            const Text(
                              "Reason for Leave",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _reasonController,
                              maxLines: 4,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                              decoration: InputDecoration(
                                hintText: "Enter detailed reason...",
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 6. Attachment Field
                            const Text(
                              "Attachment (Optional)",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _pickAttachment,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedAttachmentPath != null
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selectedAttachmentPath != null
                                          ? Icons.insert_drive_file_rounded
                                          : Icons.attach_file_rounded,
                                      color: selectedAttachmentPath != null
                                          ? const Color(0xFF2563EB)
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedAttachmentName ?? "Attach document or medical proof",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: selectedAttachmentPath != null
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: selectedAttachmentPath != null
                                              ? const Color(0xFF2563EB)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    if (selectedAttachmentPath != null)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedAttachmentPath = null;
                                            selectedAttachmentName = null;
                                          });
                                        },
                                        child: const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      Obx(() {
                        final isSubmitting = controller.isLoading.value;

                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              elevation: 4,
                              shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    "Submit Leave Request",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
