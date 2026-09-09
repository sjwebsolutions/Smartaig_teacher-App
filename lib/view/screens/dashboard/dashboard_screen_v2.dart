import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../controller/dashboard_controller_v2.dart';
import '../../../controller/banner_controller.dart';
import '../../../controller/announcement_controller.dart';
import '../../../models/announcement_model.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/appColors_&_styles/text_styles.dart';
import '../../../themes/app_bar/app_top_bar.dart';
import '../../academic_modules_screens.dart';
import '../../widgets/notification_action.dart';
import '../banner/banner_widget.dart';
import '../../profile_screen.dart';

class NewTeacherDashboardScreen extends StatelessWidget {
  const NewTeacherDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning 🙏";
    if (hour < 17) return "Good Afternoon 🙏";
    return "Good Evening 🙏";
  }
  
  @override
  Widget build(BuildContext context) {
    final NewDashboardController dashboardController = Get.find<NewDashboardController>();
    final AnnouncementController announcementController = Get.put(AnnouncementController());
    final BannerController bannerController = Get.find<BannerController>();

    const EdgeInsets kCardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 1);
    const EdgeInsets kCardPadding = EdgeInsets.all(14);
    
    return Obx(() {
      if (dashboardController.isInitialLoading.value) {
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
            appBar: const AppTopBar(
              backgroundColor: Colors.transparent,
              showBack: false,
              showDivider: false,
            ),
            body: _buildShimmerDashboard(),
          ),
        );
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
            backgroundColor: Colors.transparent,
            showBack: false,
            showDivider: false,
            centerTitle: true,
            actions: const [
              NotificationAction(),
              SizedBox(width: 8),
            ],
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
              await announcementController.fetchAnnouncements();
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 14,
                              color: AppColors.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 2,),
                          Obx(() => Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: dashboardController.dashboard.value?.data?.teacher?.name ?? "",
                                    style: AppTextStyles.h1.copyWith(
                                      fontSize: 17,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.verified,
                                        color: Color(0xFF1892FA),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    Obx(() {
                      final banners = bannerController.banners.value?.banners ?? [];
                      final isLoading = bannerController.isLoading.value;
                      if (banners.isEmpty && !isLoading) {
                        return const SizedBox(height: 10);
                      }
                      return const Column(
                        children: [
                          SizedBox(height: 10),
                          BannerWidget(),
                          SizedBox(height: 10),
                        ],
                      );
                    }),
                    _buildTeacherInfoCard(dashboardController, kCardMargin, kCardPadding),
                    _buildAnnouncementDropdownCard(context, announcementController, kCardMargin),
                    const SizedBox(height: 10),
                    _buildAttendanceCard(dashboardController, kCardMargin, kCardPadding),
                    const SizedBox(height: 5),
                    _buildAcademicModulesSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    });
  }

  Widget _buildShimmerDashboard() {
    return Container(
      color: Colors.transparent,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.white,
        period: const Duration(milliseconds: 1500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Skeleton (Moved to top)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),

              // Profile Section Skeleton
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 20),
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

              // Attendance Card Skeleton (Highly Detailed)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
              
              Builder(
                builder: (context) {
                  final double screenWidth = MediaQuery.of(context).size.width;
                  final bool isTablet = screenWidth >= 600;
                  return
                    GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: isTablet ? 6 : 3,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 6 : 3,
                      mainAxisSpacing: 25,
                      crossAxisSpacing: 15,
                      childAspectRatio: isTablet ? 1.0 : 0.8,
                    ),
                    itemBuilder: (_, __) => Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(height: 10, width: 45, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                  );
                },
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
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08), width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              Icons.auto_awesome_mosaic_rounded,
              size: 100,
              color: AppColors.primary.withValues(alpha: 0.03),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              final teacher = controller.dashboard.value?.data?.teacher;
              return Row(
                children: [
                  // Profile Image with Ring Effect
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (teacher?.image != null && teacher!.image!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: teacher.image!,
                              fit: BoxFit.cover,
                              useOldImageOnUrlChange: true,
                              placeholder: (context, url) => const Center(
                                child: Icon(Icons.person, color: AppColors.primary, size: 40),
                              ),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.person, color: AppColors.primary, size: 40),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.person, color: AppColors.primary, size: 40),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: teacher?.name ?? "Teacher Name",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.verified,
                                    color: Color(0xFF1892FA),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (teacher?.staffType ?? "Staff").toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.alternate_email_rounded, "Emp ID: ${teacher?.id ?? '-'}"),
                        const SizedBox(height: 5),
                        _buildInfoRow(
                          Icons.location_city_rounded,
                          controller.dashboard.value?.data?.school?.schoolName ?? "No school",
                          isVerified: true,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, {bool isVerified = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 14, color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(
                    color: AppColors.black.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isVerified) ...[
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.verified,
                        color: Color(0xFF1892FA),
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementDropdownCard(BuildContext context, AnnouncementController controller, EdgeInsets margin) {
    return Obx(() {
      final announcementList = controller.announcements.value?.data ?? [];
      if (announcementList.isEmpty) return const SizedBox.shrink();

      if (controller.selectedAnnouncement.value == null && announcementList.isNotEmpty) {
        controller.selectedAnnouncement.value = announcementList.first;
      }

      final selected = controller.selectedAnnouncement.value;
      if (selected == null) return const SizedBox.shrink();

      return Column(
        children: [
          const SizedBox(height: 9),
          Container(
            margin: margin,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.05), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selected.imageUrl != null && selected.imageUrl!.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () => _showFullScreenImage(
                            context,
                            selected.imageUrl!,
                            selected.title ?? "Announcement",
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: selected.imageUrl!,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 110,
                                height: 110,
                                color: AppColors.primary.withValues(alpha: 0.05),
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected.title ?? "",
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selected.description ?? "",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.black.withValues(alpha: 0.6),
                                fontSize: 13,
                                height: 1.4,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, String title) {
    Get.to(
      () => Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FE),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
          title: Text(title, style: AppTextStyles.appbarh4.copyWith(fontSize: 18)),
        ),
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: AppColors.primary),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Center(
                child: InkWell(
                  onTap: () async {
                    try {
                      final tempDir = await getTemporaryDirectory();
                      final path = '${tempDir.path}/shared_image.png';
                      await Dio().download(imageUrl, path);
                      await Share.shareXFiles([XFile(path)]);
                    } catch (e) {
                      Get.snackbar("Error", "Could not share image");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Share Image",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      fullscreenDialog: false,
    );
  }

  Widget _buildAttendanceCard(NewDashboardController controller, EdgeInsets margin, EdgeInsets padding) {
    return Container(
      margin: margin,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
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
              
              final String? statusCode = attendance?.statusCode;
              final String? status = attendance?.status?.toLowerCase();
              final bool isMarked = attendance?.isMarked ?? false;
              // Check if teacher has clocked in during current session
              final bool localClockedIn = controller.isMarked.value || controller.clockInTime.value != null;
              
              final isPresent = status == "present" || isMarked || localClockedIn;
              final isAbsent = status == "absent" && statusCode != "NM";
              final isNotMarked = statusCode == "NM" || (status == null && !isMarked && !localClockedIn);

              String statusText;
              Color statusColor;

              if (isLoading && attendance == null) {
                statusText = "Checking...";
                statusColor = Colors.grey;
              } else if (isPresent) {
                statusText = "Present";
                statusColor = AppColors.green;
              } else if (isAbsent) {
                statusText = "Absent";
                statusColor = AppColors.red;
              } else {
                statusText = "Not marked yet";
                statusColor = Colors.orange;
              }
              Color bgColor = statusColor.withValues(alpha: 0.1);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Daily Attendance",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.black.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          const SizedBox(height: 16),
          const AcademicModuleGrid(),
        ],
      ),
    );
  }
}
