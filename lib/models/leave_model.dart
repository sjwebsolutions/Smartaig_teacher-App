class LeaveModel {
  final bool? success;
  final String? message;
  final List<LeaveData>? data;

  LeaveModel({this.success, this.message, this.data});

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    List<LeaveData> list = [];
    if (json['data'] != null && json['data'] is List) {
      list = (json['data'] as List).map((i) => LeaveData.fromJson(i)).toList();
    } else if (json['leaves'] != null && json['leaves'] is List) {
      list = (json['leaves'] as List).map((i) => LeaveData.fromJson(i)).toList();
    }
    return LeaveModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: list,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class LeaveData {
  final int? id;
  final String? leaveType;
  final String? leaveTypeLabel;
  final String? dayType;
  final String? dayTypeLabel;
  final String? halfDayStartTime;
  final String? halfDayEndTime;
  final String? fromDate;
  final String? toDate;
  final String? fromDateFormatted;
  final String? toDateFormatted;
  final dynamic totalDays;
  final String? reason;
  final String? attachmentUrl;
  final String? status;
  final String? statusLabel;
  final String? actionByRole;
  final String? actionByName;
  final dynamic actionViaApp;
  final String? actionAt;
  final String? approverRemarks;
  final String? rejectionReason;
  final String? createdAt;

  // Convenience getters for UI compatibility
  String get startDate => fromDateFormatted ?? fromDate ?? "N/A";
  String get endDate => toDateFormatted ?? toDate ?? "N/A";
  String get displayLeaveType => leaveTypeLabel ?? leaveType ?? "Leave";
  String get displayStatus => statusLabel ?? status ?? "Pending";
  String get remarks => approverRemarks ?? rejectionReason ?? "";

  LeaveData({
    this.id,
    this.leaveType,
    this.leaveTypeLabel,
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
    this.actionViaApp,
    this.actionAt,
    this.approverRemarks,
    this.rejectionReason,
    this.createdAt,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      leaveType: json['leave_type']?.toString(),
      leaveTypeLabel: json['leave_type_label']?.toString() ?? json['leave_type']?.toString(),
      dayType: json['day_type']?.toString(),
      dayTypeLabel: json['day_type_label']?.toString(),
      halfDayStartTime: json['half_day_start_time']?.toString(),
      halfDayEndTime: json['half_day_end_time']?.toString(),
      fromDate: json['from_date']?.toString() ?? json['start_date']?.toString(),
      toDate: json['to_date']?.toString() ?? json['end_date']?.toString(),
      fromDateFormatted: json['from_date_formatted']?.toString(),
      toDateFormatted: json['to_date_formatted']?.toString(),
      totalDays: json['total_days']?.toString() ?? json['days']?.toString() ?? "1",
      reason: json['reason']?.toString() ?? "",
      attachmentUrl: json['attachment_url']?.toString(),
      status: json['status']?.toString() ?? "pending",
      statusLabel: json['status_label']?.toString() ?? json['status']?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      actionByName: json['action_by_name']?.toString(),
      actionViaApp: json['action_via_app'],
      actionAt: json['action_at']?.toString(),
      approverRemarks: json['approver_remarks']?.toString() ?? json['remarks']?.toString(),
      rejectionReason: json['rejection_reason']?.toString() ?? json['rejectionReason']?.toString() ?? json['reject_reason']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['applied_on']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_type': leaveType,
      'leave_type_label': leaveTypeLabel,
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
      'action_via_app': actionViaApp,
      'action_at': actionAt,
      'approver_remarks': approverRemarks,
      'rejection_reason': rejectionReason,
      'created_at': createdAt,
    };
  }
}
