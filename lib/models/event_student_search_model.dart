class EventStudentSearchModel {
  bool? success;
  List<EventStudentItem>? data;
  int? totalCount;

  EventStudentSearchModel({
    this.success,
    this.data,
    this.totalCount,
  });

  factory EventStudentSearchModel.fromJson(Map<String, dynamic> json) {
    return EventStudentSearchModel(
      success: json['success'] is bool ? json['success'] : true,
      data: (json['data'] as List?)
          ?.map((e) => EventStudentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] is num
          ? (json['total_count'] as num).toInt()
          : int.tryParse(json['total_count']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class EventStudentItem {
  int? id;
  String? studentName;
  String? admissionNumber;
  String? rollNo;
  String? studentUniqueId;
  String? className;
  String? sectionName;
  String? streamName;
  String? fatherName;
  String? fatherMobile;
  String? motherName;
  String? motherMobile;
  String? whatsappNo;
  String? studentAadhaar;
  String? fatherAadhaar;
  String? motherAadhaar;
  String? studentPhotoUrl;
  String? studentPhotoPath;
  String? fatherPhotoUrl;
  String? fatherPhotoPath;
  String? motherPhotoUrl;
  String? motherPhotoPath;
  bool? passExists;
  dynamic passId;
  String? passNumber;
  String? approvalStatus;
  String? checkinStatus;

  EventStudentItem({
    this.id,
    this.studentName,
    this.admissionNumber,
    this.rollNo,
    this.studentUniqueId,
    this.className,
    this.sectionName,
    this.streamName,
    this.fatherName,
    this.fatherMobile,
    this.motherName,
    this.motherMobile,
    this.whatsappNo,
    this.studentAadhaar,
    this.fatherAadhaar,
    this.motherAadhaar,
    this.studentPhotoUrl,
    this.studentPhotoPath,
    this.fatherPhotoUrl,
    this.fatherPhotoPath,
    this.motherPhotoUrl,
    this.motherPhotoPath,
    this.passExists,
    this.passId,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
  });

  factory EventStudentItem.fromJson(Map<String, dynamic> json) {
    return EventStudentItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      studentName: json['student_name']?.toString(),
      admissionNumber: json['admission_number']?.toString() ?? json['admission_no']?.toString(),
      rollNo: json['roll_no']?.toString(),
      studentUniqueId: json['student_unique_id']?.toString(),
      className: json['class_name']?.toString(),
      sectionName: json['section_name']?.toString(),
      streamName: json['stream_name']?.toString(),
      fatherName: json['father_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherName: json['mother_name']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      whatsappNo: json['whatsapp_no']?.toString(),
      studentAadhaar: json['student_aadhaar']?.toString(),
      fatherAadhaar: json['father_aadhaar']?.toString(),
      motherAadhaar: json['mother_aadhaar']?.toString(),
      studentPhotoUrl: json['student_photo_url']?.toString(),
      studentPhotoPath: json['student_photo_path']?.toString(),
      fatherPhotoUrl: json['father_photo_url']?.toString(),
      fatherPhotoPath: json['father_photo_path']?.toString(),
      motherPhotoUrl: json['mother_photo_url']?.toString(),
      motherPhotoPath: json['mother_photo_path']?.toString(),
      passExists: json['pass_exists'] is bool ? json['pass_exists'] : (json['pass_exists']?.toString() == 'true' || json['pass_exists'] == 1),
      passId: json['pass_id'],
      passNumber: json['pass_number']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'admission_number': admissionNumber,
      'roll_no': rollNo,
      'student_unique_id': studentUniqueId,
      'class_name': className,
      'section_name': sectionName,
      'stream_name': streamName,
      'father_name': fatherName,
      'father_mobile': fatherMobile,
      'mother_name': motherName,
      'mother_mobile': motherMobile,
      'whatsapp_no': whatsappNo,
      'student_aadhaar': studentAadhaar,
      'father_aadhaar': fatherAadhaar,
      'mother_aadhaar': motherAadhaar,
      'student_photo_url': studentPhotoUrl,
      'student_photo_path': studentPhotoPath,
      'father_photo_url': fatherPhotoUrl,
      'father_photo_path': fatherPhotoPath,
      'mother_photo_url': motherPhotoUrl,
      'mother_photo_path': motherPhotoPath,
      'pass_exists': passExists,
      'pass_id': passId,
      'pass_number': passNumber,
      'approval_status': approvalStatus,
      'checkin_status': checkinStatus,
    };
  }
}
