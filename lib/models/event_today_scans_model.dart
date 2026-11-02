class EventTodayScansModel {
  bool? success;
  EventTodayScansData? data;

  EventTodayScansModel({
    this.success,
    this.data,
  });

  factory EventTodayScansModel.fromJson(Map<String, dynamic> json) {
    return EventTodayScansModel(
      success: json['success'],
      data: json['data'] != null ? EventTodayScansData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class EventTodayScansData {
  int? totalValidScansToday;
  List<EventScanItem>? scans;

  EventTodayScansData({
    this.totalValidScansToday,
    this.scans,
  });

  factory EventTodayScansData.fromJson(Map<String, dynamic> json) {
    return EventTodayScansData(
      totalValidScansToday: json['total_valid_scans_today'] is num
          ? (json['total_valid_scans_today'] as num).toInt()
          : int.tryParse(json['total_valid_scans_today']?.toString() ?? ''),
      scans: (json['scans'] as List?)
          ?.map((e) => EventScanItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_valid_scans_today': totalValidScansToday,
      'scans': scans?.map((e) => e.toJson()).toList(),
    };
  }
}

class EventScanItem {
  int? id;
  String? passNumber;
  String? eventTitle;
  String? studentName;
  String? admissionNo;
  String? classSection;
  String? scanStatus;
  String? scanMessage;
  String? gateName;
  String? scannedBy;
  String? scannedAt;
  String? scannedAtFull;

  EventScanItem({
    this.id,
    this.passNumber,
    this.eventTitle,
    this.studentName,
    this.admissionNo,
    this.classSection,
    this.scanStatus,
    this.scanMessage,
    this.gateName,
    this.scannedBy,
    this.scannedAt,
    this.scannedAtFull,
  });

  factory EventScanItem.fromJson(Map<String, dynamic> json) {
    return EventScanItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? ''),
      passNumber: json['pass_number']?.toString(),
      eventTitle: json['event_title']?.toString(),
      studentName: json['student_name']?.toString(),
      admissionNo: json['admission_no']?.toString(),
      classSection: json['class_section']?.toString(),
      scanStatus: json['scan_status']?.toString(),
      scanMessage: json['scan_message']?.toString(),
      gateName: json['gate_name']?.toString(),
      scannedBy: json['scanned_by']?.toString(),
      scannedAt: json['scanned_at']?.toString(),
      scannedAtFull: json['scanned_at_full']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pass_number': passNumber,
      'event_title': eventTitle,
      'student_name': studentName,
      'admission_no': admissionNo,
      'class_section': classSection,
      'scan_status': scanStatus,
      'scan_message': scanMessage,
      'gate_name': gateName,
      'scanned_by': scannedBy,
      'scanned_at': scannedAt,
      'scanned_at_full': scannedAtFull,
    };
  }
}
