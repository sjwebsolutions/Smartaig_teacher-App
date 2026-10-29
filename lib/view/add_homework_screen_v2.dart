import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/homework_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
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
          title: controller.isEditing.value ? "EDIT HOMEWORK" : "ADD HOMEWORK",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: Obx(() {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD 1: Class, Section & Subject Details
                  _buildSectionContainer(
                    title: "Class & Subject Details",
                    icon: Icons.tune_rounded,
                    children: [
                      // Class Dropdown
                      _buildFieldLabel("Select Class", isRequired: true),
                      _buildDropdownWrapper(
                        icon: Icons.school_rounded,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(14),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                            ),
                            hint: Text(
                              "Choose Class",
                              style: TextStyle(color: Colors.grey[400], fontSize: 13.5),
                            ),
                            value: controller.selectedClassId.value,
                            items: controller.uniqueClasses.map((item) {
                              return DropdownMenuItem<String>(
                                value: item.classId,
                                child: Text(
                                  item.className ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              controller.selectedClassId.value = val;
                              final selectedItem = controller.homeworkFormData.value?.data
                                  ?.firstWhereOrNull((item) => item.classId == val);
                              controller.selectedStreamId.value = selectedItem?.streamId;
                              controller.selectedSectionId.value = null;
                              controller.selectedSubjectId.value = null;
                              controller.isDiary.value = false;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Section Dropdown
                      _buildFieldLabel("Select Section", isRequired: true),
                      _buildDropdownWrapper(
                        icon: Icons.grid_view_rounded,
                        isEnabled: controller.selectedClassId.value != null,
                        disabledHint: "Please select class first",
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(14),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                            ),
                            hint: Text(
                              "Choose Section",
                              style: TextStyle(color: Colors.grey[400], fontSize: 13.5),
                            ),
                            value: controller.selectedSectionId.value,
                            items: controller.sectionsForSelectedClass.map((item) {
                              return DropdownMenuItem<String>(
                                value: item.sectionId,
                                child: Text(
                                  item.sectionName ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: controller.selectedClassId.value == null
                                ? null
                                : (val) {
                                    controller.selectedSectionId.value = val;
                                    controller.selectedSubjectId.value = null;
                                  },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Subject Dropdown
                      _buildFieldLabel("Select Subject", isRequired: !controller.isDiary.value),
                      _buildDropdownWrapper(
                        icon: Icons.book_rounded,
                        isEnabled: controller.selectedSectionId.value != null,
                        disabledHint: "Please select section first",
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(14),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                            ),
                            hint: Text(
                              "Choose Subject / Diary",
                              style: TextStyle(color: Colors.grey[400], fontSize: 13.5),
                            ),
                            value: controller.selectedSubjectId.value,
                            items: controller.subjectsForSelectedSelection.map((item) {
                              final bool isDiaryItem = item.subjectName?.toLowerCase().contains("diary") ?? false;
                              return DropdownMenuItem<int>(
                                value: item.subjectId ?? -1,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.subjectName ?? "Diary",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isDiaryItem) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.greensuccess.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          "DIARY",
                                          style: TextStyle(
                                            color: AppColors.greensuccess,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: controller.selectedSectionId.value == null
                                ? null
                                : (val) {
                                    controller.onSubjectChanged(val);
                                  },
                          ),
                        ),
                      ),

                      // Status Indicator if subject/diary selected
                      if (controller.selectedSubjectId.value != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (controller.isDiary.value
                                    ? AppColors.greensuccess
                                    : const Color(0xFF2563EB))
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (controller.isDiary.value
                                      ? AppColors.greensuccess
                                      : const Color(0xFF2563EB))
                                  .withValues(alpha: 0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                controller.isDiary.value
                                    ? Icons.auto_stories_rounded
                                    : Icons.assignment_rounded,
                                size: 16,
                                color: controller.isDiary.value
                                    ? AppColors.greensuccess
                                    : const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.isDiary.value
                                      ? "Posting as Class Diary"
                                      : "Posting as Subject Homework",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: controller.isDiary.value
                                        ? AppColors.greensuccess
                                        : const Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // CARD 2: Homework Content
                  _buildSectionContainer(
                    title: "Homework Description",
                    icon: Icons.edit_note_rounded,
                    children: [
                      _buildFieldLabel("Instructions & Tasks", isRequired: true),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: controller.homeworkContentController,
                          maxLines: 5,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.45,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter homework instructions, problems, page numbers, or notes for students...",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              height: 1.4,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // CARD 3: Attachments
                  _buildSectionContainer(
                    title: "Attachments (Optional)",
                    icon: Icons.attach_file_rounded,
                    children: [
                      Obx(() {
                        final bool hasAnyImages = controller.images.isNotEmpty ||
                            controller.existingAttachments.isNotEmpty;

                        if (!hasAnyImages) {
                          return _buildAttachmentPlaceholder(context);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 110,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  // 1. Existing Network Images
                                  ...controller.existingAttachments.asMap().entries.map((entry) {
                                    final int idx = entry.key;
                                    final dynamic attachment = entry.value;
                                    String imageUrl = "";
                                    if (attachment is String) {
                                      imageUrl = attachment;
                                    } else if (attachment is Map) {
                                      imageUrl = attachment['file_url'] ?? attachment['url'] ?? "";
                                    }

                                    return _buildImageThumbnail(
                                      isNetwork: true,
                                      path: imageUrl,
                                      onRemove: () => controller.removeExistingImage(idx),
                                    );
                                  }),

                                  // 2. Newly Picked Images
                                  ...controller.images.asMap().entries.map((entry) {
                                    final int idx = entry.key;
                                    final File file = entry.value;
                                    return _buildImageThumbnail(
                                      isNetwork: false,
                                      path: file.path,
                                      onRemove: () => controller.removeImage(idx),
                                    );
                                  }),

                                  // 3. Add More Tile
                                  GestureDetector(
                                    onTap: () => _showImageSourceSheet(context),
                                    child: Container(
                                      width: 90,
                                      margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.25),
                                          style: BorderStyle.solid,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo_outlined,
                                              color: AppColors.primary, size: 24),
                                          SizedBox(height: 4),
                                          Text(
                                            "Add More",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit / Update Button
                  Obx(() {
                    final bool isPosting = controller.isPosting.value;
                    return Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isPosting ? Colors.grey : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          if (!isPosting)
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isPosting ? null : () => controller.postHomework(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isPosting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    controller.isEditing.value
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.isEditing.value
                                        ? "UPDATE HOMEWORK"
                                        : "SUBMIT HOMEWORK",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
          ),
          if (isRequired)
            const Text(
              " *",
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownWrapper({
    required IconData icon,
    required Widget child,
    bool isEnabled = true,
    String? disabledHint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.grey[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? Colors.grey.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: isEnabled ? AppColors.primary : Colors.grey[400],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: isEnabled
                ? child
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      disabledHint ?? "Not available",
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPlaceholder(BuildContext context) {
    return InkWell(
      onTap: () => _showImageSourceSheet(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Upload Photos or Worksheets",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Tap to take photo or choose from gallery (JPG, PNG)",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail({
    required bool isNetwork,
    required String path,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image: isNetwork
                  ? NetworkImage(path) as ImageProvider
                  : FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
            ),
          ),
        ),
        if (isNetwork)
          Positioned(
            bottom: 8,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "SAVED",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Select Image Source",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              ),
              title: const Text(
                "Camera",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                "Capture photo using device camera",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              onTap: () {
                Get.back();
                controller.pickImages(ImageSource.camera);
              },
            ),
            const Divider(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              ),
              title: const Text(
                "Gallery",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                "Choose multiple photos from storage",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              onTap: () {
                Get.back();
                controller.pickImages(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
