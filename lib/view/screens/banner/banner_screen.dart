import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controller/banner_controller.dart';
import '../../../controller/announcement_controller.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/app_bar/app_top_bar.dart';
import '../../../models/banner_model.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: Colors.transparent,
            title: "Updates",
            showBack: true,
            showDivider: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Banners"),
                  Tab(text: "Announcements"),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _BannerTab(),
            _AnnouncementTab(),
          ],
        ),
      ),
    ),
  );
}
}

class _BannerTab extends GetView<BannerController> {
  const _BannerTab();

  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.primary;
    category = category.toLowerCase();
    if (category.contains('urgent') || category.contains('important')) return Colors.redAccent;
    if (category.contains('holiday') || category.contains('vacation')) return Colors.orangeAccent;
    if (category.contains('event') || category.contains('celebration')) return Colors.purpleAccent;
    if (category.contains('news') || category.contains('update')) return Colors.blueAccent;
    return AppColors.primary;
  }

  bool _isNew(String? dateStr) {
    if (dateStr == null) return false;
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays <= 2;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchBanners(),
      color: AppColors.primary,
      child: Obx(() {
        final bannerList = controller.banners.value?.banners ?? [];

        if (controller.isLoading.value) {
          return const Center(child: SpinKitFadingCircle(color: AppColors.primary, size: 40.0));
        }

        if (bannerList.isEmpty) {
          return _buildEmptyState("No Banners Found", "We'll notify you when new banners are available.");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          itemCount: bannerList.length,
          itemBuilder: (context, index) {
            final banner = bannerList[index];
            final String heroTag = 'banner_list_${banner.id ?? index}';
            return _buildBannerCard(banner, heroTag);
          },
        );
      }),
    );
  }

  Widget _buildBannerCard(BannerData banner, String heroTag) {
    final categoryColor = _getCategoryColor(banner.category);
    final isNew = _isNew(banner.publishedAt);

    return GestureDetector(
      onTap: () => Get.toNamed('/bannerDetail', arguments: {'banner': banner, 'heroTag': heroTag}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl ?? "",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 160,
                      errorWidget: (context, url, error) => Container(
                        height: 160,
                        color: Colors.grey[100],
                        child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                ),
                if (banner.category != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        banner.category!.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.name ?? "Announcement",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 4),
                  if (banner.publishedAt != null)
                    Text(
                      DateFormat('dd MMM yyyy').format(DateTime.parse(banner.publishedAt!)),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

  );
}
}

class _AnnouncementTab extends GetView<AnnouncementController> {
  const _AnnouncementTab();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchAnnouncements(),
      color: AppColors.primary,
      child: Obx(() {
        final announcementList = controller.announcements.value?.data ?? [];

        if (controller.isLoading.value) {
          return const Center(child: SpinKitFadingCircle(color: AppColors.primary, size: 40.0));
        }

        if (announcementList.isEmpty) {
          return _buildEmptyState("No Announcements", "Stay tuned for school updates and news.");
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          itemCount: announcementList.length,
          itemBuilder: (context, index) {
            final item = announcementList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 150,
                          color: Colors.grey[100],
                          child: const Center(child: SpinKitFadingCircle(color: AppColors.primary, size: 25)),
                        ),
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (item.type ?? "Notice").toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (item.fromDate != null)
                                Text(
                                  DateFormat('dd MMM yyyy').format(DateTime.parse(item.fromDate!)),
                                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.title ?? "Announcement",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description ?? "",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                          if (item.createdBy != null) ...[
                            const Divider(height: 24),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 14, color: Colors.grey[400]),
                                const SizedBox(width: 6),
                                Text(
                                  "By: ${item.createdBy}",
                                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

Widget _buildEmptyState(String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
        ),
      ],
    ),
  );
}
