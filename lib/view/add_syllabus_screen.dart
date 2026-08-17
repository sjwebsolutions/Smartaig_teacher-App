import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/syllabus_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class AddSyllabusScreen extends GetView<SyllabusController> {
  const AddSyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String subjectName = controller.selectedSubject.value;

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
            showBack: true,
            backgroundColor: Colors.transparent,
            customTitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subjectName.isNotEmpty ? subjectName : "Add Syllabus",
                  style: AppTextStyles.appbarh4.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              /// Subject List (Chips) - Persistent
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Select Subject"),
                    _buildSubjectList(),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              Expanded(
                child: _buildAddSyllabusForm(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddSyllabusForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                hint: Text("Choose Class", style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                value: controller.selectedClassId.value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(15),
                menuMaxHeight: 300,
                items: controller.uniqueClasses.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.classId ?? "",
                    child: Text(item.className ?? "", style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.selectedClassId.value = val;
                  controller.selectedSectionId.value = null;
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          /// Section Dropdown
          _buildLabel("Section"),
          _buildDropdownCard(
            icon: Icons.grid_view_rounded,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Choose Section", style: AppTextStyles.body.copyWith(color: AppColors.textHint)),
                value: controller.selectedSectionId.value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(15),
                menuMaxHeight: 300,
                items: controller.sectionsForSelectedClass.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.sectionId ?? "",
                    child: Text(item.sectionName ?? "", style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.selectedSectionId.value = val;
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          const Divider(color: AppColors.primary, thickness: 0.1),
          const SizedBox(height: 4),

          _buildLabel("Chapter Name"),
          _buildTextField(
            controller: controller.chapterController,
            hint: "e.g. Chapter 1: Real Numbers",
            icon: Icons.bookmark_outline,
          ),

          const SizedBox(height: 8),
          _buildLabel("Topic Name"),
          _buildTextField(
            controller: controller.topicController,
            hint: "e.g. Rational and Irrational Numbers",
            icon: Icons.topic_outlined,
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => controller.saveSyllabusTopic(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("SAVE TOPIC",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSubjectList() {
    return Obx(() {
      final subjects = controller.subjects;

      if (subjects.isEmpty) {
        return Container(
          height: 40,
          alignment: Alignment.centerLeft,
          child: Text(
            "No subjects found",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final item = subjects[index];
            final isSelected = controller.selectedSubject.value == item;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (selected) {
                  controller.selectedSubject.value = item;
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                showCheckmark: false,
                elevation: 0,
                pressElevation: 0,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF6B7280), // Grayish color from screenshot
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildDropdownCard({required IconData icon, required Widget child}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
