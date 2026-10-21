import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/notification_controller.dart';
import '../models/notification_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.mainGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppTopBar(
          backgroundColor: Colors.transparent,
          title: "NOTIFICATIONS",
          showBack: true,
          showDivider: false,
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => controller.fetchNotifications(isRefresh: true),
            color: AppColors.primary,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: SpinKitFadingCircle(color: AppColors.primary, size: 40.0),
                );
              }

              if (controller.notifications.isEmpty) {
                return _buildEmptyState();
              }

              final filteredList = controller.filteredNotifications;

              return Column(
                children: [
                  _buildFilterChips(),
                  Expanded(
                    child: filteredList.isEmpty
                        ? _buildNoFilterMatchState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            itemCount: filteredList.length + (controller.hasMore.value ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == filteredList.length) {
                                controller.loadMore();
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: SpinKitFadingCircle(color: AppColors.primary, size: 28),
                                  ),
                                );
                              }

                              final item = filteredList[index];
                              return _buildNotificationCard(item);
                            },
                          ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final defaultFilters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Student Leaves', 'value': 'student_leaves'},
      {'label': 'Teacher Leaves', 'value': 'teacher_leaves'},
      {'label': 'Announcements', 'value': 'announcements'},
      {'label': 'Homework', 'value': 'homework'},
    ];

    final dynamicModules = <String>{};
    for (var item in controller.notifications) {
      final mod = item.displayModule.toLowerCase().trim();
      if (mod.isNotEmpty &&
          mod != 'leaves' &&
          mod != 'teacher_leaves' &&
          mod != 'student_leaves' &&
          mod != 'announcements' &&
          mod != 'homework' &&
          mod != 'all' &&
          mod != 'unread') {
        dynamicModules.add(mod);
      }
    }

    final filters = List<Map<String, String>>.from(defaultFilters);
    for (var mod in dynamicModules) {
      filters.add({
        'label': mod[0].toUpperCase() + mod.substring(1),
        'value': mod,
      });
    }

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final filterValue = filter['value']!;
          final filterLabel = filter['label']!;
          final isSelected = controller.selectedFilter.value == filterValue;

          return InkWell(
            onTap: () => controller.changeFilter(filterValue),
            borderRadius: BorderRadius.circular(7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.black.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  filterLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    final isUnread = item.isRead == false;
    final displayTime = (item.timeAgo != null && item.timeAgo!.isNotEmpty)
        ? item.timeAgo!
        : _formatDate(item.createdAt ?? item.updatedAt);
    final moduleText = item.displayModule;
    final bodyText = item.displayBody;
    final titleText = item.displayTitle;

    return InkWell(
      onTap: () {
        controller.markSingleAsRead(item);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isUnread ? 0.08 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isUnread
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.08),
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isUnread
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnread ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                color: isUnread ? AppColors.primary : AppColors.primary.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Row: Title + Module Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          titleText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            color: isUnread ? AppColors.primary : Colors.black87,
                          ),
                        ),
                      ),
                      if (moduleText.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            moduleText.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Body Text
                  if (bodyText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      bodyText,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black87,
                        height: 1.35,
                      ),
                    ),
                  ],
                  // Optional Image
                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Bottom Row: Time (Left) + Read Status Icon (Right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (displayTime.isNotEmpty)
                        Text(
                          displayTime,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? Colors.redAccent.withValues(alpha: 0.12)
                              : Colors.green.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isUnread ? Icons.circle : Icons.check_rounded,
                          color: isUnread ? Colors.redAccent : Colors.green,
                          size: isUnread ? 8 : 12,
                        ),
                      ),
                    ],
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

  Widget _buildNoFilterMatchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            "No Notifications Found",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "No notifications match the selected filter.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 600,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Notifications",
              style: AppTextStyles.h2.copyWith(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
