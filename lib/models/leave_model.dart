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
  final String? startDate;
  final String? endDate;
  final String? totalDays;
  final String? reason;
  final String? status;
  final String? appliedOn;
  final String? remarks;

  LeaveData({
    this.id,
    this.leaveType,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.reason,
    this.status,
    this.appliedOn,
    this.remarks,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      leaveType: json['leave_type'] ?? json['type'] ?? json['title']?.toString() ?? "Leave",
      startDate: json['start_date'] ?? json['from_date']?.toString() ?? "N/A",
      endDate: json['end_date'] ?? json['to_date']?.toString() ?? "N/A",
      totalDays: json['total_days']?.toString() ?? json['days']?.toString() ?? "1",
      reason: json['reason']?.toString() ?? "",
      status: json['status']?.toString() ?? "Pending",
      appliedOn: json['applied_on'] ?? json['created_at']?.toString() ?? "N/A",
      remarks: json['remarks'] ?? json['admin_remarks']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leave_type': leaveType,
      'start_date': startDate,
      'end_date': endDate,
      'total_days': totalDays,
      'reason': reason,
      'status': status,
      'applied_on': appliedOn,
      'remarks': remarks,
    };
  }
}
