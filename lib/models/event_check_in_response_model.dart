class EventCheckInResponseModel {
  bool? success;
  String? message;
  EventCheckInData? data;

  EventCheckInResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory EventCheckInResponseModel.fromJson(Map<String, dynamic> json) {
    return EventCheckInResponseModel(
      success: json['success'],
      message: json['message']?.toString(),
      data: json['data'] != null ? EventCheckInData.fromJson(json['data']) : null,
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

class EventCheckInData {
  String? passNumber;
  String? checkinStatus;
  int? admittedCount;
  List<String>? admittedAttendees;
  int? totalCheckedIn;
  int? totalApproved;
  String? checkedInAt;
  String? gateName;

  EventCheckInData({
    this.passNumber,
    this.checkinStatus,
    this.admittedCount,
    this.admittedAttendees,
    this.totalCheckedIn,
    this.totalApproved,
    this.checkedInAt,
    this.gateName,
  });

  factory EventCheckInData.fromJson(Map<String, dynamic> json) {
    return EventCheckInData(
      passNumber: json['pass_number']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      admittedCount: json['admitted_count'] is num
          ? (json['admitted_count'] as num).toInt()
          : int.tryParse(json['admitted_count']?.toString() ?? ''),
      admittedAttendees: (json['admitted_attendees'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      totalCheckedIn: json['total_checked_in'] is num
          ? (json['total_checked_in'] as num).toInt()
          : int.tryParse(json['total_checked_in']?.toString() ?? ''),
      totalApproved: json['total_approved'] is num
          ? (json['total_approved'] as num).toInt()
          : int.tryParse(json['total_approved']?.toString() ?? ''),
      checkedInAt: json['checked_in_at']?.toString(),
      gateName: json['gate_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pass_number': passNumber,
      'checkin_status': checkinStatus,
      'admitted_count': admittedCount,
      'admitted_attendees': admittedAttendees,
      'total_checked_in': totalCheckedIn,
      'total_approved': totalApproved,
      'checked_in_at': checkedInAt,
      'gate_name': gateName,
    };
  }
}
