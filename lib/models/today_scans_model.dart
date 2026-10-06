class TodayScansModel {
  bool? success;
  String? message;
  TodayScansData? data;

  TodayScansModel({
    this.success,
    this.message,
    this.data,
  });

  factory TodayScansModel.fromJson(Map<String, dynamic> json) {
    return TodayScansModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? TodayScansData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class TodayScansData {
  int? count;
  List<ScanItem>? scans;

  TodayScansData({
    this.count,
    this.scans,
  });

  factory TodayScansData.fromJson(Map<String, dynamic> json) {
    return TodayScansData(
      count: json['count'],
      scans: (json['scans'] as List?)
          ?.map((e) => ScanItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'scans': scans?.map((e) => e.toJson()).toList(),
    };
  }
}

class ScanItem {
  int? attendanceId;
  int? studentId;
  String? studentName;
  String? studentUniqueId;
  String? rollNo;
  String? className;
  String? sectionName;
  String? streamName;
  String? punchTime;
  String? profileImage;
  String? remarks;

  ScanItem({
    this.attendanceId,
    this.studentId,
    this.studentName,
    this.studentUniqueId,
    this.rollNo,
    this.className,
    this.sectionName,
    this.streamName,
    this.punchTime,
    this.profileImage,
    this.remarks,
  });

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    return ScanItem(
      attendanceId: json['attendance_id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      studentUniqueId: json['student_unique_id']?.toString(),
      rollNo: json['roll_no']?.toString(),
      className: json['class_name'],
      sectionName: json['section_name'],
      streamName: json['stream_name'],
      punchTime: json['punch_time'],
      profileImage: json['profile_image'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'student_name': studentName,
      'student_unique_id': studentUniqueId,
      'roll_no': rollNo,
      'class_name': className,
      'section_name': sectionName,
      'stream_name': streamName,
      'punch_time': punchTime,
      'profile_image': profileImage,
      'remarks': remarks,
    };
  }
}
