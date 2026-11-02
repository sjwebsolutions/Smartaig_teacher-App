import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controller/event_controller.dart';
import '../models/event_today_scans_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<EventController>()
        ? Get.find<EventController>()
        : Get.put(EventController());

    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppTopBar(
            title: "EVENTS & SCANS",
            showBack: true,
            backgroundColor: Colors.transparent,
            showDivider: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF4F46E5), // Indigo matching design
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF475569),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 18),
                          SizedBox(width: 8),
                          Text("Pass Scan"),
                        ],
                      ),
                    ),
                    Tab(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.badge_outlined, size: 18),
                          SizedBox(width: 8),
                          Text("View Gate Pass"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                // Tab 1: Pass Scan
                _buildPassScanTab(context, controller),

                // Tab 2: View Gate Pass
                _buildViewGatePassTab(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= TAB 1: PASS SCAN =================
  Widget _buildPassScanTab(BuildContext context, EventController controller) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final cameraSize = (screenWidth - 48).clamp(260.0, 320.0);
    final innerViewfinderSize = cameraSize * 0.72;

    return RefreshIndicator(
      onRefresh: () => controller.fetchTodayScans(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
        children: [
          const SizedBox(height: 8),

          // Subtitle Instruction
          const Column(
            children: [
              Text(
                "Point camera at the Event Pass QR / Barcode",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                "Pass scan will be validated automatically upon detection",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Camera Viewfinder Box
          Center(
            child: Container(
              width: cameraSize,
              height: cameraSize,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera Stream
                  Positioned.fill(
                    child: MobileScanner(
                      controller: controller.mobileScannerController,
                      onDetect: (capture) {
                        final barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final code = barcodes.first.rawValue;
                          if (code != null && code.isNotEmpty) {
                            controller.processPassScan(code);
                          }
                        }
                      },
                    ),
                  ),

                  // Inner Viewfinder Rounded Border
                  Container(
                    width: innerViewfinderSize,
                    height: innerViewfinderSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // Flash Toggle Button
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Obx(() => GestureDetector(
                          onTap: () => controller.toggleTorch(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.isTorchOn.value
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: controller.isTorchOn.value
                                  ? Colors.amber
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                        )),
                  ),

                  // Animated Cyan Glowing Laser Scan Line (when not loading)
                  Obx(() {
                    if (controller.isScanning.value) {
                      return const SizedBox.shrink();
                    }
                    return AnimatedBuilder(
                      animation: controller.scanAnimation,
                      builder: (context, child) {
                        final topStart = (cameraSize - innerViewfinderSize) / 2;
                        return Positioned(
                          top: topStart +
                              (controller.scanAnimation.value * (innerViewfinderSize - 6)),
                          child: Container(
                            width: innerViewfinderSize - 16,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF00E5FF),
                                  Color(0xFF1892FA),
                                  Color(0xFF00E5FF),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.9),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  // Camera Loader Overlay when Scanning
                  Obx(() {
                    if (!controller.isScanning.value) {
                      return const SizedBox.shrink();
                    }
                    return Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.75),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 38,
                              height: 38,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "Verifying Event Pass...",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Scan Result Feedback Box (If error/message)
          Obx(() {
            final msg = controller.scanResultMsg.value;
            final isSuccess = controller.isScanSuccess.value;

            if (msg.isEmpty || controller.isScanning.value) {
              return const SizedBox.shrink();
            }

            final Color boxBg = isSuccess ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
            final Color boxBorder = isSuccess ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5);
            final Color textColor = isSuccess ? const Color(0xFF166534) : const Color(0xFF991B1B);
            final IconData icon = isSuccess ? Icons.check_circle_rounded : Icons.warning_rounded;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: boxBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: boxBorder, width: 1),
              ),
              child: Row(
                children: [
                  Icon(icon, color: textColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      msg,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 18, color: textColor),
                    onPressed: () => controller.resetScanResult(),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Red CANCEL Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: Color(0xFFDC2626),
                ),
              ),
              label: const Text(
                "CANCEL",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                elevation: 4,
                shadowColor: const Color(0xFFE11D48).withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  // ================= TAB 2: VIEW GATE PASS =================
  Widget _buildViewGatePassTab(EventController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.eventScans.value == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final scansData = controller.eventScans.value?.data;
      final scans = scansData?.scans ?? [];
      final totalValid = scansData?.totalValidScansToday ?? 0;

      return RefreshIndicator(
        onRefresh: () => controller.fetchTodayScans(),
        color: AppColors.primary,
        child: Column(
          children: [
            const SizedBox(height: 6),

            // Summary Banner Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Valid Scans Today",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.black.withValues(alpha: 0.6),
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$totalValid",
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 20,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Scans List / Empty State
            Expanded(
              child: scans.isEmpty
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No Event Scans Today",
                                  style: AppTextStyles.h2.copyWith(
                                    fontSize: 17,
                                    color: AppColors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "No event passes have been scanned today yet.",
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12.5,
                                    color: AppColors.black.withValues(alpha: 0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                      itemCount: scans.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = scans[index];
                        return _buildScanCard(item);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildScanCard(EventScanItem item) {
    final bool isDuplicate = item.scanStatus?.toLowerCase() == 'already_entered' ||
        (item.scanMessage != null && item.scanMessage!.toLowerCase().contains('duplicate'));

    final Color statusColor = isDuplicate ? Colors.red : AppColors.green;
    final String statusLabel = (item.scanStatus ?? 'SCANNED').replaceAll('_', ' ').toUpperCase();

    return Container(
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
          color: isDuplicate
              ? Colors.red.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Pass Number & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.confirmation_number_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    item.passNumber ?? "N/A",
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.body.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.5,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          if (item.eventTitle != null && item.eventTitle!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.eventTitle!,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.black.withValues(alpha: 0.85),
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Student Info
          Row(
            children: [
              const Icon(Icons.person_rounded, size: 15, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${item.studentName ?? 'N/A'} ${item.admissionNo != null ? '(${item.admissionNo})' : ''}",
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: AppColors.black.withValues(alpha: 0.8),
                  ),
                ),
              ),
              if (item.classSection != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.classSection!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 5),

          // Gate & Scanner Info
          Row(
            children: [
              const Icon(Icons.meeting_room_rounded, size: 15, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${item.gateName ?? 'N/A'} • ${item.scannedBy ?? ''}",
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11.5,
                    color: AppColors.black.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Text(
                item.scannedAt ?? item.scannedAtFull ?? '',
                style: AppTextStyles.body.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),

          // Alert Message Box if present
          if (item.scanMessage != null && item.scanMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDuplicate ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDuplicate ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isDuplicate ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                    size: 15,
                    color: isDuplicate ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.scanMessage!,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: isDuplicate ? const Color(0xFF991B1B) : const Color(0xFF166534),
                      ),
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
}
