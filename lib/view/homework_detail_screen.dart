import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/homework_controller.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class HomeworkDetailScreen extends StatefulWidget {
  const HomeworkDetailScreen({super.key});

  @override
  State<HomeworkDetailScreen> createState() => _HomeworkDetailScreenState();
}

class _HomeworkDetailScreenState extends State<HomeworkDetailScreen> {
  final HomeworkController controller = Get.find<HomeworkController>();

  @override
  void initState() {
    super.initState();
    final int? homeworkId = Get.arguments as int?;
    if (homeworkId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchHomeworkDetail(homeworkId);
      });
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
        appBar: const AppTopBar(
          title: "Homework Information",
          showBack: true,
          backgroundColor: Colors.transparent,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          final homework = controller.homeworkDetail.value;
          if (homework == null) {
            return _buildErrorState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (homework.id != null) await controller.fetchHomeworkDetail(homework.id!);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge and Date Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: homework.isDiary == true ? AppColors.greensuccess.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              homework.isDiary == true ? Icons.book_rounded : Icons.assignment_rounded,
                              size: 14,
                              color: homework.isDiary == true ? AppColors.greensuccess : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              homework.isDiary == true ? "Class Diary" : "Homework",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: homework.isDiary == true ? AppColors.greensuccess : AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        homework.date ?? "",
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  // Subject Name
                  Text(
                    homework.subjectName ?? "General",
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 26,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Class and Section with better UI
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildMiniTag(Icons.school_outlined, "Class: ${homework.className}"),
                      _buildMiniTag(Icons.grid_view_rounded, "Section: ${homework.sectionName?.toUpperCase()}"),
                      if (homework.streamName != null)
                        _buildMiniTag(Icons.account_tree_outlined, "Stream: ${homework.streamName}"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Content Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notes_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              "Description",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          homework.content ?? "No instructions provided.",
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16,
                            height: 1.6,
                            color: AppColors.blackColorText.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Attachments Section
                  if (homework.attachments != null && homework.attachments!.isNotEmpty) ...[
                    _buildSectionHeader("Attachments", Icons.image_outlined),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: homework.attachments!.length,
                        itemBuilder: (context, index) {
                          final attachment = homework.attachments![index];
                          String imageUrl = "";
                          if (attachment is String) {
                            imageUrl = attachment;
                          } else if (attachment is Map && attachment.containsKey('file_url')) {
                            imageUrl = attachment['file_url'];
                          } else if (attachment is Map && attachment.containsKey('url')) {
                            imageUrl = attachment['url'];
                          }

                          return GestureDetector(
                            onTap: () => _showImageDialog(context, imageUrl),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Created By Section
                  _buildAuthorCard(homework),

                  const SizedBox(height: 30),

                  // Meta Data
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Group ID: ${homework.groupId ?? 'N/A'}",
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[400], fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Uploaded at: ${homework.createdAt ?? 'N/A'}",
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[400], fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMiniTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.bodySmall.copyWith(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorCard(dynamic homework) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            radius: 20,
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Created By",
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey, fontSize: 11),
              ),
              Text(
                homework.createdBy ?? "Teacher",
                style: AppTextStyles.body.copyWith(color: AppColors.primary, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          if (homework.isEditable == true)
            TextButton.icon(
              onPressed: () {
                controller.prepareEdit(homework);
                Get.toNamed('/addHomework');
              },
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
              label: Text(
                "Edit Homework",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, size: 50, color: AppColors.red),
          ),
          const SizedBox(height: 16),
          Text(
            "Oops! Data not found",
            style: AppTextStyles.h2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            "We couldn't load the homework details.",
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final int? homeworkId = Get.arguments as int?;
              if (homeworkId != null) controller.fetchHomeworkDetail(homeworkId);
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }
}
