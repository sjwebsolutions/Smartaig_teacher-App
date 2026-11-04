import 'dart:io';

class EventWalkInAttendeeRequest {
  String personType; // 'father', 'mother', 'student', 'guardian', 'guest', 'other'
  String name;
  String mobileNo;
  String? whatsappNo;
  String? aadhaarNumber;
  File? photoFile;
  String? existingPhotoPath;

  EventWalkInAttendeeRequest({
    required this.personType,
    required this.name,
    required this.mobileNo,
    this.whatsappNo,
    this.aadhaarNumber,
    this.photoFile,
    this.existingPhotoPath,
  });
}

class EventIssueWalkInRequest {
  dynamic eventId;
  dynamic studentId;
  bool autoApprove;
  bool autoCheckin;
  String? gateName;
  String? remarks;
  List<EventWalkInAttendeeRequest> attendees;

  EventIssueWalkInRequest({
    required this.eventId,
    required this.studentId,
    this.autoApprove = true,
    this.autoCheckin = true,
    this.gateName = "main gate",
    this.remarks = "Walk-in entry issued at gate",
    required this.attendees,
  });
}

class EventIssueWalkInResponseModel {
  bool? success;
  String? message;
  EventWalkInPassData? data;

  EventIssueWalkInResponseModel({
    this.success,
    this.message,
    this.data,
  });

  factory EventIssueWalkInResponseModel.fromJson(Map<String, dynamic> json) {
    return EventIssueWalkInResponseModel(
      success: json['success'] is bool ? json['success'] : true,
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EventWalkInPassData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EventWalkInPassData {
  int? passId;
  String? passNumber;
  String? approvalStatus;
  String? checkinStatus;
  String? qrPayload;
  EventWalkInStudentInfo? student;
  List<EventWalkInAttendeeInfo>? attendees;
  EventWalkInGateEntryInfo? gateEntry;

  EventWalkInPassData({
    this.passId,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
    this.qrPayload,
    this.student,
    this.attendees,
    this.gateEntry,
  });

  factory EventWalkInPassData.fromJson(Map<String, dynamic> json) {
    return EventWalkInPassData(
      passId: json['pass_id'] is num
          ? (json['pass_id'] as num).toInt()
          : int.tryParse(json['pass_id']?.toString() ?? ''),
      passNumber: json['pass_number']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      qrPayload: json['qr_payload']?.toString(),
      student: json['student'] != null && json['student'] is Map<String, dynamic>
          ? EventWalkInStudentInfo.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      attendees: (json['attendees'] as List?)
          ?.map((e) => EventWalkInAttendeeInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      gateEntry: json['gate_entry'] != null && json['gate_entry'] is Map<String, dynamic>
          ? EventWalkInGateEntryInfo.fromJson(json['gate_entry'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EventWalkInStudentInfo {
  int? id;
  String? name;
  String? className;
  String? section;

  EventWalkInStudentInfo({
    this.id,
    this.name,
    this.className,
    this.section,
  });

  factory EventWalkInStudentInfo.fromJson(Map<String, dynamic> json) {
    return EventWalkInStudentInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      className: json['class']?.toString() ?? json['class_name']?.toString(),
      section: json['section']?.toString() ?? json['section_name']?.toString(),
    );
  }
}

class EventWalkInAttendeeInfo {
  int? id;
  String? name;
  String? personType;
  String? mobileNo;
  bool? isCheckedIn;
  String? photoUrl;

  EventWalkInAttendeeInfo({
    this.id,
    this.name,
    this.personType,
    this.mobileNo,
    this.isCheckedIn,
    this.photoUrl,
  });

  factory EventWalkInAttendeeInfo.fromJson(Map<String, dynamic> json) {
    return EventWalkInAttendeeInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      personType: json['person_type']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      isCheckedIn: json['is_checked_in'] is bool
          ? json['is_checked_in']
          : (json['is_checked_in']?.toString() == 'true' || json['is_checked_in'] == 1),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class EventWalkInGateEntryInfo {
  bool? isCheckedIn;
  String? gateName;
  int? checkedInCount;
  String? checkedInAt;

  EventWalkInGateEntryInfo({
    this.isCheckedIn,
    this.gateName,
    this.checkedInCount,
    this.checkedInAt,
  });

  factory EventWalkInGateEntryInfo.fromJson(Map<String, dynamic> json) {
    return EventWalkInGateEntryInfo(
      isCheckedIn: json['is_checked_in'] is bool
          ? json['is_checked_in']
          : (json['is_checked_in']?.toString() == 'true' || json['is_checked_in'] == 1),
      gateName: json['gate_name']?.toString(),
      checkedInCount: json['checked_in_count'] is num
          ? (json['checked_in_count'] as num).toInt()
          : int.tryParse(json['checked_in_count']?.toString() ?? ''),
      checkedInAt: json['checked_in_at']?.toString(),
    );
  }
}
