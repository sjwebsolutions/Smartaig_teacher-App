import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controller/announcement_controller.dart';
import '../../../themes/appColors_&_styles/app_Colors.dart';
import '../../../themes/app_bar/app_top_bar.dart';

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
        body: RefreshIndicator(
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              itemCount: announcementList.length,
              itemBuilder: (context, index) {
                final item = announcementList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 150,
                              color: Colors.grey[100],
                              child: const Center(child: SpinKitFadingCircle(color: AppColors.primary, size: 25)),
                            ),
                            errorWidget: (context, url, error) => const SizedBox.shrink(),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
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
                              const SizedBox(height: 12),
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
                                const Divider(height: 24),
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
