class MarksStudentResponse {
  bool? success;
  bool? isLocked;
  List<SubjectData>? subjects;
  List<StudentMarkData>? students;
  List<GradeData>? grades;

  MarksStudentResponse({this.success, this.isLocked, this.subjects, this.students, this.grades});

  MarksStudentResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    isLocked = json['is_locked'] == true || json['is_locked'] == 1 || json['is_locked'] == '1' || json['is_locked'] == 'true';
    if (json['subjects'] != null) {
      subjects = <SubjectData>[];
      json['subjects'].forEach((v) {
        subjects!.add(SubjectData.fromJson(v));
      });
    }
    if (json['students'] != null) {
      students = <StudentMarkData>[];
      json['students'].forEach((v) {
        students!.add(StudentMarkData.fromJson(v));
      });
    }
    if (json['grades'] != null) {
      grades = <GradeData>[];
      json['grades'].forEach((v) {
        grades!.add(GradeData.fromJson(v));
      });
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
    subjectId = int.tryParse(json['subject_id']?.toString() ?? "");
    name = json['name']?.toString();
    isMisc = json['is_misc'] == true || json['is_misc'] == 1 || json['is_misc'] == '1';
    gradingType = json['grading_type']?.toString();
    components = json['components'] != null ? Components.fromJson(json['components']) : null;
    isTotalOnly = json['is_total_only'] == true || json['is_total_only'] == 1;
    if (json['grades'] != null) {
      grades = <GradeData>[];
      json['grades'].forEach((v) {
        grades!.add(GradeData.fromJson(v));
      });
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

  Components.fromJson(Map<String, dynamic> json) {
    wEnabled = json['w_enabled'];
    wMax = json['w_max'];
    oEnabled = json['o_enabled'];
    oMax = json['o_max'];
    aEnabled = json['a_enabled'];
    aMax = json['a_max'];
    bEnabled = json['b_enabled'];
    bMax = json['b_max'];
    assEnabled = json['ass_enabled'];
    assMax = json['ass_max'];
    pEnabled = json['p_enabled'];
    pMax = json['p_max'];
    tEnabled = json['t_enabled'];
    tMax = json['t_max'];
    gEnabled = json['g_enabled'];
  }
}

class StudentMarkData {
  int? studentId;
  String? studentName;
  String? admissionNo;
  String? rollNo;
  List<String>? allowedSubjects;
  Map<String, StudentSubjectMark>? marks;

  StudentMarkData({this.studentId, this.studentName, this.admissionNo, this.rollNo, this.allowedSubjects, this.marks});

  StudentMarkData.fromJson(Map<String, dynamic> json) {
    studentId = int.tryParse(json['student_id']?.toString() ?? "");
    studentName = json['student_name']?.toString();
    admissionNo = json['admission_no']?.toString();
    rollNo = json['roll_no']?.toString();
    allowedSubjects = json['allowed_subjects']?.cast<String>();
    if (json['marks'] != null && json['marks'] is Map) {
      marks = {};
      (json['marks'] as Map<String, dynamic>).forEach((key, value) {
        marks![key] = StudentSubjectMark.fromJson(value);
      });
    } else {
      marks = {};
    }
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
    attendance = json['attendance'];
    wMarks = json['w_marks']?.toString();
    oMarks = json['o_marks']?.toString();
    aMarks = json['a_marks']?.toString();
    bMarks = json['b_marks']?.toString();
    assMarks = json['ass_marks']?.toString();
    pMarks = json['p_marks']?.toString();
    tMarks = json['t_marks']?.toString();
    gGrade = json['g_grade']?.toString();
    grade = json['grade']?.toString();
    gradeId = json['grade_id']?.toString();
    totalMarks = json['total_marks']?.toString();
    remarks = json['remarks'];
  }
}

class GradeData {
  int? id;
  String? gradeName;

  GradeData({this.id, this.gradeName});

  GradeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    gradeName = json['grade_name'];
  }
}
