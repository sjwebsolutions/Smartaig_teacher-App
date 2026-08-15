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

    // Ensure data is fetched if not present
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasFetched.value && !controller.isLoading.value) {
        controller.fetchTeacherSyllabus();
      }
    });

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
          title: "Syllabus",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value && !controller.hasFetched.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Error Occurred",
                      style: AppTextStyles.h2.copyWith(color: AppColors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "No Syllabus Available",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchTeacherSyllabus(),
                          child: const Text("Fetch Data"),
                        )
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
              padding: const EdgeInsets.all(20),
              itemCount: controller.teacherSyllabusList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final syllabus = controller.teacherSyllabusList[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              syllabus.title ?? "No Title",
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.primary, 
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              syllabus.session ?? "N/A",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Divider(height: 1, thickness: 0.5),
                      ),
                      _buildInfoRow(Icons.people_alt_rounded, "Target", syllabus.targetAudience ?? "N/A"),
                      _buildInfoRow(Icons.calendar_today_rounded, "Date", _formatDate(syllabus.uploadedAt)),
                      
                      if (syllabus.fileUrl != null) ...[
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () {
                            Get.toNamed('/pdfViewer', arguments: {
                              'url': syllabus.fileUrl,
                              'title': syllabus.title ?? "Syllabus PDF",
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  "VIEW SYLLABUS PDF",
                                  style: TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 13,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600], 
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
