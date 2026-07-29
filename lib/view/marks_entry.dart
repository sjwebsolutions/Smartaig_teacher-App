import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../appColors_&_styles/app_Colors.dart';
import '../appColors_&_styles/text_styles.dart';
import '../controller/marks_controller.dart';
import '../models/marks_model.dart';
import '../models/marks_save_model.dart';
import '../models/marks_student_model.dart';
import '../themes/app_bar/app_top_bar.dart';


class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  final MarksController marksController = Get.find<MarksController>();
  final Map<String, TextEditingController> _marksControllers = {}; // Key: "studentId-comp"
  final Map<int, String> _attendanceMap = {};
  
  // Track entered count reactively
  final RxInt enteredCount = 0.obs;

  TextEditingController _getController(int studentId, String component, String? initialValue) {
    final key = "$studentId-$component";
    if (!_marksControllers.containsKey(key)) {
      final controller = TextEditingController(text: _formatMark(initialValue));
      _marksControllers[key] = controller;
      
      // Listen to changes to update the count and calculate total
      controller.addListener(() {
        _updateEnteredCount();
        // If any component (except total/grade) is changed, auto-calculate total
        if (component != 't' && component != 'g') {
          _calculateTotal(studentId);
        }
      });
    }
    return _marksControllers[key]!;
  }

  void _calculateTotal(int studentId) {
    final components = ['w', 'o', 'a', 'b', 'ass', 'p'];
    double total = 0;
    bool hasAnyValue = false;

    for (var comp in components) {
      final controller = _marksControllers["$studentId-$comp"];
      if (controller != null && controller.text.trim().isNotEmpty) {
        double? val = double.tryParse(controller.text.trim());
        if (val != null) {
          total += val;
          hasAnyValue = true;
        }
      }
    }

    final totalController = _marksControllers["$studentId-t"];
    if (totalController != null) {
      if (hasAnyValue) {
        String formatted = total % 1 == 0 ? total.toInt().toString() : total.toString();
        // Only update if value is different to avoid cursor jumping if user was editing total
        if (totalController.text != formatted) {
          totalController.text = formatted;
        }
      }
    }
  }

  void _updateEnteredCount() {
    int count = 0;
    final studentIds = marksController.studentsList.map((s) => s.studentId).whereType<int>().toSet();

    for (var studentId in studentIds) {
      String att = _attendanceMap[studentId] ?? "P";

      bool hasAnyMark = false;
      for (var comp in ['w', 'o', 'a', 'b', 'ass', 'p', 't', 'g']) {
        final key = "$studentId-$comp";
        if (_marksControllers.containsKey(key) && _marksControllers[key]!.text.trim().isNotEmpty) {
          hasAnyMark = true;
          break;
        }
      }

      if (hasAnyMark || att == "A" || att == "C") {
        count++;
      }
    }
    enteredCount.value = count;
  }

  void _resetControllers() {
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    _marksControllers.clear();
    _attendanceMap.clear();
    enteredCount.value = 0;
  }

  @override
  void initState() {
    super.initState();
    if (marksController.marksEntries.isEmpty) {
      marksController.fetchMarksEntries();
    }
    
    // Reset controllers when subject or section changes
    everAll([marksController.selectedSubjectId, marksController.selectedSectionId], (_) {
      _resetControllers();
    });

    // Automatically update count when students list is loaded
    ever(marksController.studentsList, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateEnteredCount();
      });
    });
  }

  @override
  void dispose() {
    _resetControllers();
    super.dispose();
  }

  String _formatMark(String? val) {
    if (val == null || val == "null" || val.trim().isEmpty) return "";
    if (val.contains('.')) {
      try {
        double d = double.parse(val);
        return d % 1 == 0 ? d.toInt().toString() : d.toString();
      } catch (_) {
        return val;
      }
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppTopBar(
        backgroundColor: AppColors.bgColor,
        showBack: true,
        showDivider: true,
        customTitle: Text("Marks Entry", style: AppTextStyles.appbarh4),
      ),
      body: Obx(() {
        if (marksController.isLoading.value || 
            marksController.isClassesLoading.value || 
            marksController.isStudentsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionDropdown(),
                const SizedBox(height: 16),
                _buildSubjectDropdown(),
                const SizedBox(height: 20),
                Obx(() {
                  final isAllSelected = marksController.selectedClassId.value != null &&
                      marksController.selectedSectionId.value != null &&
                      marksController.selectedSubjectId.value != null;

                  final selectedSubject = marksController.subjectList.firstWhereOrNull(
                      (s) => s.subjectId == marksController.selectedSubjectId.value
                  );
                  final bool isGrading = selectedSubject?.gradingType?.toLowerCase().contains('grade') == true ||
                      selectedSubject?.name?.toLowerCase().contains('computer') == true;

                  if (!isAllSelected) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text(
                              "Please select Class, Section and Subject\nto view students and enter marks",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (marksController.isLocked.value)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.lock, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "This section is finalized and locked. Editing is not allowed.",
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _buildAddedSubjectsCard(),
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Student List", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(isGrading ? "Grade" : "Marks", style: AppTextStyles.bodySmall.copyWith(color: AppColors.black.withValues(alpha: 0.5))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStudentList(),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                      const SizedBox(height: 24),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() {
      final bool isLocked = marksController.isLocked.value;
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocked ? Colors.grey : AppColors.primary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: isLocked ? null : _showConfirmationSheet,
        child: Text(
          isLocked ? "MARKS LOCKED (SUBMITTED)" : "Save All Marks",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    });
  }


  Widget _buildStudentList() {
    return Obx(() {
      if (marksController.studentsList.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "No students found in this section",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        );
      }

      final selectedSubject = marksController.subjectList.firstWhereOrNull(
          (s) => s.subjectId == marksController.selectedSubjectId.value
      );
      final bool isGrading = selectedSubject?.gradingType?.toLowerCase().contains('grade') == true ||
          selectedSubject?.name?.toLowerCase().contains('computer') == true;

      return ListView.separated(
        key: ValueKey("list_${marksController.selectedSubjectId.value}_${marksController.selectedSectionId.value}"),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: marksController.studentsList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final student = marksController.studentsList[index];
          final studentId = student.studentId!;

          final subIdStr = marksController.selectedSubjectId.value.toString();
          final subjectMarks = student.marks?[subIdStr];
          final existingAttendance = subjectMarks?.attendance;

          if (!_attendanceMap.containsKey(studentId)) {
            _attendanceMap[studentId] = (existingAttendance == null || existingAttendance.isEmpty || existingAttendance == "null") ? "P" : existingAttendance;
          }

          final components = selectedSubject?.components;
          List<Widget> markFields = [];

          // 1. Add Marks Components (Written, Oral, etc.)
          if (components != null) {
            if (components.wEnabled == true) markFields.add(_buildMarkInput(studentId, 'w', 'Written', subjectMarks?.wMarks, components.wMax, marksController.isLocked.value, _attendanceMap[studentId]));
            if (components.oEnabled == true) markFields.add(_buildMarkInput(studentId, 'o', 'Oral', subjectMarks?.oMarks, components.oMax, marksController.isLocked.value, _attendanceMap[studentId]));
            if (components.aEnabled == true) markFields.add(_buildMarkInput(studentId, 'a', 'A', subjectMarks?.aMarks, components.aMax, marksController.isLocked.value, _attendanceMap[studentId]));
            if (components.bEnabled == true) markFields.add(_buildMarkInput(studentId, 'b', 'B', subjectMarks?.bMarks, components.bMax, marksController.isLocked.value, _attendanceMap[studentId]));
            if (components.assEnabled == true) markFields.add(_buildMarkInput(studentId, 'ass', 'Assign.', subjectMarks?.assMarks, components.assMax, marksController.isLocked.value, _attendanceMap[studentId]));
            if (components.pEnabled == true) markFields.add(_buildMarkInput(studentId, 'p', 'Pract.', subjectMarks?.pMarks, components.pMax, marksController.isLocked.value, _attendanceMap[studentId]));

            bool showTotal = components.tEnabled == true || (!isGrading && markFields.isEmpty);
            if (showTotal) {
              markFields.add(_buildMarkInput(studentId, 't', 'Total', subjectMarks?.tMarks, components.tMax, marksController.isLocked.value, _attendanceMap[studentId]));
            }
          } else if (!isGrading) {
            markFields.add(_buildMarkInput(studentId, 't', 'Total', subjectMarks?.tMarks, "100", marksController.isLocked.value, _attendanceMap[studentId]));
          }

          // 2. Add Grade Component (If enabled or if it's a grading subject)
          if (isGrading || components?.gEnabled == true) {
            final String? existingGrade = subjectMarks?.gGrade?.toString() ??
                (subjectMarks?.grade?.toString() != "null" ? subjectMarks?.grade?.toString() : null);
            final controller = _getController(studentId, 'g', existingGrade);

            markFields.add(SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "GRADE",
                    style: TextStyle(
                        fontSize: 9,
                        color: AppColors.black.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 40,
                    child: _buildGradeDropdown(studentId, controller),
                  ),
                ],
              ),
            ));
          }

          // Update count if data exists
          bool hasAnyInitialData = false;
          if (subjectMarks != null) {
            if ((subjectMarks.wMarks != null && subjectMarks.wMarks!.isNotEmpty && subjectMarks.wMarks != "null") ||
                (subjectMarks.oMarks != null && subjectMarks.oMarks!.isNotEmpty && subjectMarks.oMarks != "null") ||
                (subjectMarks.tMarks != null && subjectMarks.tMarks!.isNotEmpty && subjectMarks.tMarks != "null") ||
                (subjectMarks.gGrade != null && subjectMarks.gGrade!.isNotEmpty && subjectMarks.gGrade != "null") ||
                (subjectMarks.grade != null && subjectMarks.grade!.isNotEmpty && subjectMarks.grade != "null")) {
              hasAnyInitialData = true;
            }
          }
          if (hasAnyInitialData || (_attendanceMap[studentId] != "P")) {
            Future.microtask(() => _updateEnteredCount());
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.08), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.studentName ?? "N/A",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Roll No: ${student.rollNo ?? "N/A"} • Adm: ${student.admissionNo ?? "N/A"}",
                              style: TextStyle(color: AppColors.black.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      _buildAttendanceSelector(studentId),
                    ],
                  ),
                ),
                if (markFields.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.02),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border(top: BorderSide(color: AppColors.primary.withValues(alpha: 0.05))),
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: markFields,
                    ),
                  )
                ]
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildMarkInput(int studentId, String comp, String label, String? existingMark, dynamic maxMarksVal, bool isLocked, String? attendance) {
    final controller = _getController(studentId, comp, existingMark);
    final maxMarksStr = maxMarksVal?.toString() ?? "100";
    final maxMarks = int.tryParse(maxMarksStr) ?? 100;
    
    final bool isDisabled = isLocked || attendance != "P";

    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.black.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5
                  ),
                ),
              ),
              Text(
                "/$maxMarksStr",
                style: TextStyle(fontSize: 9, color: AppColors.primary.withValues(alpha: 0.4), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDisabled ? Colors.grey.shade200 : AppColors.primary.withValues(alpha: 0.2),
                width: 1.5
              ),
            ),
            child: TextField(
              controller: controller,
              enabled: !isDisabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey : AppColors.black,
                  fontSize: 15
              ),
              onChanged: (v) {
                if (v.isNotEmpty) {
                  int? val = int.tryParse(v);
                  if (val != null && val > maxMarks) {
                    controller.text = maxMarks.toString();
                    controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length));
                    Get.snackbar("Alert", "$label cannot exceed $maxMarks",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 1));
                  }
                }
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
                hintText: "-",
                hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.3)),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDropdown(int studentId, TextEditingController controller) {
    return Obx(() {
      final grades = marksController.gradeList;
      final String? currentValue = grades.any((g) => g.gradeName == controller.text)
          ? controller.text
          : null;

      final bool isLocked = marksController.isLocked.value || _attendanceMap[studentId] != "P";

      return Container(
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isLocked ? Colors.grey.shade200 : AppColors.primary.withValues(alpha: 0.2),
            width: 1.5
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentValue,
            isExpanded: true,
            alignment: Alignment.center,
            hint: Center(
              child: Text(
                "Grade",
                style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
              ),
            ),
            icon: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: isLocked ? Colors.grey : AppColors.primary),
            ),
            selectedItemBuilder: (BuildContext context) {
              return grades.map<Widget>((g) {
                return Center(
                  child: Text(
                    g.gradeName ?? "",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey : AppColors.black,
                    ),
                  ),
                );
              }).toList();
            },
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
            items: grades.map((g) => DropdownMenuItem(
              value: g.gradeName,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  g.gradeName ?? "",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.black),
                ),
              ),
            )).toList(),
            onChanged: isLocked
                ? null
                : (val) {
              if (val != null) {
                setState(() {
                  controller.text = val;
                });
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildAttendanceSelector(int studentId) {
    String current = _attendanceMap[studentId] ?? "P";
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _attendanceOption(studentId, "P", Colors.green, current == "P"),
        _attendanceOption(studentId, "A", Colors.red, current == "A"),
        _attendanceOption(studentId, "C", Colors.orange, current == "C"),
      ],
    );
  }

  Widget _attendanceOption(int studentId, String label, Color color, bool isSelected) {
    return GestureDetector(
      onTap: marksController.isLocked.value ? null : () {
        setState(() {
          _attendanceMap[studentId] = label;
          if (label == "A" || label == "C") {
             for (var comp in ['w', 'o', 'a', 'b', 'ass', 'p', 't', 'g']) {
               _marksControllers["$studentId-$comp"]?.text = "";
             }
          }
          _updateEnteredCount();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationSheet() {
    if (marksController.selectedClassId.value == null || marksController.selectedSectionId.value == null) {
      Get.snackbar("Error", "Please select Class and Section", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    List<MarksModel> newMarks = [];
    String examName = "Marks Entry";
    if (marksController.marksEntries.isNotEmpty && marksController.selectedExamTypeId.value != null) {
      final selectedExam = marksController.marksEntries.firstWhereOrNull((e) => e.id == marksController.selectedExamTypeId.value);
      if (selectedExam != null) {
        examName = selectedExam.datesheetName ?? "Marks Entry";
      }
    }

    final List<MarksEntry> entries = [];
    final selectedSubjectId = marksController.selectedSubjectId.value;
    final subjects = marksController.subjectList;
    final currentSubject = subjects.firstWhereOrNull((s) => s.subjectId == selectedSubjectId);
    final bool isGrading = currentSubject?.gradingType?.toLowerCase().contains('grade') == true ||
        currentSubject?.name?.toLowerCase().contains('computer') == true;
    
    for (var student in marksController.studentsList) {
      final studentId = student.studentId;
      if (studentId == null) continue;
      final attendance = _attendanceMap[studentId] ?? "P";
      
      bool hasMarks = false;
      final compKeys = ['w', 'o', 'a', 'b', 'ass', 'p', 't', 'g'];
      for (var k in compKeys) {
        if (_marksControllers["$studentId-$k"]?.text.trim().isNotEmpty == true) {
          hasMarks = true;
          break;
        }
      }
      
      if (hasMarks || attendance != "P") {
        final totalMarkVal = _marksControllers["$studentId-t"]?.text.trim() ?? 
                            _marksControllers["$studentId-g"]?.text.trim() ?? "";
        
        newMarks.add(MarksModel(
          studentName: student.studentName ?? "N/A",
          rollNo: student.rollNo ?? "N/A",
          subject: currentSubject?.name ?? "N/A",
          examType: examName,
          marks: attendance != "P" ? attendance : totalMarkVal,
          date: DateTime.now(),
        ));

        entries.add(MarksEntry(
          studentId: studentId,
          subjectId: selectedSubjectId,
          isMisc: currentSubject?.isMisc ?? false,
          attendance: attendance,
          wMarks: int.tryParse(_marksControllers["$studentId-w"]?.text ?? ""),
          oMarks: int.tryParse(_marksControllers["$studentId-o"]?.text ?? ""),
          aMarks: int.tryParse(_marksControllers["$studentId-a"]?.text ?? ""),
          bMarks: int.tryParse(_marksControllers["$studentId-b"]?.text ?? ""),
          assMarks: int.tryParse(_marksControllers["$studentId-ass"]?.text ?? ""),
          pMarks: int.tryParse(_marksControllers["$studentId-p"]?.text ?? ""),
          tMarks: int.tryParse(_marksControllers["$studentId-t"]?.text ?? ""),
          gGrade: _marksControllers["$studentId-g"]?.text.isNotEmpty == true ? _marksControllers["$studentId-g"]?.text : null,
          remarks: "",
        ));
      }
    }

    if (entries.isEmpty) {
      Get.snackbar("Error", "Please enter marks for at least one student");
      return;
    }

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Icon(Icons.check_circle_outline, size: 50, color: AppColors.primary),
              const SizedBox(height: 16),
              Text("Select Action", style: AppTextStyles.appbarh4),
              const SizedBox(height: 8),
              Text(
                "What would you like to do with marks for ${entries.length} students?",
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: marksController.isSaving.value ? null : () async {
                    final selectedData = marksController.marksEntryClasses.firstWhereOrNull(
                      (element) => element.classId == marksController.selectedClassId.value && 
                                   element.sectionId == marksController.selectedSectionId.value
                    );
  
                    final request = MarksSaveRequest(
                      marksEntryId: marksController.selectedExamTypeId.value,
                      classId: int.tryParse(marksController.selectedClassId.value ?? ""),
                      sectionId: int.tryParse(marksController.selectedSectionId.value ?? ""),
                      streamId: int.tryParse(selectedData?.streamId ?? ""),
                      entries: entries,
                    );
  
                    bool success = await marksController.saveMarksToApi(request);
                    
                    if (success) {
                      Get.back(); // Close sheet only on success
                      marksController.saveMarks(newMarks);
                    }
                  },
                  child: marksController.isSaving.value 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("SAVE AS DRAFT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.red, width: 1.5),
                  ),
                  onPressed: () {
                    Get.back();
                    _showFinalSubmitConfirmation();
                  },
                  child: const Text("FINAL SUBMIT", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancel", style: TextStyle(color: AppColors.grey)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showFinalSubmitConfirmation() {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Icon(Icons.warning_amber_rounded, size: 50, color: AppColors.red),
              const SizedBox(height: 16),
              const Text("Final Submit?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.red)),
              const SizedBox(height: 8),
              const Text(
                "After final submission, you will not be able to edit these marks. Do you want to proceed?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Get.back();
  
                        final selectedData = marksController.marksEntryClasses.firstWhereOrNull(
                          (element) => element.classId == marksController.selectedClassId.value && 
                                       element.sectionId == marksController.selectedSectionId.value
                        );
  
                        final Map<String, dynamic> body = {
                          "marks_entry_id": marksController.selectedExamTypeId.value,
                          "class_id": int.tryParse(marksController.selectedClassId.value ?? ""),
                          "section_id": int.tryParse(marksController.selectedSectionId.value ?? ""),
                          "stream_id": int.tryParse(selectedData?.streamId ?? ""),
                        };
  
                        bool success = await marksController.submitMarksToApi(body);
                        if (success) {
                          Get.offAllNamed('/dashboard');
                        }
                      },
                      child: const Text("Final Submit", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddedSubjectsCard() {
    final List<SubjectData> subjects = List<SubjectData>.from(marksController.subjectList);
    final students = marksController.studentsList;
    
    if (subjects.isEmpty || students.isEmpty) return const SizedBox.shrink();

    // Helper function to check if subject has data
    bool hasDataForSubject(SubjectData subject) {
      String subId = subject.subjectId.toString();
      for (var student in students) {
        var m = student.marks?[subId];
        if (m != null) {
          bool hasMarks = (m.wMarks?.isNotEmpty == true && m.wMarks != "null") ||
              (m.oMarks?.isNotEmpty == true && m.oMarks != "null") ||
              (m.tMarks?.isNotEmpty == true && m.tMarks != "null") ||
              (m.aMarks?.isNotEmpty == true && m.aMarks != "null") ||
              (m.bMarks?.isNotEmpty == true && m.bMarks != "null") ||
              (m.assMarks?.isNotEmpty == true && m.assMarks != "null") ||
              (m.pMarks?.isNotEmpty == true && m.pMarks != "null") ||
              (m.gGrade?.isNotEmpty == true && m.gGrade != "null");

          String? att = m.attendance;
          bool hasAtt = att != null && att.trim().isNotEmpty && att != "null" && att != "P";

          if (hasMarks || hasAtt) return true;
        }
      }
      return false;
    }

    // Sort subjects: Added (green) first
    subjects.sort((a, b) {
      bool aHas = hasDataForSubject(a);
      bool bHas = hasDataForSubject(b);
      if (aHas && !bHas) return -1;
      if (!aHas && bHas) return 1;
      return 0;
    });
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                "Subject-wise Marks Status:",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects.map((subject) {
              bool hasData = hasDataForSubject(subject);
              String displayName = subject.name ?? "";
              if (subject.isMisc == true) {
                displayName += " (Misc)";
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: hasData ? Colors.green.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasData ? Colors.green : Colors.grey.withValues(alpha: 0.3),
                    width: 1
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasData) const Icon(Icons.check_circle, size: 12, color: Colors.green),
                    if (hasData) const SizedBox(width: 4),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: hasData ? FontWeight.bold : FontWeight.w500, 
                        color: hasData ? Colors.green : Colors.grey.shade600
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      int total = marksController.studentsList.length;
      int entered = enteredCount.value;
      int pending = total - entered;

      final selectedSubject = marksController.subjectList.firstWhereOrNull(
              (s) => s.subjectId == marksController.selectedSubjectId.value
      );
      final bool isGrading = selectedSubject?.gradingType?.toLowerCase().contains('grade') == true ||
          selectedSubject?.name?.toLowerCase().contains('computer') == true;

      final maxMarks = isGrading ? "Grade" : (selectedSubject?.components?.tMax?.toString() ?? "N/A");

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            _summaryItem("Total", total.toString(), Icons.people_outline, AppColors.primary),
            _summaryDivider(),
            _summaryItem("Added", entered.toString(), Icons.check_circle_outline, AppColors.green),
            _summaryDivider(),
            _summaryItem("Pending", pending.toString(), Icons.pending_actions, AppColors.orange),
            _summaryDivider(),
            _summaryItem("Max", maxMarks, Icons.stars_outlined, Colors.blue),
          ],
        ),
      );
    });
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
          Text(label, style: AppTextStyles.body.copyWith(fontSize: 10, color: AppColors.black.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(height: 40, width: 1, color: AppColors.grey.withValues(alpha: 0.4));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary.withValues(alpha: 0.7),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildSectionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("SELECT SECTION"),
        const SizedBox(height: 8),
        Obx(() {
          final sections = marksController.sectionsForSelectedClass;
          return _buildDropdownCard(
            icon: Icons.grid_view_rounded,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Choose Section", style: AppTextStyles.body.copyWith(color: AppColors.grey)),
                value: marksController.selectedSectionId.value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                items: sections.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.sectionId,
                    child: Text(item.sectionName?.toUpperCase() ?? "", style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: (val) {
                  marksController.selectedSectionId.value = val;
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("SELECT SUBJECT"),
        const SizedBox(height: 8),
        Obx(() {
          final subjects = marksController.subjectList;
          return _buildDropdownCard(
            icon: Icons.book_outlined,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                hint: Text("Choose Subject", style: AppTextStyles.body.copyWith(color: AppColors.grey)),
                value: marksController.selectedSubjectId.value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                items: subjects.map((item) {
                  String displayName = item.name ?? "";
                  if (item.isMisc == true) {
                    displayName += " (Misc)";
                  }
                  return DropdownMenuItem<int>(
                    value: item.subjectId,
                    child: Text(displayName, style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    marksController.selectedSubjectId.value = val;
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDropdownCard({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
