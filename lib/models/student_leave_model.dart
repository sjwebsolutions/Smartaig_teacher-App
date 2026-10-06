class StudentLeaveModel {
  bool? success;
  bool? canApprove;
  String? message;
  List<StudentLeaveData>? data;

  StudentLeaveModel({
    this.success,
    this.canApprove,
    this.message,
    this.data,
  });

  factory StudentLeaveModel.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'];
    return StudentLeaveModel(
      success: json['success'] as bool? ?? true,
      canApprove: json['can_approve'] as bool? ?? false,
      message: json['message'] as String?,
      data: dataList is List
          ? dataList.map((i) => StudentLeaveData.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'can_approve': canApprove,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class StudentLeaveData {
  int? id;
  int? studentId;
  int? studentClassId;
  int? studentSectionId;
  int? studentStreamId;
  String? studentName;
  String? admissionNumber;
  String? rollNo;
  String? className;
  String? sectionName;
  String? streamName;
  String? dayType;
  String? dayTypeLabel;
  String? halfDayStartTime;
  String? halfDayEndTime;
  String? fromDate;
  String? toDate;
  String? fromDateFormatted;
  String? toDateFormatted;
  num? totalDays;
  String? reason;
  String? attachmentUrl;
  String? status;
  String? statusLabel;
  String? actionByRole;
  String? actionByName;
  String? actionAt;
  String? approverRemarks;
  String? rejectionReason;
  String? createdAt;

  StudentLeaveData({
    this.id,
    this.studentId,
    this.studentClassId,
    this.studentSectionId,
    this.studentStreamId,
    this.studentName,
    this.admissionNumber,
    this.rollNo,
    this.className,
    this.sectionName,
    this.streamName,
    this.dayType,
    this.dayTypeLabel,
    this.halfDayStartTime,
    this.halfDayEndTime,
    this.fromDate,
    this.toDate,
    this.fromDateFormatted,
    this.toDateFormatted,
    this.totalDays,
    this.reason,
    this.attachmentUrl,
    this.status,
    this.statusLabel,
    this.actionByRole,
    this.actionByName,
    this.actionAt,
    this.approverRemarks,
    this.rejectionReason,
    this.createdAt,
  });

  factory StudentLeaveData.fromJson(Map<String, dynamic> json) {
    return StudentLeaveData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      studentId: json['student_id'] is int ? json['student_id'] : int.tryParse(json['student_id']?.toString() ?? ''),
      studentClassId: json['student_class_id'] is int ? json['student_class_id'] : int.tryParse(json['student_class_id']?.toString() ?? ''),
      studentSectionId: json['student_section_id'] is int ? json['student_section_id'] : int.tryParse(json['student_section_id']?.toString() ?? ''),
      studentStreamId: json['student_stream_id'] is int ? json['student_stream_id'] : int.tryParse(json['student_stream_id']?.toString() ?? ''),
      studentName: json['student_name']?.toString() ?? "N/A",
      admissionNumber: json['admission_number']?.toString() ?? "",
      rollNo: json['roll_no']?.toString() ?? "",
      className: json['class_name']?.toString() ?? "",
      sectionName: json['section_name']?.toString() ?? "",
      streamName: json['stream_name']?.toString(),
      dayType: json['day_type']?.toString(),
      dayTypeLabel: json['day_type_label']?.toString() ?? "Full Day",
      halfDayStartTime: json['half_day_start_time']?.toString(),
      halfDayEndTime: json['half_day_end_time']?.toString(),
      fromDate: json['from_date']?.toString(),
      toDate: json['to_date']?.toString(),
      fromDateFormatted: json['from_date_formatted']?.toString() ?? json['from_date']?.toString() ?? "N/A",
      toDateFormatted: json['to_date_formatted']?.toString() ?? json['to_date']?.toString() ?? "N/A",
      totalDays: json['total_days'] is num ? json['total_days'] : num.tryParse(json['total_days']?.toString() ?? '1') ?? 1,
      reason: json['reason']?.toString() ?? "",
      attachmentUrl: json['attachment_url']?.toString(),
      status: json['status']?.toString() ?? "pending",
      statusLabel: json['status_label']?.toString() ?? "Pending",
      actionByRole: json['action_by_role']?.toString(),
      actionByName: json['action_by_name']?.toString(),
      actionAt: json['action_at']?.toString(),
      approverRemarks: json['approver_remarks']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_class_id': studentClassId,
      'student_section_id': studentSectionId,
      'student_stream_id': studentStreamId,
      'student_name': studentName,
      'admission_number': admissionNumber,
      'roll_no': rollNo,
      'class_name': className,
      'section_name': sectionName,
      'stream_name': streamName,
      'day_type': dayType,
      'day_type_label': dayTypeLabel,
      'half_day_start_time': halfDayStartTime,
      'half_day_end_time': halfDayEndTime,
      'from_date': fromDate,
      'to_date': toDate,
      'from_date_formatted': fromDateFormatted,
      'to_date_formatted': toDateFormatted,
      'total_days': totalDays,
      'reason': reason,
      'attachment_url': attachmentUrl,
      'status': status,
      'status_label': statusLabel,
      'action_by_role': actionByRole,
      'action_by_name': actionByName,
      'action_at': actionAt,
      'approver_remarks': approverRemarks,
      'rejection_reason': rejectionReason,
      'created_at': createdAt,
    };
  }
}
