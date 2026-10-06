import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../controller/leave_controller.dart';
import '../themes/appColors_&_styles/text_styles.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _reasonController = TextEditingController();
  final LeaveController controller = Get.find<LeaveController>();

  String? selectedLeaveType;
  String? selectedDayType;

  TimeOfDay halfDayStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay halfDayEnd = const TimeOfDay(hour: 13, minute: 0);

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  String? selectedAttachmentPath;
  String? selectedAttachmentName;

  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final meta = controller.leaveMeta.value;
    final categories = meta?.leaveCategories ?? [];
    final durationTypes = meta?.durationTypes ?? [];

    if (categories.isNotEmpty) {
      selectedLeaveType = categories.first.key;
    } else {
      selectedLeaveType = "casual";
    }

    if (durationTypes.isNotEmpty) {
      selectedDayType = durationTypes.first.key;
    } else {
      selectedDayType = "full_day";
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

    try {
      final success = await controller.applyLeave(
        fromDate: formatter.format(startDate),
        toDate: formatter.format(endDate),
        leaveType: selectedLeaveType ?? "casual",
        dayType: selectedDayType ?? "full_day",
        halfDayStartTime: selectedDayType == "half_day"
            ? "${halfDayStart.hour.toString().padLeft(2, '0')}:${halfDayStart.minute.toString().padLeft(2, '0')}"
            : null,
        halfDayEndTime: selectedDayType == "half_day"
            ? "${halfDayEnd.hour.toString().padLeft(2, '0')}:${halfDayEnd.minute.toString().padLeft(2, '0')}"
            : null,
        reason: reason,
        attachmentPath: selectedAttachmentPath,
      );

      if (success) {
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

  @override
  Widget build(BuildContext context) {
    final meta = controller.leaveMeta.value;
    final categories = meta?.leaveCategories ?? [];
    final durationTypes = meta?.durationTypes ?? [];

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
                      // Policy Note
                      if (meta?.policyNote != null && meta!.policyNote!.isNotEmpty)
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
                            // Leave Type Dropdown
                            const Text(
                              "Leave Type",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedLeaveType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
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
                                            child: Text(c.label ?? "Casual Leave"),
                                          ))
                                      .toList()
                                  : const [
                                      DropdownMenuItem(value: "casual", child: Text("Casual Leave")),
                                      DropdownMenuItem(value: "sick", child: Text("Sick Leave")),
                                      DropdownMenuItem(value: "other", child: Text("Other / Special Leave")),
                                    ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedLeaveType = val);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Duration Type Dropdown
                            const Text(
                              "Duration Type",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedDayType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                              ),
                              items: durationTypes.isNotEmpty
                                  ? durationTypes
                                      .map((d) => DropdownMenuItem(
                                            value: d.key ?? "full_day",
                                            child: Text(d.label ?? "Full Day"),
                                          ))
                                      .toList()
                                  : const [
                                      DropdownMenuItem(value: "full_day", child: Text("Full Day")),
                                      DropdownMenuItem(value: "half_day", child: Text("Half Day")),
                                    ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedDayType = val);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Half Day Timings if half_day
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
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: halfDayStart,
                                        );
                                        if (picked != null) {
                                          setState(() => halfDayStart = picked);
                                        }
                                      },
                                      icon: const Icon(Icons.access_time_rounded, size: 18),
                                      label: Text("Start: ${halfDayStart.format(context)}"),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: halfDayEnd,
                                        );
                                        if (picked != null) {
                                          setState(() => halfDayEnd = picked);
                                        }
                                      },
                                      icon: const Icon(Icons.access_time_rounded, size: 18),
                                      label: Text("End: ${halfDayEnd.format(context)}"),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],

                            // From & To Dates
                            const Text(
                              "Date Range",
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
                                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Reason
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
                              decoration: InputDecoration(
                                hintText: "Enter detailed reason...",
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
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

                            // Attachment Picker
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
