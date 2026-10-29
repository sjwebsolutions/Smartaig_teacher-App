import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/banner_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/app_bar/app_top_bar.dart';
import '../models/banner_model.dart';

class BannerScreen extends GetView<BannerController> {
  const BannerScreen({super.key});

  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.primary;
    category = category.toLowerCase();
    if (category.contains('urgent') || category.contains('important')) return Colors.redAccent;
    if (category.contains('holiday') || category.contains('vacation')) return Colors.orangeAccent;
    if (category.contains('event') || category.contains('celebration')) return Colors.purpleAccent;
    if (category.contains('news') || category.contains('update')) return Colors.blueAccent;
    return AppColors.primary;
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
        appBar: const AppTopBar(
          backgroundColor: Colors.transparent,
          title: "Banners",
          showBack: true,
          showDivider: false,
        ),
        body: SafeArea(
          child: RefreshIndicator(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: bannerList.length,
                itemBuilder: (context, index) {
                  final banner = bannerList[index];
                  final String heroTag = 'banner_list_${banner.id ?? index}_$index';
                  return _buildBannerCard(banner, heroTag);
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCard(BannerData banner, String heroTag) {
    final categoryColor = _getCategoryColor(banner.category);

    return GestureDetector(
      onTap: () => Get.toNamed('/bannerDetail', arguments: {'banner': banner, 'heroTag': heroTag}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl ?? "",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 170,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (context, url) => Container(
                        height: 170,
                        color: AppColors.primary.withValues(alpha: 0.05),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 170,
                        color: Colors.grey[100],
                        child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                  if (banner.category != null && banner.category!.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          banner.category!.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.name ?? "Announcement",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    if (banner.publishedAt != null && banner.publishedAt!.isNotEmpty)
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.parse(banner.publishedAt!)),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 60, color: Colors.grey[300]),
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
}
