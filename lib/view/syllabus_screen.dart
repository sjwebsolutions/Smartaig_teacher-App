import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/syllabus_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SyllabusController());

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
          title: "Syllabus",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
          // actions: [
          //   IconButton(
          //     onPressed: () => controller.resetFilters(),
          //     icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          //     tooltip: "Reset Filters",
          //   ),
          // ],
        ),
        body: Column(
          children: [
            _buildFilters(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && !controller.hasFetched.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            "Error Occurred",
                            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(color: Colors.black54),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => controller.fetchTeacherSyllabus(),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text("Retry", style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (controller.teacherSyllabusList.isEmpty && controller.hasFetched.value) {
                  return RefreshIndicator(
                    onRefresh: () => controller.fetchTeacherSyllabus(),
                    child: ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.library_books_outlined, size: 64, color: AppColors.primary),
                              const SizedBox(height: 16),
                              const Text(
                                "No Syllabus Available",
                                style: TextStyle(color: Colors.black54, fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              if (controller.filterTermId.value != null || 
                                  controller.filterClassId.value != null || 
                                  controller.filterSubjectId.value != null)
                                TextButton(
                                  onPressed: () => controller.resetFilters(),
                                  child: const Text("Clear Filters", style: TextStyle(color: AppColors.primary)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchTeacherSyllabus(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.teacherSyllabusList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final syllabus = controller.teacherSyllabusList[index];
                      return _buildSyllabusCard(context, controller, syllabus);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        floatingActionButton: Obx(() {
          if (controller.canUpload.value) {
            return FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/uploadSyllabus'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("UPLOAD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  Widget _buildFilters(SyllabusController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Obx(() {
        if (controller.isFiltersLoading.value) {
          return const SizedBox(
            height: 2,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    hint: "Term",
                    showAll: true,
                    value: controller.filterTermId.value,
                    items: controller.termsList.map((e) => {'id': e.id, 'name': e.name}).toList(),
                    onChanged: (val) {
                      controller.filterTermId.value = val;
                      controller.fetchTeacherSyllabus();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    hint: "Class",
                    showAll: true,
                    value: controller.filterClassId.value,
                    items: controller.classesList.map((e) => {'id': e.id, 'name': e.name}).toList(),
                    onChanged: (val) {
                      controller.filterClassId.value = val;
                      controller.fetchTeacherSyllabus();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown(
                    hint: "Subject",
                    showAll: true,
                    value: controller.filterSubjectId.value,
                    items: controller.filterSubjectsList.map((e) => {'id': e.id, 'name': e.name}).toList(),
                    onChanged: (val) {
                      controller.filterSubjectId.value = val;
                      controller.fetchTeacherSyllabus();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required int? value,
    required List<Map<String, dynamic>> items,
    required Function(int?) onChanged,
    bool showAll = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 20),
          hint: Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          value: value,
          items: [
            if (showAll)
              DropdownMenuItem<int>(
                value: null,
                child: Text("All $hint", style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ...items.map((item) {
              return DropdownMenuItem<int>(
                value: item['id'],
                child: Text(
                  item['name'] ?? item['title'] ?? "N/A",
                  style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSyllabusCard(BuildContext context, SyllabusController controller, dynamic syllabus) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      syllabus.title ?? "No Title",
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary, 
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      syllabus.session ?? "N/A",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            syllabus.description ?? "No Description",
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),
          _buildInfoRow(Icons.people_alt_rounded, "Target", syllabus.targetAudience ?? "N/A", isMultiLine: true),
          _buildInfoRow(Icons.person_outline_rounded, "Uploaded By", syllabus.uploadedBy ?? "N/A"),
          _buildInfoRow(Icons.calendar_today_rounded, "Uploaded At", _formatDate(syllabus.uploadedAt)),
          
          const SizedBox(height: 8),
          Row(
            children: [
              if (syllabus.isMyUpload == true) ...[
                GestureDetector(
                  onTap: () => controller.prepareSyllabusUpdate(syllabus),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: Colors.amber, size: 20),
                  ),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: syllabus.status == 1,
                    onChanged: (val) => controller.toggleSyllabusStatus(syllabus.id!),
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (syllabus.status == 1 ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  syllabus.status == 1 ? "ACTIVE" : "INACTIVE",
                  style: TextStyle(
                    color: syllabus.status == 1 ? Colors.green : Colors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (syllabus.fileUrl != null || (syllabus.attachments != null && syllabus.attachments!.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final String? mainUrl = syllabus.fileUrl;
              final List<Map<String, dynamic>> allFiles = [];

              if (mainUrl != null && mainUrl.isNotEmpty) {
                allFiles.add({
                  'url': mainUrl,
                  'isImage': mainUrl.toLowerCase().contains('.jpg') || mainUrl.toLowerCase().contains('.png') || mainUrl.toLowerCase().contains('.jpeg')
                });
              }

              if (syllabus.attachments != null) {
                for (var att in syllabus.attachments!) {
                  if (att.url != null && att.url!.isNotEmpty) {
                    final bool isImg = att.isImage ?? false || 
                                     att.ext?.toLowerCase() == 'jpg' || 
                                     att.ext?.toLowerCase() == 'png' || 
                                     att.ext?.toLowerCase() == 'jpeg' ||
                                     att.url!.toLowerCase().contains('.jpg') ||
                                     att.url!.toLowerCase().contains('.png') ||
                                     att.url!.toLowerCase().contains('.jpeg');
                    
                    if (att.url != mainUrl) {
                      allFiles.add({'url': att.url, 'isImage': isImg});
                    }
                  }
                }
              }

              if (allFiles.isEmpty) return const SizedBox.shrink();

              final bool firstIsImage = allFiles.first['isImage'];

              return InkWell(
                onTap: () {
                  Get.toNamed('/pdfViewer', arguments: {
                    'files': allFiles,
                    'title': syllabus.title ?? "Syllabus File",
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(firstIsImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        allFiles.length > 1 
                          ? "VIEW ALL ATTACHMENTS (${allFiles.length})" 
                          : (firstIsImage ? "VIEW SYLLABUS IMAGE" : "VIEW SYLLABUS PDF"),
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.primary.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: label == "Uploaded By" ? AppColors.primary : Colors.grey[600], 
                fontSize: 12,
                fontWeight: label == "Uploaded By" ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: isMultiLine ? null : 1,
              overflow: isMultiLine ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      final date = DateTime.parse(dateStr);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateStr;
    }
  }
}
