import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/image_update_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class StudentImageUpdateScreen extends GetView<ImageUpdateController> {
  const StudentImageUpdateScreen({super.key});

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
          title: "Image Update Requests",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
            );
          }

          if (controller.classesList.isEmpty) {
            return const Center(child: Text("No update requests found"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.classesList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final item = controller.classesList[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.class_outlined, color: AppColors.primary),
                  ),
                  title: Text(
                    "${item.className} - ${item.sectionName}",
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: item.streamName != null ? Text(item.streamName!) : null,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                  onTap: () {
                    Get.toNamed('/studentUpdateList', arguments: {
                      'class_id': item.classId,
                      'section_id': item.sectionId,
                      'stream_id': item.streamId,
                      'class_name': item.className,
                      'section_name': item.sectionName,
                    });
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
