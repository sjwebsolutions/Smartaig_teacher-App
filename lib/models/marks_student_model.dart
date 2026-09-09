class MarksStudentResponse {
  bool? success;
  bool? isLocked;
  List<SubjectData>? subjects;
  List<StudentMarkData>? students;
  List<GradeData>? grades;

  MarksStudentResponse({this.success, this.isLocked, this.subjects, this.students, this.grades});

  MarksStudentResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true || json['success'] == 1 || json['success'] == 'true';
    isLocked = json['is_locked'] == true || json['is_locked'] == 1 || json['is_locked'] == '1' || json['is_locked'] == 'true';
    
    final subjectsJson = json['subjects'] ?? json['data']?['subjects'] ?? json['all_subjects'];
    if (subjectsJson != null && subjectsJson is List) {
      subjects = <SubjectData>[];
      for (var v in subjectsJson) {
        if (v is Map<String, dynamic>) {
          subjects!.add(SubjectData.fromJson(v));
        } else if (v is Map) {
          subjects!.add(SubjectData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    final studentsJson = json['students'] ?? json['data']?['students'];
    if (studentsJson != null && studentsJson is List) {
      students = <StudentMarkData>[];
      for (var v in studentsJson) {
        if (v is Map<String, dynamic>) {
          students!.add(StudentMarkData.fromJson(v));
        } else if (v is Map) {
          students!.add(StudentMarkData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    final gradesJson = json['grades'] ?? json['data']?['grades'];
    if (gradesJson != null && gradesJson is List) {
      grades = <GradeData>[];
      for (var v in gradesJson) {
        if (v is Map<String, dynamic>) {
          grades!.add(GradeData.fromJson(v));
        } else if (v is Map) {
          grades!.add(GradeData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
  }
}

class SubjectData {
  int? subjectId;
  String? name;
  bool? isMisc;
  String? gradingType;
  Components? components;
  bool? isTotalOnly;
  List<GradeData>? grades;

  SubjectData({this.subjectId, this.name, this.isMisc, this.gradingType, this.components, this.isTotalOnly, this.grades});

  SubjectData.fromJson(Map<String, dynamic> json) {
    subjectId = int.tryParse(json['subject_id']?.toString() ?? json['id']?.toString() ?? "");
    name = json['name']?.toString() ?? json['subject_name']?.toString();
    isMisc = json['is_misc'] == true || json['is_misc'] == 1 || json['is_misc'] == '1' || json['is_misc'] == 'true';
    gradingType = json['grading_type']?.toString();
    components = json['components'] != null ? Components.fromJson(json['components']) : null;
    isTotalOnly = json['is_total_only'] == true || json['is_total_only'] == 1 || json['is_total_only'] == '1' || json['is_total_only'] == 'true';
    if (json['grades'] != null && json['grades'] is List) {
      grades = <GradeData>[];
      for (var v in json['grades']) {
        if (v is Map<String, dynamic>) {
          grades!.add(GradeData.fromJson(v));
        } else if (v is Map) {
          grades!.add(GradeData.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
  }
}

class Components {
  bool? wEnabled;
  dynamic wMax;
  bool? oEnabled;
  dynamic oMax;
  bool? aEnabled;
  dynamic aMax;
  bool? bEnabled;
  dynamic bMax;
  bool? assEnabled;
  dynamic assMax;
  bool? pEnabled;
  dynamic pMax;
  bool? tEnabled;
  dynamic tMax;
  bool? gEnabled;

  static bool _parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final s = val.toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  Components.fromJson(Map<String, dynamic> json) {
    wEnabled = _parseBool(json['w_enabled']);
    wMax = json['w_max'];
    oEnabled = _parseBool(json['o_enabled']);
    oMax = json['o_max'];
    aEnabled = _parseBool(json['a_enabled']);
    aMax = json['a_max'];
    bEnabled = _parseBool(json['b_enabled']);
    bMax = json['b_max'];
    assEnabled = _parseBool(json['ass_enabled']);
    assMax = json['ass_max'];
    pEnabled = _parseBool(json['p_enabled']);
    pMax = json['p_max'];
    tEnabled = _parseBool(json['t_enabled']);
    tMax = json['t_max'];
    gEnabled = _parseBool(json['g_enabled']);
  }
}

class StudentMarkData {
  int? studentId;
  String? studentName;
  String? fatherName;
  String? admissionNo;
  String? rollNo;
  List<String>? allowedSubjects;
  Map<String, StudentSubjectMark>? marks;

  StudentMarkData({
    this.studentId,
    this.studentName,
    this.fatherName,
    this.admissionNo,
    this.rollNo,
    this.allowedSubjects,
    this.marks,
  });

  static List<String>? _parseAllowedSubjects(dynamic jsonVal) {
    if (jsonVal == null) return null;
    if (jsonVal is List) {
      List<String> list = [];
      for (var item in jsonVal) {
        if (item == null) continue;
        if (item is Map) {
          final sId = item['subject_id']?.toString() ?? item['id']?.toString();
          if (sId != null && sId.isNotEmpty) {
            list.add(sId);
          }
          final sName = item['name']?.toString() ?? item['subject_name']?.toString();
          if (sName != null && sName.isNotEmpty) {
            list.add(sName);
          }
        } else {
          final str = item.toString().trim();
          if (str.isNotEmpty) {
            list.add(str);
          }
        }
      }
      return list.isNotEmpty ? list : null;
    } else if (jsonVal is String) {
      if (jsonVal.trim().isEmpty) return null;
      final split = jsonVal.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return split.isNotEmpty ? split : null;
    }
    return null;
  }

  StudentMarkData.fromJson(Map<String, dynamic> json) {
    studentId = int.tryParse(json['student_id']?.toString() ?? json['id']?.toString() ?? "");
    studentName = json['student_name']?.toString() ?? json['name']?.toString();
    fatherName = json['father_name']?.toString();
    admissionNo = json['admission_no']?.toString() ?? json['admission_number']?.toString();
    rollNo = json['roll_no']?.toString() ?? json['roll_number']?.toString();

    // Safely extract allowed / enrolled subjects from any possible backend key
    allowedSubjects = _parseAllowedSubjects(json['allowed_subjects']) ??
                      _parseAllowedSubjects(json['allowed_subject_ids']) ??
                      _parseAllowedSubjects(json['assigned_subjects']) ??
                      _parseAllowedSubjects(json['student_subjects']) ??
                      _parseAllowedSubjects(json['optional_subjects']) ??
                      _parseAllowedSubjects(json['subjects']);

    // Safely parse marks map or list
    marks = {};
    final marksJson = json['marks'];
    if (marksJson != null) {
      if (marksJson is Map) {
        marksJson.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            marks![key.toString()] = StudentSubjectMark.fromJson(value);
          } else if (value is Map) {
            marks![key.toString()] = StudentSubjectMark.fromJson(Map<String, dynamic>.from(value));
          }
        });
      } else if (marksJson is List) {
        for (var item in marksJson) {
          if (item is Map) {
            final mapItem = Map<String, dynamic>.from(item);
            final sId = mapItem['subject_id']?.toString() ?? mapItem['id']?.toString();
            if (sId != null && sId.isNotEmpty) {
              marks![sId] = StudentSubjectMark.fromJson(mapItem);
            }
          }
        }
      }
    }
  }

  /// Checks if this student takes / is enrolled in the given subject.
  bool hasSubject(dynamic subjectId, [String? subjectName]) {
    final subIdStr = subjectId?.toString().trim();
    final subNameClean = subjectName?.trim().toLowerCase();

    // 1. If the student has an explicit list of allowed/assigned subjects:
    if (allowedSubjects != null && allowedSubjects!.isNotEmpty) {
      if (subIdStr != null && subIdStr.isNotEmpty) {
        if (allowedSubjects!.any((s) => s.trim() == subIdStr)) {
          return true;
        }
      }
      if (subNameClean != null && subNameClean.isNotEmpty) {
        if (allowedSubjects!.any((s) => s.trim().toLowerCase() == subNameClean)) {
          return true;
        }
      }
      return false;
    }

    // 2. If student already has existing marks for this subject:
    if (marks != null && marks!.isNotEmpty && subIdStr != null) {
      if (marks!.containsKey(subIdStr)) {
        return true;
      }
    }

    // 3. Default: student is eligible for all standard class subjects
    return true;
  }
}

class StudentSubjectMark {
  String? attendance;
  String? wMarks;
  String? oMarks;
  String? aMarks;
  String? bMarks;
  String? assMarks;
  String? pMarks;
  String? tMarks;
  String? gGrade;
  String? grade;
  String? gradeId;
  String? totalMarks;
  String? remarks;

  StudentSubjectMark({
    this.attendance,
    this.wMarks,
    this.oMarks,
    this.aMarks,
    this.bMarks,
    this.assMarks,
    this.pMarks,
    this.tMarks,
    this.gGrade,
    this.grade,
    this.gradeId,
    this.totalMarks,
    this.remarks,
  });

  StudentSubjectMark.fromJson(Map<String, dynamic> json) {
    attendance = json['attendance']?.toString();
    wMarks = json['w_marks']?.toString() ?? json['w']?.toString() ?? json['written_marks']?.toString();
    oMarks = json['o_marks']?.toString() ?? json['o']?.toString() ?? json['oral_marks']?.toString();
    aMarks = json['a_marks']?.toString() ?? json['a']?.toString();
    bMarks = json['b_marks']?.toString() ?? json['b']?.toString();
    assMarks = json['ass_marks']?.toString() ?? json['ass']?.toString() ?? json['assessment_marks']?.toString();
    pMarks = json['p_marks']?.toString() ?? json['p']?.toString() ?? json['practical_marks']?.toString();
    tMarks = json['t_marks']?.toString() ?? json['t']?.toString() ?? json['total_marks']?.toString() ?? json['total']?.toString();
    gGrade = json['g_grade']?.toString() ?? json['g']?.toString();
    grade = json['grade']?.toString();
    gradeId = json['grade_id']?.toString();
    totalMarks = json['total_marks']?.toString() ?? json['total']?.toString();
    remarks = json['remarks']?.toString();
  }
}

class GradeData {
  int? id;
  String? gradeName;

  GradeData({this.id, this.gradeName});

  GradeData.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? "");
    gradeName = json['grade_name']?.toString() ?? json['name']?.toString();
  }
}
