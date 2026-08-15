import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/homework_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';
import 'add_homework_screen_v2.dart';

class UploadHomeworkScreen extends GetView<HomeworkController> {
  final VoidCallback? onBack;
  const UploadHomeworkScreen({super.key, this.onBack});

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
        appBar: AppTopBar(
          title: "Homework List",
          showBack: true,
          onBack: onBack,
          backgroundColor: Colors.transparent,
        ),
        body: Obx(() {
          // If we haven't fetched data yet OR it's currently loading while the list is empty
          if (!controller.hasFetched.value || (controller.isLoading.value && controller.homeworkList.isEmpty)) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // Show "No Homework" ONLY if loading is finished and list is still empty
          if (controller.homeworkList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined,
                      size: 80, color: AppColors.primary.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    "No Homework Found",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 18,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          // Otherwise show the list
          return RefreshIndicator(
            onRefresh: () => controller.fetchHomeworkList(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: controller.homeworkList.length,
              itemBuilder: (context, index) {
                final homework = controller.homeworkList[index];
                return GestureDetector(
                  onTap: () => Get.toNamed('/homeworkDetail', arguments: homework.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${homework.className} - ${homework.sectionName}",
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                homework.date ?? "",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.black.withValues(alpha: 0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            homework.subjectName ?? "General",
                            style: AppTextStyles.body.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            homework.content ?? "",
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.black.withValues(alpha: 0.7),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 16, color: AppColors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    "By: ${homework.createdBy ?? "Teacher"}",
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 11,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => controller.handleAddHomework(),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Homework", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
