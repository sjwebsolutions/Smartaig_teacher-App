import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/syllabus_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class SyllabusTrackerScreen extends GetView<SyllabusController> {
  const SyllabusTrackerScreen({super.key});

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
          title: "Syllabus Tracker",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return Column(
              children: [
                /// Subject Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: _buildSubjectList(),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 80),
                    children: [
                      if (controller.filteredSyllabusList.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              "No topics found for ${controller.selectedSubject.value}",
                              style: const TextStyle(color: AppColors.grey),
                            ),
                          ),
                        )
                      else
                        ...controller.filteredSyllabusList.map((item) {
                          ModuleStatus status = ModuleStatus.locked;
                          String s = item['status'].toString().toLowerCase();
                          if (s == 'completed') status = ModuleStatus.completed;
                          if (s == 'active' || s == 'inprogress') status = ModuleStatus.active;
                          if (s == 'pending' || s == 'locked') status = ModuleStatus.locked;

                          return _ModuleCard(
                            title: item['title'],
                            subtitle: item['subtitle'],
                            status: status,
                          );
                        }),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () {
            Get.toNamed('/addSyllabus');
          },
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildSubjectList() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.subjects.length,
        itemBuilder: (context, index) {
          final item = controller.subjects[index];
          final isSelected = controller.selectedSubject.value == item;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
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
                fontSize: 13,
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
  }
}

enum ModuleStatus { completed, active, locked }

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final ModuleStatus status;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case ModuleStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = "COMPLETED";
        break;
      case ModuleStatus.active:
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle_filled;
        statusText = "IN PROGRESS";
        break;
      case ModuleStatus.locked:
        statusColor = Colors.grey;
        statusIcon = Icons.lock;
        statusText = "PENDING";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                  style: const TextStyle(
                    color: AppColors.black, 
                    fontSize: 13, 
                    fontWeight: FontWeight.bold
                  )
                ),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 9),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.grey, size: 18),
        ],
      ),
    );
  }
}
