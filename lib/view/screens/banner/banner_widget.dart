import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../controller/banner_controller.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController controller = Get.find<BannerController>();

    return Obx(() {
      // Show loader while loading data from API
      if (controller.isLoading.value) {
        return Container(
          height: 150,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: SpinKitFadingCircle(
              color: AppColors.primary,
              size: 35.0,
            ),
          ),
        );
      }

      final bannerList = controller.banners.value?.banners ?? [];

      if (bannerList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              itemCount: bannerList.length,
              controller: controller.bannerPageController,
              physics: bannerList.length <= 1 
                  ? const NeverScrollableScrollPhysics() 
                  : const BouncingScrollPhysics(),
              onPageChanged: (index) {
                controller.currentBannerIndex.value = index;
              },
              itemBuilder: (context, index) {
                final banner = bannerList[index];
                return AnimatedScale(
                  scale: (bannerList.length > 1 && controller.currentBannerIndex.value == index) || bannerList.length == 1 
                      ? 1.0 
                      : 0.9,
                  duration: const Duration(milliseconds: 400),
                  child: GestureDetector(
                    onTap: () {
                      if (banner.imageUrl != null) {
                        Get.to(
                          () => Scaffold(
                            backgroundColor: Colors.black,
                            body: Stack(
                              children: [
                                // Main Image
                                Center(
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Hero(
                                      tag: 'banner_${banner.id ?? index}',
                                      child: CachedNetworkImage(
                                        imageUrl: banner.imageUrl!,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        placeholder: (context, url) => const Center(
                                          child: SpinKitFadingCircle(color: Colors.white, size: 40),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Top Controls
                                Positioned(
                                  top: 50,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                                    ),
                                  ),
                                ),

                                // Bottom Share Button
                                Positioned(
                                  bottom: 40,
                                  left: 40,
                                  right: 40,
                                  child: GestureDetector(
                                    onTap: () {
                                      Share.share("${banner.name ?? 'Banner'}\n${banner.imageUrl}");
                                    },
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primary.withValues(alpha: 0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.share_rounded, color: Colors.white, size: 22),
                                          SizedBox(width: 12),
                                          Text(
                                            "Share with Others",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          fullscreenDialog: true,
                          transition: Transition.zoom,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: 'banner_${banner.id ?? index}',
                          child: CachedNetworkImage(
                            imageUrl: banner.imageUrl ?? "",
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => const Center(
                              child: SpinKitFadingCircle(
                                color: AppColors.primary,
                                size: 25.0,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: AppColors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (bannerList.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerList.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: controller.currentBannerIndex.value == index
                        ? AppColors.primary
                        : AppColors.grey.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    });
  }
}
