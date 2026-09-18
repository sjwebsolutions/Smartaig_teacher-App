import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/image_update_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class UpdateStudentDataScreen extends StatefulWidget {
  const UpdateStudentDataScreen({super.key});

  @override
  State<UpdateStudentDataScreen> createState() => _UpdateStudentDataScreenState();
}

class _UpdateStudentDataScreenState extends State<UpdateStudentDataScreen> {
  late final ImageUpdateController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ImageUpdateController>()
        ? Get.find<ImageUpdateController>()
        : Get.put(ImageUpdateController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchClasses();
      controller.fetchFormOptions();
    });
  }

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
          title: "Update Student Data",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.classesList.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (controller.errorMessage.isNotEmpty && controller.classesList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.fetchClasses();
                          controller.fetchFormOptions();
                        },
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        label: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.classesList.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchClasses();
                  await controller.fetchFormOptions();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No update requests found",
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => controller.fetchClasses(),
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                            label: const Text("Refresh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await controller.fetchClasses();
                await controller.fetchFormOptions();
              },
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
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
              ),
            );
          }),
        ),
      ),
    );
  }
}
