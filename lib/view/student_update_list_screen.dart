import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/image_update_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class StudentUpdateListScreen extends StatefulWidget {
  const StudentUpdateListScreen({super.key});

  @override
  State<StudentUpdateListScreen> createState() => _StudentUpdateListScreenState();
}

class _StudentUpdateListScreenState extends State<StudentUpdateListScreen> {
  final ImageUpdateController controller = Get.find<ImageUpdateController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchStudents(
        args['class_id'],
        args['section_id'],
        args['stream_id'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final className = args['class_name'];
    final sectionName = args['section_name'];

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
          title: "$className - $sectionName",
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

          if (controller.studentsList.isEmpty) {
            return const Center(child: Text("No students found in this class"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.studentsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final student = controller.studentsList[index];
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
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.05), width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (student.currentProfileImage != null && student.currentProfileImage!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: student.currentProfileImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: Icon(Icons.person, color: AppColors.primary, size: 25),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.person, color: AppColors.primary, size: 25),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.person, color: AppColors.primary, size: 25),
                              ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.studentName ?? "No name",
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Unique ID: ${student.studentUniqueId ?? '-'}",
                              style: AppTextStyles.body.copyWith(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            if (student.hasPendingRequest == true)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "PENDING REQUEST",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final result = await Get.toNamed('/studentImageUpload', arguments: student);
                          if (result == true) {
                            final args = Get.arguments as Map<String, dynamic>;
                            controller.fetchStudents(
                              args['class_id'],
                              args['section_id'],
                              args['stream_id'],
                            );
                          }
                        },
                        icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.05),
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
    );
  }
}
