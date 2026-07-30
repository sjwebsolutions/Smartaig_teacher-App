import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../../../controller/dashboard_controller_v2.dart';
import '../../../controller/banner_controller.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/appColors_&_styles/text_styles.dart';
import '../../../themes/app_bar/app_top_bar.dart';
import '../../academic_modules_screens.dart';
import '../banner/banner_widget.dart';

class NewTeacherDashboardScreen extends StatelessWidget {
  const NewTeacherDashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final NewDashboardController dashboardController = Get.find<NewDashboardController>();

    const EdgeInsets kCardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 1);
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
              onRefresh: () async {
                await dashboardController.fetchDashboard(showLoading: false);
                if (Get.isRegistered<BannerController>()) {
                  await Get.find<BannerController>().fetchBanners(showLoading: false);
                }
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      _buildTeacherInfoCard(dashboardController, kCardMargin, kCardPadding),
                      const SizedBox(height: 9),
                      const BannerWidget(),
                      const SizedBox(height: 6),
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
    return Container(
      color: const Color(0xFFF8F9FD),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.white,
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section Skeleton
              Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 18, width: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Banner Skeleton
              Container(
                height: 165,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 25),

              // Attendance Card Skeleton (Highly Detailed)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(height: 18, width: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        Container(height: 22, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Row(
                      children: List.generate(2, (index) => Expanded(
                        child: Column(
                          children: [
                            Container(height: 14, width: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                            const SizedBox(height: 10),
                            Container(height: 20, width: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                          ],
                        )),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(height: 50, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // Academic Modules Skeleton
              Row(
                children: [
                  Container(height: 20, width: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
                  Container(height: 20, width: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                ],
              ),
              const SizedBox(height: 25),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (_, __) => Column(
                  children: [
                    Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 12, width: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherInfoCard(NewDashboardController controller, EdgeInsets margin, EdgeInsets padding) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05), width: 1),
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
                        useOldImageOnUrlChange: true,
                        fadeInDuration: Duration.zero,
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
    );
  }

  Widget _buildAttendanceCard(NewDashboardController controller, EdgeInsets margin, EdgeInsets padding) {
    return Container(
      margin: margin,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final isLoading = controller.isLoading.value;
              final attendance = controller.dashboard.value?.data?.todayAttendance;
              final isPresent = attendance?.status == "present" || controller.isMarked.value;

              String statusText = (isLoading && attendance == null) 
                  ? "Checking..." 
                  : (attendance?.statusLabel ?? (isPresent ? "Present" : "Absent"));
              Color statusColor = isPresent ? AppColors.green : AppColors.red;
              Color bgColor = statusColor.withValues(alpha: 0.1);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Daily Attendance",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.black.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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

            Obx(() {
              final isMarked = controller.isMarked.value;
              final clockIn = controller.clockInTime.value;
              final clockOut = controller.clockOutTime.value;

              return IntrinsicHeight(
                child: Row(
                  children: [
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: VerticalDivider(
                        color: AppColors.grey.withValues(alpha: 0.2),
                        thickness: 1.5,
                        width: 30,
                      ),
                    ),
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
                time != null ? DateFormat('hh:mm a').format(time) : ".............",
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Academic Modules",
              style: AppTextStyles.body.copyWith(
                color: AppColors.black.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const AcademicModuleGrid(),
          ],
        ),
      ),
    );
  }
}
