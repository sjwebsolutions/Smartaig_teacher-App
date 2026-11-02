class EventPassScanResponseModel {
  bool? success;
  String? message;
  bool? isAlreadyCheckedIn;
  bool? canCheckin;
  String? warning;
  EventPassScanData? data;

  EventPassScanResponseModel({
    this.success,
    this.message,
    this.isAlreadyCheckedIn,
    this.canCheckin,
    this.warning,
    this.data,
  });

  factory EventPassScanResponseModel.fromJson(Map<String, dynamic> json) {
    return EventPassScanResponseModel(
      success: json['success'],
      message: json['message']?.toString(),
      isAlreadyCheckedIn: json['is_already_checked_in'],
      canCheckin: json['can_checkin'],
      warning: json['warning']?.toString(),
      data: json['data'] != null ? EventPassScanData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'is_already_checked_in': isAlreadyCheckedIn,
      'can_checkin': canCheckin,
      'warning': warning,
      'data': data?.toJson(),
    };
  }
}

class EventPassScanData {
  EventPassInfo? pass;
  EventInfo? event;
  EventStudentInfo? student;
  List<EventAttendeeInfo>? approvedAttendees;
  List<EventAttendeeInfo>? rejectedAttendees;

  EventPassScanData({
    this.pass,
    this.event,
    this.student,
    this.approvedAttendees,
    this.rejectedAttendees,
  });

  factory EventPassScanData.fromJson(Map<String, dynamic> json) {
    return EventPassScanData(
      pass: json['pass'] != null ? EventPassInfo.fromJson(json['pass']) : null,
      event: json['event'] != null ? EventInfo.fromJson(json['event']) : null,
      student: json['student'] != null ? EventStudentInfo.fromJson(json['student']) : null,
      approvedAttendees: (json['approved_attendees'] as List?)
          ?.map((e) => EventAttendeeInfo.fromJson(e))
          .toList(),
      rejectedAttendees: (json['rejected_attendees'] as List?)
          ?.map((e) => EventAttendeeInfo.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pass': pass?.toJson(),
      'event': event?.toJson(),
      'student': student?.toJson(),
      'approved_attendees': approvedAttendees?.map((e) => e.toJson()).toList(),
      'rejected_attendees': rejectedAttendees?.map((e) => e.toJson()).toList(),
    };
  }
}

class EventPassInfo {
  int? id;
  String? uuid;
  String? passNumber;
  String? approvalStatus;
  String? checkinStatus;
  String? firstCheckinAt;
  int? totalAttendeesRequested;
  int? totalAttendeesApproved;
  int? totalCheckedIn;
  int? totalRemaining;

  EventPassInfo({
    this.id,
    this.uuid,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
    this.firstCheckinAt,
    this.totalAttendeesRequested,
    this.totalAttendeesApproved,
    this.totalCheckedIn,
    this.totalRemaining,
  });

  factory EventPassInfo.fromJson(Map<String, dynamic> json) {
    return EventPassInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      uuid: json['uuid']?.toString(),
      passNumber: json['pass_number']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      firstCheckinAt: json['first_checkin_at']?.toString(),
      totalAttendeesRequested: json['total_attendees_requested'] is num
          ? (json['total_attendees_requested'] as num).toInt()
          : int.tryParse(json['total_attendees_requested']?.toString() ?? ''),
      totalAttendeesApproved: json['total_attendees_approved'] is num
          ? (json['total_attendees_approved'] as num).toInt()
          : int.tryParse(json['total_attendees_approved']?.toString() ?? ''),
      totalCheckedIn: json['total_checked_in'] is num
          ? (json['total_checked_in'] as num).toInt()
          : int.tryParse(json['total_checked_in']?.toString() ?? ''),
      totalRemaining: json['total_remaining'] is num
          ? (json['total_remaining'] as num).toInt()
          : int.tryParse(json['total_remaining']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'pass_number': passNumber,
      'approval_status': approvalStatus,
      'checkin_status': checkinStatus,
      'first_checkin_at': firstCheckinAt,
      'total_attendees_requested': totalAttendeesRequested,
      'total_attendees_approved': totalAttendeesApproved,
      'total_checked_in': totalCheckedIn,
      'total_remaining': totalRemaining,
    };
  }
}

class EventInfo {
  int? id;
  String? title;
  String? venue;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;

  EventInfo({
    this.id,
    this.title,
    this.venue,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      title: json['title']?.toString(),
      venue: json['venue']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'venue': venue,
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class EventStudentInfo {
  int? id;
  String? studentName;
  String? studentNamePunjabi;
  String? admissionNumber;
  String? rollNo;
  String? studentUniqueId;
  String? studentClass;
  String? section;
  String? classSection;
  String? fatherName;
  String? fatherMobile;
  String? motherName;
  String? motherMobile;
  String? photoUrl;

  EventStudentInfo({
    this.id,
    this.studentName,
    this.studentNamePunjabi,
    this.admissionNumber,
    this.rollNo,
    this.studentUniqueId,
    this.studentClass,
    this.section,
    this.classSection,
    this.fatherName,
    this.fatherMobile,
    this.motherName,
    this.motherMobile,
    this.photoUrl,
  });

  factory EventStudentInfo.fromJson(Map<String, dynamic> json) {
    return EventStudentInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      studentName: json['student_name']?.toString(),
      studentNamePunjabi: json['student_name_punjabi']?.toString(),
      admissionNumber: json['admission_number']?.toString(),
      rollNo: json['roll_no']?.toString(),
      studentUniqueId: json['student_unique_id']?.toString(),
      studentClass: json['class']?.toString(),
      section: json['section']?.toString(),
      classSection: json['class_section']?.toString(),
      fatherName: json['father_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherName: json['mother_name']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'student_name_punjabi': studentNamePunjabi,
      'admission_number': admissionNumber,
      'roll_no': rollNo,
      'student_unique_id': studentUniqueId,
      'class': studentClass,
      'section': section,
      'class_section': classSection,
      'father_name': fatherName,
      'father_mobile': fatherMobile,
      'mother_name': motherName,
      'mother_mobile': motherMobile,
      'photo_url': photoUrl,
    };
  }
}

class EventAttendeeInfo {
  int? id;
  String? name;
  String? personType;
  String? mobileNo;
  String? maskedAadhaar;
  String? photoUrl;
  bool? isCheckedIn;
  String? checkedInAt;

  EventAttendeeInfo({
    this.id,
    this.name,
    this.personType,
    this.mobileNo,
    this.maskedAadhaar,
    this.photoUrl,
    this.isCheckedIn,
    this.checkedInAt,
  });

  factory EventAttendeeInfo.fromJson(Map<String, dynamic> json) {
    return EventAttendeeInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      personType: json['person_type']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      maskedAadhaar: json['masked_aadhaar']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      isCheckedIn: json['is_checked_in'],
      checkedInAt: json['checked_in_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'person_type': personType,
      'mobile_no': mobileNo,
      'masked_aadhaar': maskedAadhaar,
      'photo_url': photoUrl,
      'is_checked_in': isCheckedIn,
      'checked_in_at': checkedInAt,
    };
  }
}
