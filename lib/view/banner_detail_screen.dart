import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/banner_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/app_bar/app_top_bar.dart';
import '../services/share_service.dart';

class BannerDetailScreen extends StatelessWidget {
  const BannerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final BannerData? banner = args['banner'];
    final String heroTag = args['heroTag'] ?? 'banner_tag';

    final String? imageUrl = banner?.imageUrl;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

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
          title: banner?.name ?? "Banner",
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
                  child: Hero(
                    tag: heroTag,
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
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
                              Text("No Image", style: TextStyle(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ),

              if (hasImage)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (banner != null && banner.imageUrl != null) {
                        ShareService.shareBanner(
                          banner.imageUrl!,
                          banner.name,
                          banner.wishing,
                        );
                      }
                    },
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Share with Others",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
      ),
    );
  }
}
