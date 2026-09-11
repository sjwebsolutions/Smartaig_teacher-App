import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/admit_card_scanner_controller.dart';
import '../models/admit_card_verify_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class AdmitCardDetailScreen extends StatelessWidget {
  const AdmitCardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdmitCardVerifyData? data = Get.arguments as AdmitCardVerifyData?;

    if (data == null) {
      return const Scaffold(
        appBar: AppTopBar(title: "Admit Card Details"),
        body: Center(child: Text("No admit card details available")),
      );
    }

    final student = data.student;
    final admitCard = data.admitCard;
    final seatingPlan = data.seatingPlan;
    final feeBalance = data.feeBalance;
    final datesheet = data.datesheetSchedule ?? [];
    final todaySeat = seatingPlan?.todaySeat;

    void onNextScan() {
      Get.back(); // Return to scanner
      if (Get.isRegistered<AdmitCardScannerController>()) {
        Get.find<AdmitCardScannerController>().resumeScanning();
      }
    }

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
        appBar: AppTopBar(
          title: "Admit Card Details",
          backgroundColor: Colors.transparent,
          showBack: true,
          onBack: () {
            Get.back();
            if (Get.isRegistered<AdmitCardScannerController>()) {
              Get.find<AdmitCardScannerController>().resumeScanning();
            }
          },
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top 30px gap
              const SizedBox(height: 30),

              // "Scan Next Admit Card" Button at TOP
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF233263), Color(0xFF1E293B)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF233263).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onNextScan,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Scan Next Admit Card",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 1. Student Profile Card (with embedded Parent Details)
              _buildStudentProfileCard(student),

              const SizedBox(height: 12),

              // 2. Today's Seating Arrangement Card
              if (todaySeat != null) ...[
                _buildTodaySeatCard(todaySeat, seatingPlan?.arrangementName),
                const SizedBox(height: 12),
              ],

              // 3. Admit Card Info / Final Examination Details
              if (admitCard != null) ...[
                _buildAdmitCardInfo(admitCard),
                const SizedBox(height: 12),
              ],

              // 4. Fee Balance Alert (Placed directly under Final Examination)
              if (feeBalance != null && (feeBalance.hasDue == true || (feeBalance.balanceTillToday != null && feeBalance.balanceTillToday > 0))) ...[
                _buildFeeAlertBanner(feeBalance),
                const SizedBox(height: 12),
              ],

              // 5. Datesheet Schedule List
              if (datesheet.isNotEmpty) ...[
                _buildDatesheetSection(datesheet),
                const SizedBox(height: 12),
              ],

              // 6. All Seating Schedule (if available)
              if (seatingPlan != null && (seatingPlan.allSeats?.isNotEmpty ?? false)) ...[
                _buildAllSeatsSection(seatingPlan.allSeats!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentProfileCard(StudentDetail? student) {
    if (student == null) return const SizedBox.shrink();

    final hasParentDetails = (student.fatherName != null && student.fatherName!.isNotEmpty) ||
        (student.motherName != null && student.motherName!.isNotEmpty);

    final photoUrl = student.photoUrl;
    final cacheKey = (photoUrl != null && photoUrl.isNotEmpty) ? photoUrl.split('?').first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF233263).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Photo + Student Name + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo with fast caching and circular loader
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        cacheKey: cacheKey,
                        memCacheWidth: 240,
                        memCacheHeight: 240,
                        maxWidthDiskCache: 300,
                        maxHeightDiskCache: 300,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 150),
                        placeholder: (context, url) => _buildImageLoader(),
                        errorWidget: (context, url, error) => _buildAvatarPlaceholder(student.studentName),
                      )
                    : _buildAvatarPlaceholder(student.studentName),
              ),
              const SizedBox(width: 14),

              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            student.studentName ?? "Student Name",
                            style: AppTextStyles.body.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (student.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Text(
                              student.status!.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (student.gender != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              student.gender!.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2x2 Grid of Student Info (Class, Exam Roll, Adm No, DOB)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        Icons.school_rounded,
                        "CLASS",
                        student.classSection ?? student.studentClass ?? "-",
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.confirmation_number_rounded,
                        "EXAM ROLL",
                        student.examRollNo ?? "-",
                        const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        Icons.badge_rounded,
                        "ADM NO",
                        student.admissionNumber ?? "-",
                        const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.tag_rounded,
                        "ROLL NO",
                        student.rollNo ?? "N/A",
                        const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
                if (student.formattedDob != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.cake_rounded,
                          "DOB",
                          student.formattedDob!,
                          const Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.calendar_today_rounded,
                          "SESSION",
                          student.session ?? "-",
                          const Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Parent / Guardian Details
          if (hasParentDetails) ...[
            const SizedBox(height: 12),
            const Divider(height: 16, thickness: 0.8, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people_alt_rounded, size: 15, color: AppColors.primary.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                const Text(
                  "PARENT DETAILS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (student.fatherName != null && student.fatherName!.isNotEmpty)
              _buildParentRow(
                icon: Icons.person_rounded,
                label: "Father",
                name: student.fatherName!,
                mobile: student.fatherMobile,
              ),
            if (student.motherName != null && student.motherName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildParentRow(
                icon: Icons.person_outline_rounded,
                label: "Mother",
                name: student.motherName!,
                mobile: student.motherMobile,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildImageLoader() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String? name) {
    String initials = "ST";
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else if (parts[0].isNotEmpty) {
        initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return Container(
      color: const Color(0xFFE2E8F0),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF233263),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: accentColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentRow({
    required IconData icon,
    required String label,
    required String name,
    String? mobile,
  }) {
    final hasValidMobile = mobile != null && mobile.isNotEmpty && mobile != '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF475569)),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasValidMobile) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_rounded, size: 10, color: Color(0xFF2563EB)),
                  const SizedBox(width: 3),
                  Text(
                    mobile,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeAlertBanner(FeeBalanceDetail fee) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Fee Balance Alert",
                        style: TextStyle(
                          color: Color(0xFF991B1B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        fee.formattedBalance ?? "DUE",
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  fee.message ?? "Fee balance pending as of today.",
                  style: const TextStyle(
                    color: Color(0xFF7F1D1D),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySeatCard(SeatItem todaySeat, String? arrangementName) {
    final hasExam = todaySeat.hasExamToday ?? false;
    final isAssigned = todaySeat.isAssigned ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_seat_rounded, color: Color(0xFF0284C7), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Today's Exam & Seat",
                  style: AppTextStyles.body.copyWith(
                    color: const Color(0xFF0369A1),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasExam ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasExam ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  hasExam ? "EXAM TODAY" : "NO EXAM TODAY",
                  style: TextStyle(
                    color: hasExam ? const Color(0xFF15803D) : Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18, thickness: 0.5, color: Color(0xFFBAE6FD)),
          if (todaySeat.subject != null) ...[
            Text(
              todaySeat.subject!,
              style: AppTextStyles.h2.copyWith(
                fontSize: 16,
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${todaySeat.formattedDate ?? ''} (${todaySeat.day ?? ''})",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (isAssigned && todaySeat.seatLabel != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.meeting_room_rounded, color: Color(0xFF0284C7), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      todaySeat.seatLabel!,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              todaySeat.message ?? "Seat not assigned",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdmitCardInfo(AdmitCardDetail card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.badge_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  card.examTitle ?? "Admit Card Details",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (card.examCenterName != null)
            _buildDetailLine(Icons.location_on_rounded, "Center", card.examCenterName!, const Color(0xFF8B5CF6)),
          if (card.startTime != null && card.endTime != null)
            _buildDetailLine(Icons.access_time_rounded, "Timing", "${card.startTime} - ${card.endTime}", const Color(0xFF3B82F6)),
          if (card.session != null)
            _buildDetailLine(Icons.calendar_today_rounded, "Session", card.session!, const Color(0xFF0284C7)),
        ],
      ),
    );
  }

  Widget _buildDatesheetSection(List<DatesheetScheduleItem> schedule) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Datesheet Schedule",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  "${schedule.length} Exams",
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...schedule.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        item.formattedDate?.split(' ').first ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AppColors.primary,
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
                          item.subjectName ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${item.formattedDate ?? ''} (${item.day ?? ''})",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (item.timing != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.timing!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAllSeatsSection(List<SeatItem> seats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event_seat_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "All Exam Seating",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Text(
                  "${seats.length} Exams",
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Seating Cards List (Green if assigned, Red if not assigned)
          ...seats.map((seat) {
            final isAssigned = seat.isAssigned == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAssigned ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAssigned ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            seat.subject ?? "Exam",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isAssigned ? const Color(0xFF166534) : const Color(0xFF991B1B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (seat.formattedDate != null && seat.formattedDate!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            seat.formattedDate!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isAssigned ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isAssigned ? Icons.meeting_room_rounded : Icons.info_outline_rounded,
                          color: isAssigned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            seat.seatLabel ?? seat.message ?? (isAssigned ? "Seat assigned" : "Seat not assigned"),
                            style: TextStyle(
                              fontSize: 12,
                              color: isAssigned ? const Color(0xFF15803D) : const Color(0xFF991B1B),
                              fontWeight: isAssigned ? FontWeight.w700 : FontWeight.w500,
                              fontStyle: isAssigned ? FontStyle.normal : FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailLine(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
