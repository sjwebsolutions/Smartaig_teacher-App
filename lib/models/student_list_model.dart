class StudentListModel {
  bool? success;
  StudentListData? data;

  StudentListModel({this.success, this.data});

  factory StudentListModel.fromJson(Map<String, dynamic> json) {
    return StudentListModel(
      success: json['success'],
      data: json['data'] != null ? StudentListData.fromJson(json['data']) : null,
    );
  }
}

class StudentListData {
  dynamic holiday;
  List<Student>? students;

  StudentListData({this.holiday, this.students});

  factory StudentListData.fromJson(Map<String, dynamic> json) {
    return StudentListData(
      holiday: json['holiday'],
      students: json['students'] != null
          ? (json['students'] as List).map((i) => Student.fromJson(i)).toList()
          : null,
    );
  }
}

class Student {
  int? id;
  String? studentName;
  String? rollNo;
  String? studentUniqueId;
  String? admissionNumber;
  String? fatherName;
  String? className;
  String? sectionName;
  String? streamName;
  dynamic longLeave;
  bool? isRegularAbsent;
  ExistingAttendance? existingAttendance;

  Student({
    this.id,
    this.studentName,
    this.rollNo,
    this.studentUniqueId,
    this.admissionNumber,
    this.fatherName,
    this.className,
    this.sectionName,
    this.streamName,
    this.longLeave,
    this.isRegularAbsent,
    this.existingAttendance,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentName: json['student_name'],
      rollNo: json['roll_no']?.toString(),
      studentUniqueId: json['student_unique_id'],
      admissionNumber: json['admission_number'],
      fatherName: json['father_name'],
      className: json['class_name'],
      sectionName: json['section_name'],
      streamName: json['stream_name'],
      longLeave: json['long_leave'],
      isRegularAbsent: json['is_regular_absent'],
      existingAttendance: json['existing_attendance'] != null
          ? ExistingAttendance.fromJson(json['existing_attendance'])
          : null,
    );
  }
}

class ExistingAttendance {
  String? status;
  String? remarks;

  ExistingAttendance({this.status, this.remarks});

  factory ExistingAttendance.fromJson(Map<String, dynamic> json) {
    return ExistingAttendance(
      status: json['status'],
      remarks: json['remarks'],
    );
  }
}
