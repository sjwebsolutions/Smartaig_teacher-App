import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service/event_service.dart';
import '../models/active_event_model.dart';
import '../models/event_student_search_model.dart';
import '../themes/appColors_&_styles/app_Colors.dart';
import '../themes/appColors_&_styles/text_styles.dart';
import '../themes/app_bar/app_top_bar.dart';

class EventStudentSearchScreen extends StatefulWidget {
  const EventStudentSearchScreen({super.key});

  @override
  State<EventStudentSearchScreen> createState() => _EventStudentSearchScreenState();
}

class _EventStudentSearchScreenState extends State<EventStudentSearchScreen> {
  final EventService _eventService = EventService();
  final TextEditingController _searchController = TextEditingController();

  ActiveEventItem? _event;
  bool _isLoading = false;
  String _errorMessage = '';
  List<EventStudentItem> _searchResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is ActiveEventItem) {
      _event = args;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _errorMessage = '';
      });
      return;
    }

    if (_event?.id == null) {
      setState(() {
        _errorMessage = "Event ID not available";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
    });

    try {
      final res = await _eventService.searchEventStudents(
        eventId: _event!.id!,
        query: trimmedQuery,
      );
      setState(() {
        _searchResults = res.data ?? [];
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String eventTitle = (_event?.title ?? "EVENT ENTRY").toUpperCase();

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
          title: eventTitle,
          showBack: true,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Input Box
              Container(
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {});
                    _performSearch(val);
                  },
                  onSubmitted: (val) => _performSearch(val),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: "Search student name, admission no, roll no...",
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.black.withValues(alpha: 0.4),
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.primary),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              // Body Results / States
              Expanded(
                child: _buildBodyContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                "Search Error",
                style: AppTextStyles.h2.copyWith(color: AppColors.primary, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.black.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _performSearch(_searchController.text),
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                label: const Text("RETRY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.manage_search_rounded, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                "Search Event Students",
                style: AppTextStyles.h1.copyWith(fontSize: 17, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                "Enter student name, admission number or roll number above to search.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.black.withValues(alpha: 0.55)),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                "No Matching Students Found",
                style: AppTextStyles.h2.copyWith(fontSize: 16, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                "No student found for '${_searchController.text}' in this event.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.black.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final student = _searchResults[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(EventStudentItem student) {
    final bool hasPass = student.passExists == true;
    final String className = student.className ?? '';
    final String sectionName = student.sectionName ?? '';
    final String classSec = [className, sectionName].where((s) => s.isNotEmpty).join(' - ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Photo or Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: (student.studentPhotoUrl != null && student.studentPhotoUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: student.studentPhotoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    errorWidget: (context, url, error) => _buildInitialsAvatar(student.studentName),
                  )
                : _buildInitialsAvatar(student.studentName),
          ),

          const SizedBox(width: 12),

          // Student Details Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Class Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        student.studentName ?? "Student",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (classSec.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          classSec,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                // Admission No & Roll No
                Row(
                  children: [
                    if (student.admissionNumber != null && student.admissionNumber!.isNotEmpty)
                      _buildMiniInfo(Icons.badge_outlined, "Adm: ${student.admissionNumber}"),
                    if (student.rollNo != null && student.rollNo!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      _buildMiniInfo(Icons.format_list_numbered_rounded, "Roll: ${student.rollNo}"),
                    ],
                  ],
                ),

                if (student.fatherName != null && student.fatherName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildMiniInfo(
                    Icons.family_restroom_rounded,
                    "Father: ${student.fatherName}${student.fatherMobile != null && student.fatherMobile!.isNotEmpty ? ' (${student.fatherMobile})' : ''}",
                  ),
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Pass Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasPass
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: hasPass
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasPass ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            size: 12,
                            color: hasPass ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasPass ? "Pass Exists (${student.passNumber ?? ''})" : "No Pass Created",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: hasPass ? Colors.green.shade700 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (student.approvalStatus != null && student.approvalStatus!.isNotEmpty)
                      Text(
                        student.approvalStatus!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String? name) {
    final String initial = (name != null && name.trim().isNotEmpty)
        ? name.trim()[0].toUpperCase()
        : "S";
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.black.withValues(alpha: 0.45)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
