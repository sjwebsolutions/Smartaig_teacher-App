import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/homework_controller.dart';
import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class AddHomeworkScreen extends GetView<HomeworkController> {
  const AddHomeworkScreen({super.key});

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
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Type Selection (Diary vs Subject)
                _buildLabel("Homework Type"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeCard(
                        title: "Subject Homework",
                        isSelected: !controller.isDiary.value,
                        onTap: () => controller.isDiary.value = false,
                        icon: Icons.book_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeCard(
                        title: "Class Diary",
                        isSelected: controller.isDiary.value,
                        onTap: () => controller.isDiary.value = true,
                        icon: Icons.auto_stories_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Class Dropdown
                _buildLabel("Select Class"),
                _buildDropdownCard(
                  icon: Icons.school_outlined,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text("Choose Class"),
                    value: controller.selectedClassId.value,
                    items: controller.uniqueClasses.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.classId,
                        child: Text(item.className ?? ""),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedClassId.value = val;
                      controller.selectedSectionId.value = null;
                      controller.selectedSectionIds.clear();
                      controller.selectedSubjectId.value = null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                /// Section Dropdown
                _buildLabel("Select Section"),
                _buildDropdownCard(
                  icon: Icons.grid_view_rounded,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text("Choose Section"),
                    value: controller.selectedSectionId.value,
                    items: controller.sectionsForSelectedClass.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.sectionId,
                        child: Text(item.sectionName ?? ""),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedSectionId.value = val;
                      if (val != null) {
                        if (!controller.selectedSectionIds.contains(val)) {
                          controller.selectedSectionIds.add(val);
                        }
                      }
                      controller.selectedSubjectId.value = null;
                    },
                  ),
                ),
                if (controller.selectedSectionIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 8,
                      children: controller.selectedSectionIds.map((id) {
                        final section = controller.sectionsForSelectedClass
                            .firstWhereOrNull((s) => s.sectionId == id);
                        return Chip(
                          label: Text(section?.sectionName ?? id),
                          onDeleted: () => controller.selectedSectionIds.remove(id),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          deleteIconColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 16),

                /// Subject Dropdown (Only for Subject Homework)
                if (!controller.isDiary.value) ...[
                  _buildLabel("Select Subject"),
                  _buildDropdownCard(
                    icon: Icons.book_outlined,
                    child: DropdownButton<int>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Choose Subject"),
                      value: controller.selectedSubjectId.value,
                      items: controller.subjectsForSelectedSelection.map((item) {
                        return DropdownMenuItem<int>(
                          value: item.subjectId,
                          child: Text(item.subjectName ?? ""),
                        );
                      }).toList(),
                      onChanged: (val) => controller.onSubjectChanged(val),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

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
                const SizedBox(height: 20),

                /// Attachments
                _buildLabel("Attachments (Optional)"),
                InkWell(
                  onTap: () => controller.pickImages(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(15),
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                        SizedBox(height: 4),
                        Text("Add Images", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                if (controller.images.isNotEmpty)
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(top: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(controller.images[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => controller.removeImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isPosting.value ? null : () => controller.postHomework(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: controller.isPosting.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("SUBMIT HOMEWORK",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  Widget _buildTypeCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primary),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
