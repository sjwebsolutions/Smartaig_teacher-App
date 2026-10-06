class QrScanModel {
  bool? success;
  bool? alreadyMarked;
  String? message;
  QrScanData? data;

  QrScanModel({
    this.success,
    this.alreadyMarked,
    this.message,
    this.data,
  });

  factory QrScanModel.fromJson(Map<String, dynamic> json) {
    return QrScanModel(
      success: json['success'],
      alreadyMarked: json['already_marked'],
      message: json['message'],
      data: json['data'] != null ? QrScanData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'already_marked': alreadyMarked,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class QrScanData {
  QrStudent? student;
  QrAttendanceInfo? attendance;
  bool? onLeaveWarning;
  dynamic leaveDetails;

  QrScanData({
    this.student,
    this.attendance,
    this.onLeaveWarning,
    this.leaveDetails,
  });

  factory QrScanData.fromJson(Map<String, dynamic> json) {
    return QrScanData(
      student: json['student'] != null ? QrStudent.fromJson(json['student']) : null,
      attendance:
          json['attendance'] != null ? QrAttendanceInfo.fromJson(json['attendance']) : null,
      onLeaveWarning: json['on_leave_warning'],
      leaveDetails: json['leave_details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student?.toJson(),
      'attendance': attendance?.toJson(),
      'on_leave_warning': onLeaveWarning,
      'leave_details': leaveDetails,
    };
  }
}

class QrStudent {
  int? id;
  String? studentUniqueId;
  String? studentName;
  String? studentNamePunjabi;
  String? rollNo;
  String? admissionNumber;
  int? classId;
  String? className;
  int? sectionId;
  String? sectionName;
  int? streamId;
  String? streamName;
  String? gender;
  String? fatherName;
  String? fatherMobile;
  String? profileImage;

  QrStudent({
    this.id,
    this.studentUniqueId,
    this.studentName,
    this.studentNamePunjabi,
    this.rollNo,
    this.admissionNumber,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.streamId,
    this.streamName,
    this.gender,
    this.fatherName,
    this.fatherMobile,
    this.profileImage,
  });

  factory QrStudent.fromJson(Map<String, dynamic> json) {
    return QrStudent(
      id: json['id'],
      studentUniqueId: json['student_unique_id']?.toString(),
      studentName: json['student_name'],
      studentNamePunjabi: json['student_name_punjabi'],
      rollNo: json['roll_no']?.toString(),
      admissionNumber: json['admission_number']?.toString(),
      classId: json['class_id'],
      className: json['class_name'],
      sectionId: json['section_id'],
      sectionName: json['section_name'],
      streamId: json['stream_id'],
      streamName: json['stream_name'],
      gender: json['gender'],
      fatherName: json['father_name'],
      fatherMobile: json['father_mobile']?.toString(),
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_unique_id': studentUniqueId,
      'student_name': studentName,
      'student_name_punjabi': studentNamePunjabi,
      'roll_no': rollNo,
      'admission_number': admissionNumber,
      'class_id': classId,
      'class_name': className,
      'section_id': sectionId,
      'section_name': sectionName,
      'stream_id': streamId,
      'stream_name': streamName,
      'gender': gender,
      'father_name': fatherName,
      'father_mobile': fatherMobile,
      'profile_image': profileImage,
    };
  }
}

class QrAttendanceInfo {
  int? id;
  String? status;
  String? date;
  String? punchTime;
  String? markedVia;
  String? takenByName;
  String? takenByRole;
  String? remarks;

  QrAttendanceInfo({
    this.id,
    this.status,
    this.date,
    this.punchTime,
    this.markedVia,
    this.takenByName,
    this.takenByRole,
    this.remarks,
  });

  factory QrAttendanceInfo.fromJson(Map<String, dynamic> json) {
    return QrAttendanceInfo(
      id: json['id'],
      status: json['status'],
      date: json['date'],
      punchTime: json['punch_time'],
      markedVia: json['marked_via'],
      takenByName: json['taken_by_name'],
      takenByRole: json['taken_by_role'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'date': date,
      'punch_time': punchTime,
      'marked_via': markedVia,
      'taken_by_name': takenByName,
      'taken_by_role': takenByRole,
      'remarks': remarks,
    };
  }
}
