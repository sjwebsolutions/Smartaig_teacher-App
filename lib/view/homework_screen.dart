import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/homework_controller.dart';
import '../models/homework_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/app_bar/app_top_bar.dart';

class UploadHomeworkScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool? showBack;
  const UploadHomeworkScreen({super.key, this.onBack, this.showBack});

  @override
  State<UploadHomeworkScreen> createState() => _UploadHomeworkScreenState();
}

class _UploadHomeworkScreenState extends State<UploadHomeworkScreen> {
  final HomeworkController controller = Get.find<HomeworkController>();
  String _selectedFilter = 'all'; // 'all', 'homework', 'diary'

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    final bool effectiveShowBack = widget.showBack ?? canPop;

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
          title: "HOMEWORK",
          showBack: effectiveShowBack,
          onBack: widget.onBack,
          backgroundColor: Colors.transparent,
          showDivider: false,
        ),
        body: SafeArea(
          child: Obx(() {
            // Loading state on initial fetch
            if (!controller.hasFetched.value ||
                (controller.isLoading.value && controller.homeworkList.isEmpty)) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final allHomework = controller.homeworkList;

            // Apply filter
            final filteredList = allHomework.where((item) {
              if (_selectedFilter == 'homework') {
                return item.isDiary != true;
              } else if (_selectedFilter == 'diary') {
                return item.isDiary == true;
              }
              return true;
            }).toList();

            return RefreshIndicator(
              onRefresh: () => controller.fetchHomeworkList(),
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Filter Chips & Stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterRow(allHomework),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Assignments (${filteredList.length})",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary.withValues(alpha: 0.75),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (controller.isLoading.value)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Empty State or List
                  if (filteredList.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(context),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final homework = filteredList[index];
                            return _buildHomeworkCard(context, homework);
                          },
                          childCount: filteredList.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'upload_homework_fab',
          onPressed: () => controller.handleAddHomework(),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: const Text(
            "Add Homework",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(List<HomeworkData> allHomework) {
    final int totalCount = allHomework.length;
    final int hwCount = allHomework.where((h) => h.isDiary != true).length;
    final int diaryCount = allHomework.where((h) => h.isDiary == true).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            label: "All",
            count: totalCount,
            isSelected: _selectedFilter == 'all',
            icon: Icons.grid_view_rounded,
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: "Homework",
            count: hwCount,
            isSelected: _selectedFilter == 'homework',
            icon: Icons.assignment_rounded,
            onTap: () => setState(() => _selectedFilter = 'homework'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: "Class Diary",
            count: diaryCount,
            isSelected: _selectedFilter == 'diary',
            icon: Icons.auto_stories_rounded,
            onTap: () => setState(() => _selectedFilter = 'diary'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$count",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, HomeworkData homework) {
    final bool isDiary = homework.isDiary == true;
    final int attachmentCount = homework.attachments?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Get.toNamed('/homeworkDetail', arguments: homework.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Class & Section + Type Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_rounded,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(
                            "${homework.className ?? ''} • Sec ${homework.sectionName ?? ''}",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (homework.streamName != null &&
                              homework.streamName!.isNotEmpty) ...[
                            Text(
                              " • ${homework.streamName}",
                              style: TextStyle(
                                color: AppColors.primary.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDiary
                                ? AppColors.greensuccess
                                : const Color(0xFF2563EB))
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDiary
                                ? Icons.auto_stories_rounded
                                : Icons.assignment_rounded,
                            size: 12,
                            color: isDiary
                                ? AppColors.greensuccess
                                : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDiary ? "DIARY" : "HOMEWORK",
                            style: TextStyle(
                              color: isDiary
                                  ? AppColors.greensuccess
                                  : const Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subject Name & Date Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        homework.subjectName ?? (isDiary ? "Class Diary" : "General"),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (homework.date != null && homework.date!.isNotEmpty) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            homework.date!,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Content Snippet
                Text(
                  (homework.content != null && homework.content!.trim().isNotEmpty)
                      ? homework.content!.trim()
                      : "No instructions provided.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 10),

                // Footer Row: Author + Attachments indicator + chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          homework.createdBy ?? "Teacher",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (attachmentCount > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.attach_file_rounded,
                                    size: 13, color: AppColors.primary),
                                const SizedBox(width: 2),
                                Text(
                                  "$attachmentCount",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFilter == 'all'
                    ? "No Homework Found"
                    : "No ${_selectedFilter == 'homework' ? 'Homework' : 'Class Diary'} Entries",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Create and publish new homework or class diary for your students",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => controller.handleAddHomework(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  "Create Homework",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
