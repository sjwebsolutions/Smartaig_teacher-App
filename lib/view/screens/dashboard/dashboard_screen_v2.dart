import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:teacher_app_attendance/controller/auth_controller.dart';
import '../../../controller/dashboard_controller_v2.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/appColors_&_styles/text_styles.dart';
import '../../../themes/app_bar/app_top_bar.dart';
import 'package:get/get.dart';

import '../../academic_modules_screens.dart';
import '../banner/banner_widget.dart';

class NewTeacherDashboardScreen extends StatelessWidget {
  const NewTeacherDashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final NewDashboardController dashboardController = Get.find<NewDashboardController>();

    const EdgeInsets kCardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    const EdgeInsets kCardPadding = EdgeInsets.all(14);
    
    return Obx(() {
      if (dashboardController.isInitialLoading.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const AppTopBar(
            title: "Dashboard",
            showBack: false,
          ),
          body: _buildShimmerDashboard(),
        );
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
            backgroundColor: Colors.transparent,
            showBack: false,
            showDivider: true,
            customTitle: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dashboard", style: AppTextStyles.appbarh4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => dashboardController.fetchDashboard(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      // _buildWelcomeText(),
                      _buildTeacherInfoCard(dashboardController, kCardMargin, kCardPadding),
                      const BannerWidget(),
                      _buildAttendanceCard(dashboardController, kCardMargin, kCardPadding),
                      _buildAcademicModulesSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShimmerDashboard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Info Card Shimmer
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 15, width: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Banner Shimmer
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            
            // Attendance Card Shimmer
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 30),
            
            // Academic Modules Title Shimmer
            Container(
              height: 18,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid Items Shimmer
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, __) => Column(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildTeacherInfoCard(NewDashboardController controller, EdgeInsets margin, EdgeInsets padding) {
    return Container(
      margin: margin,
      child: Card(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05), width: 1),
        ),
        child: Padding(
          padding: padding,
          child: Obx(() {
            final teacher = controller.dashboard.value?.data?.teacher;
            return Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (teacher?.image != null && teacher!.image!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: teacher.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: Icon(Icons.person, color: AppColors.primary, size: 30),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.person, color: AppColors.primary, size: 30),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.person, color: AppColors.primary, size: 30),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(teacher?.name ?? "No name",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.black.withValues(alpha: 0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 2),
                      Text(teacher?.staffType ?? "No role",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.black.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          )),
                      Text("Emp ID: ${teacher?.id ?? '-'}",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.black.withValues(alpha: 0.4),
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(NewDashboardController controller, EdgeInsets margin, EdgeInsets padding) {
    return Container(
      margin: margin,
      width: double.infinity,
      child: Card(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.05), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Obx(() {
                final isLoading = controller.isLoading.value;
                final attendance = controller.dashboard.value?.data?.todayAttendance;
                final isPresent = attendance?.status == "present" || controller.isMarked.value;

                String statusText = isLoading ? "Checking..." : (attendance?.statusLabel ?? (isPresent ? "Present" : "Absent"));
                Color statusColor = isPresent ? AppColors.green : AppColors.red;
                Color bgColor = statusColor.withValues(alpha: 0.1);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [

                        Text(
                          "Daily Attendance",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.black.withValues(alpha: 0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText.toUpperCase(),
                        style: AppTextStyles.body.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              /// Main Content Row (Split Layout)
              Obx(() {
                final isMarked = controller.isMarked.value;
                final clockIn = controller.clockInTime.value;
                final clockOut = controller.clockOutTime.value;

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left Side: Scanner & Status Pill
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => controller.handleScannerTap(),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.05),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.qr_code_scanner_rounded,
                                    color: AppColors.primary,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isMarked
                                    ? AppColors.red.withValues(alpha: 0.08)
                                    : AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (isMarked ? AppColors.red : AppColors.primary).withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                isMarked ? "CLOCK OUT" : "CLOCK IN",
                                style: TextStyle(
                                  color: isMarked ? AppColors.red : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vertical Divider (Bold)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: VerticalDivider(
                          color: AppColors.grey.withValues(alpha: 0.2),
                          thickness: 1.5,
                          width: 30,
                        ),
                      ),

                      // Right Side: Timing Details
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimingRow(
                              icon: Icons.login_rounded,
                              label: "Clock-In",
                              time: clockIn,
                              color: AppColors.green,
                            ),
                            const SizedBox(height: 12),
                            _buildTimingRow(
                              icon: Icons.logout_rounded,
                              label: "Clock-Out",
                              time: clockOut,
                              color: AppColors.red,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimingRow({
    required IconData icon,
    required String label,
    required DateTime? time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                time != null ? DateFormat('hh:mm a').format(time) : "--:--",
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicModulesSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 1),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Academic Modules", style: AppTextStyles.body.copyWith(color: AppColors.black.withValues(alpha: 0.60), fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        const AcademicModuleGrid(),
        const SizedBox(height: 20),
      ],
    );
  }
}
