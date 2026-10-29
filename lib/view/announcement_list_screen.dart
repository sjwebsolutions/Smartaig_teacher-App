import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../controller/announcement_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/app_bar/app_top_bar.dart';

class AnnouncementListScreen extends GetView<AnnouncementController> {
  const AnnouncementListScreen({super.key});

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
          title: "Announcements",
          showBack: true,
          showDivider: false,
        ),
        body: SafeArea(
          child: RefreshIndicator(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: announcementList.length,
                itemBuilder: (context, index) {
                  final item = announcementList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
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
                          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                            GestureDetector(
                              onTap: () => _showFullScreenImage(
                                context,
                                item.imageUrl!,
                                item.title ?? "Announcement",
                              ),
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                memCacheWidth: 600,
                                memCacheHeight: 400,
                                maxWidthDiskCache: 1200,
                                maxHeightDiskCache: 800,
                                placeholder: (context, url) => Container(
                                  height: 160,
                                  color: Colors.grey[100],
                                  child: const Center(child: SpinKitFadingCircle(color: AppColors.primary, size: 25)),
                                ),
                                errorWidget: (context, url, error) => const SizedBox.shrink(),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(14),
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
                                const SizedBox(height: 10),
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
                                  const Divider(height: 20),
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
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, String title) {
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
            title: title,
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
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: AppColors.primary),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: InkWell(
                    onTap: () async {
                      try {
                        final tempDir = await getTemporaryDirectory();
                        final path = '${tempDir.path}/shared_announcement.png';
                        await Dio().download(imageUrl, path);
                        await Share.shareXFiles([XFile(path)]);
                      } catch (e) {
                        Get.snackbar("Error", "Could not share image");
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
                            "Share Image",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                            Text(
                              "Share Image",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

      fullscreenDialog: false,
    );
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
}
