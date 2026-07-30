import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controller/banner_controller.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/appColors_&_styles/text_styles.dart';
import '../../../themes/app_bar/app_top_bar.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  // Helper function for dynamic category colors
  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.primary;
    category = category.toLowerCase();
    if (category.contains('urgent') || category.contains('important')) return Colors.redAccent;
    if (category.contains('holiday') || category.contains('vacation')) return Colors.orangeAccent;
    if (category.contains('event') || category.contains('celebration')) return Colors.purpleAccent;
    if (category.contains('news') || category.contains('update')) return Colors.blueAccent;
    return AppColors.primary;
  }

  // Helper to check if the banner is "New" (posted within last 48 hours)
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
    final BannerController controller = Get.find<BannerController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF), // Soft bluish-grey background
      appBar: const AppTopBar(
        title: "Announcements",
        showBack: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchBanners(),
        color: AppColors.primary,
        child: Obx(() {
          final bannerList = controller.banners.value?.banners ?? [];

          if (controller.isLoading.value) {
            return const Center(
              child: SpinKitFadingCircle(
                color: AppColors.primary,
                size: 50.0,
              ),
            );
          }

          if (bannerList.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            itemCount: bannerList.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final banner = bannerList[index];
              final String heroTag = 'banner_${banner.id ?? index}_$index';
              final categoryColor = _getCategoryColor(banner.category);
              final isNew = _isNew(banner.publishedAt);
              
              // Entrance Animation
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: _buildBannerCard(banner, heroTag, categoryColor, isNew),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildBannerCard(var banner, String heroTag, Color categoryColor, bool isNew) {
    return GestureDetector(
      onTap: () => Get.toNamed('/bannerDetail', arguments: {
        'banner': banner,
        'heroTag': heroTag,
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl ?? "",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 160,
                      errorWidget: (context, url, error) => Container(
                        height: 160,
                        color: AppColors.grey.withValues(alpha: 0.1),
                        child: const Icon(Icons.broken_image_rounded, color: AppColors.grey, size: 40),
                      ),
                    ),
                  ),
                ),
                // Category Glass Badge
                if (banner.category != null)
                  Positioned(
                    top: 15,
                    left: 15,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            banner.category!.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // NEW Tag
                if (isNew)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF5252), Color(0xFFFF1744)]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 8)],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Text(
                            "NEW",
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          banner.name ?? "Announcement",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A1A),
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      if (banner.publishedAt != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.primary.withValues(alpha: 0.4)),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM').format(DateTime.parse(banner.publishedAt!)),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  if (banner.wishing != null && banner.wishing!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: categoryColor.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.format_quote_rounded, size: 16, color: categoryColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              banner.wishing!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.black.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        "Tap for more info",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: Get.height * 0.25),
        Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Icon(Icons.notifications_none_rounded, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text(
                "All Quiet Here",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 12),
              Text(
                "No announcements at the moment.\nWe'll notify you when something comes up!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[500], height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
