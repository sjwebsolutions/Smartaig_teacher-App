import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../controller/syllabus_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class UploadSyllabusScreen extends GetView<SyllabusController> {
  const UploadSyllabusScreen({super.key});

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
          title: controller.isUpdateMode.value ? "Update Syllabus" : "Upload Syllabus",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
          onBack: () {
            controller.clearUploadMode();
            Get.back();
          },
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("TITLE *"),
                _buildTextField(
                  controller: controller.uploadTitleController,
                  hint: "e.g. Term 1 History Syllabus",
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 20),

                _buildLabel("TERM *"),
                _buildDropdownCard(
                  icon: Icons.calendar_today_rounded,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: Text("Select Term", style: AppTextStyles.body.copyWith(color: Colors.grey.shade600)),
                      value: controller.uploadSelectedTermId.value,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: controller.termsList.map((term) {
                        return DropdownMenuItem<int>(
                          value: term.id,
                          child: Text(term.name ?? "", style: AppTextStyles.body),
                        );
                      }).toList(),
                      onChanged: (val) => controller.uploadSelectedTermId.value = val,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel("CLASS *"),
                _buildDropdownCard(
                  icon: Icons.school_rounded,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: Text("Select Class", style: AppTextStyles.body.copyWith(color: Colors.grey.shade600)),
                      value: controller.uploadSelectedClassId.value,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: controller.classesList.map((cls) {
                        return DropdownMenuItem<int>(
                          value: cls.id,
                          child: Text(cls.name ?? ""),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.uploadSelectedClassId.value = val;
                        controller.uploadSelectedSectionIds.clear(); // Reset sections when class changes
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- NEW: SECTION SELECTION ---
                _buildLabel("SECTIONS *"),
                _buildSectionSelector(),
                const SizedBox(height: 20),

                _buildLabel("SUBJECT"),
                _buildDropdownCard(
                  icon: Icons.book_rounded,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: Text("Select Subject (Optional)", style: AppTextStyles.body.copyWith(color: Colors.grey.shade600)),
                      value: controller.uploadSelectedSubjectId.value,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: controller.filterSubjectsList.map((sub) {
                        return DropdownMenuItem<int>(
                          value: sub.id,
                          child: Text(sub.name ?? "", style: AppTextStyles.body),
                        );
                      }).toList(),
                      onChanged: (val) => controller.uploadSelectedSubjectId.value = val,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel("DESCRIPTION"),
                _buildTextField(
                  controller: controller.uploadDescController,
                  hint: "Enter description...",
                  icon: Icons.description_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                if (controller.isUpdateMode.value && controller.existingAttachments.isNotEmpty) ...[
                  _buildLabel("EXISTING ATTACHMENTS (CLICK TO DELETE)"),
                  _buildExistingAttachments(),
                  const SizedBox(height: 20),
                ],

                _buildLabel("NEW ATTACHMENTS"),
                _buildAttachmentSection(),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => controller.storeTeacherSyllabus(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: Text(
                      controller.isUpdateMode.value ? "UPDATE SYLLABUS" : "UPLOAD SYLLABUS",
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
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
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdownCard({required IconData icon, required Widget child}) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSectionSelector() {
    if (controller.uploadSelectedClassId.value == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: const Text("Select a class first", style: TextStyle(color: Colors.grey)),
      );
    }

    final sections = controller.sectionsList;

    if (sections.isEmpty) {
      return const Text("No sections available", style: TextStyle(color: Colors.red));
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        children: sections.map((section) {
          final isSelected = controller.uploadSelectedSectionIds.contains(section.id);
          return FilterChip(
            label: Text(section.name ?? ""),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                controller.uploadSelectedSectionIds.add(section.id!);
              } else {
                controller.uploadSelectedSectionIds.remove(section.id);
              }
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExistingAttachments() {
    return Obx(() => ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.existingAttachments.length,
      itemBuilder: (context, index) {
        final att = controller.existingAttachments[index];
        final bool isMarkedForDelete = controller.deleteAttachmentPaths.contains(att.path);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMarkedForDelete ? Colors.red.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isMarkedForDelete ? Colors.red.withOpacity(0.3) : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                att.isImage == true ? Icons.image_rounded : Icons.insert_drive_file_rounded, 
                color: isMarkedForDelete ? Colors.red : Colors.grey
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  att.name ?? "Attachment",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: isMarkedForDelete ? TextDecoration.lineThrough : null,
                    color: isMarkedForDelete ? Colors.red : Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isMarkedForDelete ? Icons.undo_rounded : Icons.delete_outline_rounded, 
                  color: isMarkedForDelete ? Colors.green : Colors.red, 
                  size: 20
                ),
                onPressed: () {
                  if (isMarkedForDelete) {
                    controller.deleteAttachmentPaths.remove(att.path);
                  } else {
                    if (att.path != null) {
                      controller.deleteAttachmentPaths.add(att.path!);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildAttachmentSection() {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            print("--- OPENING FILE PICKER ---");
            try {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
              );

              if (result != null) {
                print("Files selected: ${result.paths.length}");
                
                final int maxSizeInBytes = 10 * 1024 * 1024; // 10 MB
                List<File> validFiles = [];
                List<String> largeFiles = [];

                for (var platformFile in result.files) {
                  if (platformFile.path != null) {
                    if (platformFile.size <= maxSizeInBytes) {
                      validFiles.add(File(platformFile.path!));
                    } else {
                      largeFiles.add(platformFile.name);
                    }
                  }
                }

                if (validFiles.isNotEmpty) {
                  controller.uploadAttachments.addAll(validFiles);
                }

                if (largeFiles.isNotEmpty) {
                  Get.snackbar(
                    "File Too Large",
                    "The following files exceed 10MB and were not added: ${largeFiles.join(', ')}",
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 5),
                  );
                }
              } else {
                print("No files selected (User canceled)");
              }
            } catch (e) {
              print("ERROR PICKING FILES: $e");
              Get.snackbar("Picker Error", e.toString());
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_rounded, size: 40, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text("Tap to select files", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("(PDF, DOC, JPG, PNG)", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.uploadAttachments.length,
          itemBuilder: (context, index) {
            final file = controller.uploadAttachments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_rounded, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      file.path.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: () => controller.uploadAttachments.removeAt(index),
                  ),
                ],
              ),
            );
          },
        )),
      ],
    );
  }
}
