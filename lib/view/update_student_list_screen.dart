import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/image_update_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class UpdateStudentListScreen extends StatefulWidget {
  const UpdateStudentListScreen({super.key});

  @override
  State<UpdateStudentListScreen> createState() => _UpdateStudentListScreenState();
}

class _UpdateStudentListScreenState extends State<UpdateStudentListScreen> {
  final ImageUpdateController controller = Get.find<ImageUpdateController>();

  int? classId;
  int? sectionId;
  int? streamId;
  String className = "";
  String sectionName = "";

  @override
  void initState() {
    super.initState();
    final rawArgs = Get.arguments;
    if (rawArgs is Map<String, dynamic>) {
      classId = rawArgs['class_id'];
      sectionId = rawArgs['section_id'];
      streamId = rawArgs['stream_id'];
      className = rawArgs['class_name']?.toString() ?? "";
      sectionName = rawArgs['section_name']?.toString() ?? "";
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  void _loadStudents() {
    if (classId != null && sectionId != null) {
      controller.fetchStudents(
        classId!,
        sectionId!,
        streamId,
      );
    }
  }

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
          title: className.isNotEmpty && sectionName.isNotEmpty 
              ? "$className - $sectionName" 
              : "Students List",
          showBack: true,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.studentsList.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (controller.errorMessage.isNotEmpty && controller.studentsList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadStudents,
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        label: const Text("Retry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.studentsList.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => _loadStudents(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            "No students found in this class",
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadStudents,
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                            label: const Text("Refresh", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadStudents(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: controller.studentsList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final student = controller.studentsList[index];
                  return InkWell(
                    onTap: () async {
                      final result = await Get.toNamed('/updateStudentDetails', arguments: student);
                      if (result == true) {
                        _loadStudents();
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
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
                                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                      ),
                                      child: const Text(
                                        "Pending Approval",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
