import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/event_controller.dart';
import '../models/event_pass_scan_response_model.dart';
import '../models/event_check_in_response_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';
import '../utils/app_snackbar.dart';

class EventCheckInResultScreen extends StatefulWidget {
  const EventCheckInResultScreen({super.key});

  @override
  State<EventCheckInResultScreen> createState() => _EventCheckInResultScreenState();
}

class _EventCheckInResultScreenState extends State<EventCheckInResultScreen> {
  List<EventAttendeeInfo> approvedAttendees = [];
  EventStudentInfo? student;
  EventPassInfo? pass;
  EventInfo? event;
  EventCheckInResponseModel? checkInRes;

  Set<int> selectedAttendeeIds = {};
  bool isCheckedInSuccess = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments is Map<String, dynamic>
        ? Get.arguments as Map<String, dynamic>
        : {};

    approvedAttendees = List<EventAttendeeInfo>.from(args['approvedAttendees'] ?? []);
    if (approvedAttendees.isEmpty && args['attendee'] != null) {
      approvedAttendees = [args['attendee'] as EventAttendeeInfo];
    }
    student = args['student'] as EventStudentInfo?;
    pass = args['pass'] as EventPassInfo?;
    event = args['event'] as EventInfo?;
    checkInRes = args['checkInRes'] as EventCheckInResponseModel?;

    // Pre-select all un-checked approved attendee IDs
    selectedAttendeeIds = approvedAttendees
        .where((a) => a.id != null)
        .map((a) => a.id!)
        .toSet();

    if (checkInRes != null || (approvedAttendees.isNotEmpty && approvedAttendees.every((a) => a.isCheckedIn == true))) {
      isCheckedInSuccess = true;
    }
  }

  Future<void> _performCheckIn() async {
    if (selectedAttendeeIds.isEmpty) {
      AppSnackBar.error("Please select at least 1 person to check in");
      return;
    }

    final passId = pass?.id;
    if (passId == null) {
      setState(() {
        isCheckedInSuccess = true;
      });
      return;
    }

    try {
      setState(() {
        isSubmitting = true;
      });

      final controller = Get.isRegistered<EventController>()
          ? Get.find<EventController>()
          : Get.put(EventController());

      final res = await controller.checkInPass(
        passId: passId,
        attendeeIds: selectedAttendeeIds.toList(),
        gateName: "Main Gate",
      );

      setState(() {
        checkInRes = res;
        isCheckedInSuccess = true;
        isSubmitting = false;
      });

      AppSnackBar.success(res?.message ?? "Check-in successful for ${selectedAttendeeIds.length} person(s)!");
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      AppSnackBar.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: isCheckedInSuccess ? "Check-In Confirmation" : "Select Persons to Check In",
          backgroundColor: Colors.transparent,
          showBack: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCheckedInSuccess) ...[
                        // Success Banner State
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      checkInRes?.message ?? "GATE ADMISSION SUCCESSFUL",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF166534),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "Checked in at: ${checkInRes?.data?.checkedInAt ?? 'Just now'}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        // Person Selection Instruction Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 22),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  "Select the persons physically present at the gate for Check-In:",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Select All Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selectedAttendeeIds.length == approvedAttendees.where((a) => a.id != null).length && approvedAttendees.isNotEmpty,
                                activeColor: const Color(0xFF059669),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (bool? val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedAttendeeIds = approvedAttendees.where((a) => a.id != null).map((a) => a.id!).toSet();
                                    } else {
                                      selectedAttendeeIds.clear();
                                    }
                                  });
                                },
                              ),
                              Text(
                                "SELECT ALL PERSONS (${selectedAttendeeIds.length}/${approvedAttendees.length})",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Persons List Card with Checkboxes
                      _buildSectionHeader(
                        isCheckedInSuccess ? "ADMITTED PERSONS (${approvedAttendees.length})" : "PERSONS FOR CHECK-IN",
                        Icons.group_rounded,
                      ),
                      const SizedBox(height: 6),
                      ...approvedAttendees.map((att) => _buildPersonItem(att)),
                      const SizedBox(height: 14),

                      // Student Details
                      if (student != null) ...[
                        _buildSectionHeader("STUDENT INFORMATION", Icons.person_rounded),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: _cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("Student Name", student!.studentName ?? 'N/A'),
                              _buildDetailRow("Admission No", student!.admissionNumber ?? 'N/A'),
                              _buildDetailRow("Class & Section", student!.classSection ?? student!.studentClass ?? 'N/A'),
                              _buildDetailRow("Roll No", student!.rollNo ?? 'N/A'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Event & Pass Summary
                      _buildSectionHeader("EVENT & PASS DETAILS", Icons.confirmation_number_rounded),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: _cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow("Pass Number", checkInRes?.data?.passNumber ?? pass?.passNumber ?? 'N/A'),
                            if (event != null)
                              _buildDetailRow("Event Title", event!.title ?? 'N/A'),
                            _buildDetailRow("Gate Entrance", checkInRes?.data?.gateName ?? "Main Gate"),
                            if (checkInRes?.data?.admittedCount != null)
                              _buildDetailRow("Admitted Count", "${checkInRes!.data!.admittedCount}"),
                            if (checkInRes?.data?.totalCheckedIn != null)
                              _buildDetailRow("Total Checked-In", "${checkInRes!.data!.totalCheckedIn} / ${checkInRes?.data?.totalApproved ?? pass?.totalAttendeesApproved ?? approvedAttendees.length}"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : (isCheckedInSuccess ? () => Get.back(result: checkInRes) : _performCheckIn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckedInSuccess ? AppColors.primary : const Color(0xFF059669),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            isCheckedInSuccess
                                ? "DONE / CLOSE"
                                : "CONFIRM CHECK IN (${selectedAttendeeIds.length} SELECTED)",
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonItem(EventAttendeeInfo attendee) {
    final bool isSelected = attendee.id != null && selectedAttendeeIds.contains(attendee.id);
    final bool checkedIn = attendee.isCheckedIn == true;

    return GestureDetector(
      onTap: isCheckedInSuccess ? null : () {
        setState(() {
          if (attendee.id != null) {
            if (isSelected) {
              selectedAttendeeIds.remove(attendee.id!);
            } else {
              selectedAttendeeIds.add(attendee.id!);
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF86EFAC) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox for selection
            if (!isCheckedInSuccess)
              Checkbox(
                value: isSelected,
                activeColor: const Color(0xFF059669),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (bool? val) {
                  setState(() {
                    if (attendee.id != null) {
                      if (val == true) {
                        selectedAttendeeIds.add(attendee.id!);
                      } else {
                        selectedAttendeeIds.remove(attendee.id!);
                      }
                    }
                  });
                },
              ),

            // Attendee Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: attendee.photoUrl != null && attendee.photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: attendee.photoUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendee.name ?? "N/A",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${attendee.personType ?? 'Attendee'} • ${attendee.mobileNo ?? ''}",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  if (attendee.maskedAadhaar != null)
                    Text(
                      "Aadhaar: ${attendee.maskedAadhaar}",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                ],
              ),
            ),

            if (isCheckedInSuccess || checkedIn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF047857)),
                    SizedBox(width: 4),
                    Text(
                      "CHECKED IN",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
      border: Border.all(
        color: AppColors.primary.withValues(alpha: 0.08),
        width: 1,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
          ),
          const Text(" : ", style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
