import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
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
          height: 160,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
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
                            appBar: AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              leading: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                onPressed: () => Get.back(),
                              ),
                              actions: [
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  onPressed: () {
                                    Share.share("${banner.name ?? 'Banner'}\n${banner.imageUrl}");
                                  },
                                ),
                              ],
                            ),
                            body: Center(
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: CachedNetworkImage(
                                  imageUrl: banner.imageUrl!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          fullscreenDialog: true,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                        child: CachedNetworkImage(
                          imageUrl: banner.imageUrl ?? "",
                          fit: BoxFit.fill,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: AppColors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (bannerList.length > 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerList.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: controller.currentBannerIndex.value == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: controller.currentBannerIndex.value == index
                        ? AppColors.primary
                        : AppColors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
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
