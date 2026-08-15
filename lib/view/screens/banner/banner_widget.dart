import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../controller/banner_controller.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BannerController controller = Get.find<BannerController>();

    return Obx(() {
      final bannerList = controller.banners.value?.banners ?? [];

      if (controller.isLoading.value) {
        return Container(
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: const SpinKitFadingCircle(color: AppColors.primary, size: 30),
        );
      }

      if (bannerList.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 160,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: bannerList.length,
          itemBuilder: (context, index) {
            final banner = bannerList[index];
            return GestureDetector(
              onTap: () => _showBannerDetail(banner, index),
              child: Container(
                width: 115,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl ?? "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: SpinKitFadingCircle(color: AppColors.primary, size: 20),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _showBannerDetail(dynamic banner, int index) {
    // Local variable to track sharing state within the dialog context
    final RxBool isSharing = false.obs;

    Future<void> shareImage() async {
      if (banner.imageUrl == null) return;
      try {
        isSharing.value = true;
        final directory = await getTemporaryDirectory();
        final filePath = "${directory.path}/banner_${banner.id ?? index}.png";
        
        await Dio().download(banner.imageUrl!, filePath);
        
        await Share.shareXFiles([XFile(filePath)], text: banner.name ?? "");
      } catch (e) {
        Get.snackbar("Error", "Failed to share image: $e", 
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isSharing.value = false;
      }
    }

    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: banner.imageUrl!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: SpinKitFadingCircle(color: Colors.white, size: 40),
                  ),
                ),
              ),
            ),
            
            // Close Button
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

            // Share Button
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Obx(() => GestureDetector(
                onTap: isSharing.value ? null : shareImage,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
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
                      const SizedBox(width: 12),
                      Text(
                        isSharing.value ? "PREPARING..." : "SHARE BANNER",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
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
      fullscreenDialog: true,
    );
  }
}
