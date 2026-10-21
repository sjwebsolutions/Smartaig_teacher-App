import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/notification_controller.dart';
import '../../themes/appColors_&_styles/app_Colors.dart';

class NotificationAction extends StatelessWidget {
  const NotificationAction({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Obx(() {
      final count = notificationController.calculatedUnreadCount;
      final showBadge = count > 0 || notificationController.hasNewNotifications.value;
      final badgeText = count > 99 ? '99+' : (count > 0 ? '$count' : '1');

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: () {
              notificationController.markAsRead();
              notificationController.fetchNotifications(isRefresh: true);
              Get.toNamed('/notifications');
            },
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 28),
          ),
          if (showBadge)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
