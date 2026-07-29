import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/homework_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class NewAddHomeworkScreen extends GetView<HomeworkController> {
  const NewAddHomeworkScreen({super.key});

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
          title: controller.isEditing.value ? "Edit Homework" : "Add Homework",
          showBack: true,
          backgroundColor: Colors.transparent,
        ),
        body: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Class Dropdown
                _buildLabel("Select Class"),
                _buildDropdownCard(
                  icon: Icons.school_outlined,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(15),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      hint: const Text("Choose Class"),
                      value: controller.selectedClassId.value,
                      items: controller.uniqueClasses.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.classId,
                          child: Row(
                            children: [
                              const Icon(Icons.class_outlined, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(item.className ?? "", style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedClassId.value = val;
                        final selectedItem = controller.homeworkFormData.value?.data?.firstWhere((item) => item.classId == val);
                        controller.selectedStreamId.value = selectedItem?.streamId;
                        controller.selectedSectionId.value = null;
                        controller.selectedSubjectId.value = null;
                        controller.isDiary.value = false;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// Section Dropdown
                _buildLabel("Select Section"),
                _buildDropdownCard(
                  icon: Icons.grid_view_rounded,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(15),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      hint: const Text("Choose Section"),
                      value: controller.selectedSectionId.value,
                      items: controller.sectionsForSelectedClass.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.sectionId,
                          child: Row(
                            children: [
                              const Icon(Icons.layers_outlined, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(item.sectionName ?? "", style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedSectionId.value = val;
                        controller.selectedSubjectId.value = null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                /// Subject Dropdown
                _buildLabel("Select Subject"),
                _buildDropdownCard(
                  icon: Icons.book_outlined,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(15),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      hint: const Text("Choose Subject"),
                      value: controller.selectedSubjectId.value,
                      items: controller.subjectsForSelectedSelection.map((item) {
                        return DropdownMenuItem<int>(
                          value: item.subjectId ?? -1, 
                          child: Row(
                            children: [
                              const Icon(Icons.subject_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.subjectName ?? "Diary",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.onSubjectChanged(val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel("Homework Description"),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: controller.homeworkContentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "Enter homework details here...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildLabel("Attachments (Optional)"),
                Obx(() {
                  final bool hasAnyImages = controller.images.isNotEmpty || controller.existingAttachments.isNotEmpty;
                  
                  if (!hasAnyImages) {
                    return _buildAttachmentButton(
                      icon: Icons.add_a_photo_outlined,
                      label: "Add Images",
                      onTap: () => _showImageSourceSheet(context),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // 1. Show existing network images
                            ...controller.existingAttachments.asMap().entries.map((entry) {
                              final int idx = entry.key;
                              final dynamic attachment = entry.value;
                              String imageUrl = "";
                              if (attachment is String) imageUrl = attachment;
                              else if (attachment is Map) imageUrl = attachment['file_url'] ?? attachment['url'] ?? "";

                              return _buildImageItem(
                                isNetwork: true,
                                path: imageUrl,
                                onRemove: () => controller.removeExistingImage(idx),
                              );
                            }),

                            // 2. Show newly selected files
                            ...controller.images.asMap().entries.map((entry) {
                              final int idx = entry.key;
                              final File file = entry.value;
                              return _buildImageItem(
                                isNetwork: false,
                                path: file.path,
                                onRemove: () => controller.removeImage(idx),
                              );
                            }),

                            // 3. "Add More" Button
                            GestureDetector(
                              onTap: () => _showImageSourceSheet(context),
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline, color: AppColors.primary),
                                    SizedBox(height: 4),
                                    Text("More", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => controller.isPosting.value ? null : controller.postHomework(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: controller.isPosting.value 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(controller.isEditing.value ? "UPDATE HOMEWORK" : "SUBMIT HOMEWORK", 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdownCard({required IconData icon, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
          borderRadius: BorderRadius.circular(15),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, 
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary, 
                fontWeight: FontWeight.bold, 
                fontSize: 16
              )
            ),
            const SizedBox(height: 4),
            Text("JPEG, PNG files are supported", 
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey, 
                fontSize: 11
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem({required bool isNetwork, required String path, required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
            image: DecorationImage(
              image: isNetwork ? NetworkImage(path) as ImageProvider : FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
        if (isNetwork)
          Positioned(
            bottom: 12,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text("OLD", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Image Source", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: const Text("Camera"),
              onTap: () {
                Get.back();
                controller.pickImages(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text("Gallery"),
              onTap: () {
                Get.back();
                controller.pickImages(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
