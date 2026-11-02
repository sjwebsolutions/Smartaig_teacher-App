import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/event_controller.dart';
import '../models/event_pass_scan_response_model.dart';
import '../models/event_check_in_response_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class EventPassDetailScreen extends StatefulWidget {
  const EventPassDetailScreen({super.key});

  @override
  State<EventPassDetailScreen> createState() => _EventPassDetailScreenState();
}

class _EventPassDetailScreenState extends State<EventPassDetailScreen> {
  EventPassScanResponseModel? response;
  List<EventAttendeeInfo> approvedAttendees = [];
  List<EventAttendeeInfo> rejectedAttendees = [];
  int checkedInCount = 0;
  int remainingCount = 0;

  @override
  void initState() {
    super.initState();
    response = Get.arguments as EventPassScanResponseModel?;
    if (response?.data != null) {
      approvedAttendees = List.from(response!.data!.approvedAttendees ?? []);
      rejectedAttendees = List.from(response!.data!.rejectedAttendees ?? []);

      final pass = response!.data!.pass;
      final int initialApproved =
          approvedAttendees.isNotEmpty ? approvedAttendees.length : (pass?.totalAttendeesApproved ?? 0);
      final int initialCheckedIn =
          pass?.totalCheckedIn ?? approvedAttendees.where((a) => a.isCheckedIn == true).length;

      checkedInCount = initialCheckedIn;
      remainingCount = (pass?.totalRemaining != null && pass!.totalRemaining! >= 0)
          ? pass.totalRemaining!
          : (initialApproved - initialCheckedIn).clamp(0, 999);
    }
  }

  void _clockInAllApproved() {
    if (approvedAttendees.isEmpty) return;

    Get.toNamed('/eventCheckInResult', arguments: {
      'approvedAttendees': approvedAttendees,
      'student': response?.data?.student,
      'pass': response?.data?.pass,
      'event': response?.data?.event,
    })?.then((updatedRes) {
      if (updatedRes is EventCheckInResponseModel && updatedRes.data != null) {
        setState(() {
          final timeStr = updatedRes.data?.checkedInAt ?? "Just now";
          for (var att in approvedAttendees) {
            att.isCheckedIn = true;
            att.checkedInAt ??= timeStr;
          }
          if (updatedRes.data?.totalCheckedIn != null) {
            checkedInCount = updatedRes.data!.totalCheckedIn!;
          } else {
            checkedInCount = approvedAttendees.length;
          }
          remainingCount = (approvedAttendees.length - checkedInCount).clamp(0, 999);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (response == null || response?.data == null) {
      return Scaffold(
        appBar: const AppTopBar(title: "Pass Details", showBack: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text("No pass detail data available"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    final data = response!.data!;
    final pass = data.pass;
    final event = data.event;
    final student = data.student;

    final bool isDuplicate = response!.isAlreadyCheckedIn == true ||
        (response!.warning != null && response!.warning!.isNotEmpty);

    void onOkPressed() {
      Get.back();
      if (Get.isRegistered<EventController>()) {
        Get.find<EventController>().resetScanResult();
      }
    }

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
          title: "Pass Scan Result",
          backgroundColor: Colors.transparent,
          showBack: true,
          onBack: onOkPressed,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Scrollable Detail Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (Get.isRegistered<EventController>()) {
                      await Get.find<EventController>().fetchTodayScans();
                    }
                  },
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Status Alert Banner
                      if (isDuplicate ||
                          response!.warning != null ||
                          response!.message != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDuplicate
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDuplicate
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFF86EFAC),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDuplicate ? Colors.red : Colors.green)
                                    .withValues(alpha: 0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isDuplicate
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_rounded,
                                size: 20,
                                color: isDuplicate
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF16A34A),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isDuplicate
                                          ? "DUPLICATE / CHECKED-IN ALERT"
                                          : "PASS SCAN SUCCESSFUL",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDuplicate
                                            ? const Color(0xFF991B1B)
                                            : const Color(0xFF166534),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      response!.warning ??
                                          response!.message ??
                                          "Pass status processed.",
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        height: 1.3,
                                        fontWeight: FontWeight.w500,
                                        color: isDuplicate
                                            ? const Color(0xFF7F1D1D)
                                            : const Color(0xFF14532D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Student Profile Card
                      if (student != null) ...[
                        _buildSectionHeader("STUDENT INFORMATION", Icons.person_rounded),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Student Photo
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: student.photoUrl != null &&
                                            student.photoUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: student.photoUrl!,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              width: 56,
                                              height: 56,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.person,
                                                  color: Colors.grey),
                                            ),
                                            errorWidget: (context, url, error) =>
                                                Container(
                                              width: 56,
                                              height: 56,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.person,
                                                  color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            width: 56,
                                            height: 56,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.person,
                                                color: Colors.grey),
                                          ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.studentName ?? "N/A",
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        if (student.studentNamePunjabi != null &&
                                            student.studentNamePunjabi!.isNotEmpty) ...[
                                          const SizedBox(height: 1),
                                          Text(
                                            student.studentNamePunjabi!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _buildTag(
                                              "Adm: ${student.admissionNumber ?? 'N/A'}",
                                              AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            _buildTag(
                                              "Class: ${student.classSection ?? student.studentClass ?? 'N/A'}",
                                              const Color(0xFF059669),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                              ),

                              // Details
                              _buildDetailRow("Roll No", student.rollNo ?? "N/A"),
                              _buildDetailRow("Father",
                                  "${student.fatherName ?? 'N/A'} (${student.fatherMobile ?? 'N/A'})"),
                              _buildDetailRow("Mother",
                                  "${student.motherName ?? 'N/A'} (${student.motherMobile ?? 'N/A'})"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Event Details Card
                      if (event != null) ...[
                        _buildSectionHeader("EVENT DETAILS", Icons.event_rounded),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title ?? "Event Title",
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildDetailRow("Venue", event.venue ?? "N/A"),
                              _buildDetailRow("Dates",
                                  "${event.startDate ?? ''} - ${event.endDate ?? ''}"),
                              _buildDetailRow("Timings",
                                  "${event.startTime ?? ''} - ${event.endTime ?? ''}"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Pass Status & Summary Card
                      if (pass != null) ...[
                        _buildSectionHeader("PASS STATUS & SUMMARY", Icons.confirmation_number_rounded),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow("Pass Number", pass.passNumber ?? "N/A"),
                              _buildDetailRow(
                                  "Approval Status", (pass.approvalStatus ?? "N/A").toUpperCase()),
                              _buildDetailRow(
                                  "Check-in Status", (pass.checkinStatus ?? "N/A").toUpperCase()),
                              if (pass.firstCheckinAt != null)
                                _buildDetailRow("First Check-in", pass.firstCheckinAt!),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                              ),

                              // Stats Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn(
                                    "Approved",
                                    "${approvedAttendees.isNotEmpty ? approvedAttendees.length : (pass.totalAttendeesApproved ?? 0)}",
                                    const Color(0xFF2563EB),
                                  ),
                                  _buildStatColumn(
                                    "Checked In",
                                    "$checkedInCount",
                                    const Color(0xFF059669),
                                  ),
                                  _buildStatColumn(
                                    "Remaining",
                                    "$remainingCount",
                                    const Color(0xFFD97706),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Approve Attendance Card (Approved Attendees with Check In Button)
                      if (approvedAttendees.isNotEmpty) ...[
                        _buildSectionHeader("APPROVE ATTENDANCE", Icons.how_to_reg_rounded),
                        const SizedBox(height: 4),
                        _buildApprovedAttendanceCard(),
                        const SizedBox(height: 6),
                      ],

                      // Rejected Attendees List
                      if (rejectedAttendees.isNotEmpty) ...[
                        _buildSectionHeader(
                            "REJECTED ATTENDEES (${rejectedAttendees.length})",
                            Icons.person_off_rounded),
                        const SizedBox(height: 4),
                        ...rejectedAttendees.map((att) => _buildAttendeeCard(att, false)),
                        const SizedBox(height: 6),
                      ],
                    ],
                  ),
                ),
              ),
            ),

              // Fixed Bottom OK Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 8),
                color: Colors.transparent,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onOkPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 3,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
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

  Widget _buildApprovedAttendanceCard() {
    if (approvedAttendees.isEmpty) return const SizedBox.shrink();

    final bool allCheckedIn = approvedAttendees.every((a) => a.isCheckedIn == true);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
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
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "APPROVED ATTENDEES (${approvedAttendees.length})",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      "$checkedInCount of ${approvedAttendees.length} Checked In",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Header Check In Button (Green)
              ElevatedButton.icon(
                onPressed: _clockInAllApproved,
                icon: Icon(
                  allCheckedIn ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                label: Text(
                  allCheckedIn ? "CHECK IN ALL" : "CHECK IN ALL",
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // List of Approved Attendees inside this Card
          ...approvedAttendees.map((att) => _buildApprovedAttendeeItem(att)),
        ],
      ),
    );
  }

  Widget _buildApprovedAttendeeItem(EventAttendeeInfo attendee) {
    final bool checkedIn = attendee.isCheckedIn == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Attendee Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: attendee.photoUrl != null && attendee.photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: attendee.photoUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 20, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendee.name ?? "N/A",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "${attendee.personType ?? ''} • ${attendee.mobileNo ?? ''}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                if (attendee.maskedAadhaar != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    "Aadhaar: ${attendee.maskedAadhaar}",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Clean Status Badge (Non-clickable static badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: checkedIn ? const Color(0xFFD1FAE5) : const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              checkedIn ? "CHECKED IN" : "APPROVED",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: checkedIn ? const Color(0xFF047857) : const Color(0xFF1E40AF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Colors.black.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.h2.copyWith(
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeCard(EventAttendeeInfo attendee, bool isApproved) {
    final bool checkedIn = attendee.isCheckedIn == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isApproved
              ? (checkedIn ? const Color(0xFF059669) : Colors.grey.shade300)
                  .withValues(alpha: 0.3)
              : Colors.red.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Attendee Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: attendee.photoUrl != null && attendee.photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: attendee.photoUrl!,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 42,
                      height: 42,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 42,
                      height: 42,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 20, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 42,
                    height: 42,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 20, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendee.name ?? "N/A",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "${attendee.personType ?? ''} • ${attendee.mobileNo ?? ''}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                if (attendee.maskedAadhaar != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    "Aadhaar: ${attendee.maskedAadhaar}",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isApproved
                  ? (checkedIn
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7))
                  : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              isApproved
                  ? (checkedIn
                      ? "CHECKED IN"
                      : "PENDING")
                  : "REJECTED",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isApproved
                    ? (checkedIn
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309))
                    : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
