import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../controller/banner_controller.dart';
import '../../themes/appColors_&_styles/app_Colors.dart';
import '../../themes/appColors_&_styles/text_styles.dart';
import '../../themes/app_bar/app_top_bar.dart';

class BannerWidget extends StatelessWidget {
  final EdgeInsets? margin;
  const BannerWidget({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final BannerController controller = Get.find<BannerController>();

    return Obx(() {
      final bannerList = controller.banners.value?.banners ?? [];

      if (controller.isLoading.value && bannerList.isEmpty) {
        return const SizedBox.shrink();
      }

      if (bannerList.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 6),
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
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Banners",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.black.withValues(alpha: 0.8),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 74,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 12, right: 12),
                scrollDirection: Axis.horizontal,
                itemCount: bannerList.length,
                itemBuilder: (context, index) {
                  final banner = bannerList[index];
                  return GestureDetector(
                    onTap: () => _showBannerDetail(banner, index),
                    child: Container(
                      margin: EdgeInsets.only(right: index == bannerList.length - 1 ? 0 : 10),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.05),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: banner.imageUrl ?? "",
                          fit: BoxFit.cover,
                          width: 66,
                          height: 66,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          memCacheWidth: 140,
                          memCacheHeight: 120,
                          placeholder: (context, url) => Container(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showBannerDetail(dynamic banner, int index) {
    final RxBool isSharing = false.obs;
    final String? imageUrl = banner.imageUrl;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    Future<void> shareImage() async {
      if (!hasImage) return;
      try {
        isSharing.value = true;
        final directory = await getTemporaryDirectory();
        final filePath = "${directory.path}/banner_${banner.id ?? index}.png";
        
        await Dio().download(imageUrl!, filePath);
        
        await Share.shareXFiles([XFile(filePath)], text: banner.name ?? "");
      } catch (e) {
        Get.snackbar("Error", "Failed to share image: $e", 
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isSharing.value = false;
      }
    }

    Get.to(
      () => Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppTopBar(
            title: banner.name ?? "Banner",
            showBack: true,
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: hasImage 
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_rounded, color: AppColors.primary, size: 50),
                              SizedBox(height: 10),
                              Text("No Image Available", style: TextStyle(color: AppColors.black, fontSize: 16)),
                            ],
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined, color: AppColors.primary, size: 60),
                            SizedBox(height: 16),
                            Text(
                              "No Image",
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),

                if (hasImage)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Obx(() => GestureDetector(
                      onTap: isSharing.value ? null : shareImage,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isSharing.value 
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              isSharing.value ? "PREPARING..." : "SHARE BANNER",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ),
              ],
            ),
          ),
        ),
      ),
      fullscreenDialog: false,
    );
  }
}
