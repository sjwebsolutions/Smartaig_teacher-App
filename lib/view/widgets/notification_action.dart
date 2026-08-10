import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/announcement_controller.dart';
import '../../themes/appColors_&_styles/app_Colors.dart';

class NotificationAction extends StatelessWidget {
  const NotificationAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final announcementController = Get.find<AnnouncementController>();
      final hasNew = announcementController.hasNewNotifications.value;
      
      return Stack(
        children: [
          IconButton(
            onPressed: () {
              announcementController.markAsRead();
              Get.toNamed('/banners');
            },
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 28),
          ),
          if (hasNew)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      );
    });
  }
}
