import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/banner_model.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../services/share_service.dart';

class BannerDetailScreen extends StatelessWidget {
  const BannerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments;
    final BannerData banner = args['banner'];
    final String heroTag = args['heroTag'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full Screen Image
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: heroTag,
                child: Image.network(
                  banner.imageUrl ?? "",
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
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
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
          
          // Top Bar (Back & Share)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        if (banner.imageUrl != null) {
                          ShareService.shareBanner(
                            banner.imageUrl!,
                            banner.name,
                            banner.wishing,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
