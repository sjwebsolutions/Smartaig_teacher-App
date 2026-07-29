import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../controller/banner_controller.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/appColors_&_styles/text_styles.dart';
import '../../../themes/app_bar/app_top_bar.dart';

class BannerScreen extends StatelessWidget {
  const BannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController controller = Get.find<BannerController>();

    return Scaffold(
      appBar: const AppTopBar(
        title: "Banners",
        showBack: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchBanners(),
        color: AppColors.primary,
        child: Obx(() {
          final bannerList = controller.banners.value?.banners ?? [];

          if (controller.isLoading.value && bannerList.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            );
          }

          if (bannerList.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: Get.height * 0.4),
                const Center(child: Text("No banners available")),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bannerList.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final banner = bannerList[index];
              final String heroTag = 'banner_${banner.id ?? index}_$index';
              
              return GestureDetector(
                onTap: () => Get.toNamed('/bannerDetail', arguments: {
                  'banner': banner,
                  'heroTag': heroTag,
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
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
                              child: Image.network(
                                banner.imageUrl ?? "",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180,
                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                  if (wasSynchronouslyLoaded) return child;
                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 1,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    child: child,
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 180,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 180,
                                  color: AppColors.grey.withValues(alpha: 0.1),
                                  child: const Icon(Icons.broken_image, color: AppColors.grey, size: 40),
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
                                  color: AppColors.primary.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  banner.category!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Banner Title",
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        banner.name ?? "Announcement",
                                        style: AppTextStyles.body.copyWith(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (banner.publishedAt != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.grey.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      DateFormat('dd MMM').format(DateTime.parse(banner.publishedAt!)),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontSize: 10,
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (banner.wishing != null && banner.wishing!.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1, thickness: 0.5),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, size: 14, color: Colors.orangeAccent),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      banner.wishing!,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 13,
                                        color: AppColors.black.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
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
      ),
    );
  }
}
