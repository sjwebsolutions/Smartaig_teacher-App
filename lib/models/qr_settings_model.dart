class QrSettingsModel {
  bool? success;
  String? message;
  QrSettingsData? data;

  QrSettingsModel({
    this.success,
    this.message,
    this.data,
  });

  factory QrSettingsModel.fromJson(Map<String, dynamic> json) {
    return QrSettingsModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? QrSettingsData.fromJson(json['data']) : null,
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

class QrSettingsData {
  bool? qrAttendanceEnabled;
  bool? canScan;
  String? permissionMessage;
  bool? autoAbsentEnabled;
  String? autoAbsentCutoffTime;
  ScannerInfo? scannerInfo;
  QrStats? stats;

  QrSettingsData({
    this.qrAttendanceEnabled,
    this.canScan,
    this.permissionMessage,
    this.autoAbsentEnabled,
    this.autoAbsentCutoffTime,
    this.scannerInfo,
    this.stats,
  });

  factory QrSettingsData.fromJson(Map<String, dynamic> json) {
    return QrSettingsData(
      qrAttendanceEnabled: json['qr_attendance_enabled'],
      canScan: json['can_scan'],
      permissionMessage: json['permission_message'],
      autoAbsentEnabled: json['auto_absent_enabled'],
      autoAbsentCutoffTime: json['auto_absent_cutoff_time'],
      scannerInfo: json['scanner_info'] != null
          ? ScannerInfo.fromJson(json['scanner_info'])
          : null,
      stats: json['stats'] != null ? QrStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_attendance_enabled': qrAttendanceEnabled,
      'can_scan': canScan,
      'permission_message': permissionMessage,
      'auto_absent_enabled': autoAbsentEnabled,
      'auto_absent_cutoff_time': autoAbsentCutoffTime,
      'scanner_info': scannerInfo?.toJson(),
      'stats': stats?.toJson(),
    };
  }
}

class ScannerInfo {
  String? appRole;
  String? scannerRole;
  int? userId;
  String? userName;

  ScannerInfo({
    this.appRole,
    this.scannerRole,
    this.userId,
    this.userName,
  });

  factory ScannerInfo.fromJson(Map<String, dynamic> json) {
    return ScannerInfo(
      appRole: json['app_role'],
      scannerRole: json['scanner_role'],
      userId: json['user_id'],
      userName: json['user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_role': appRole,
      'scanner_role': scannerRole,
      'user_id': userId,
      'user_name': userName,
    };
  }
}

class QrStats {
  int? scannedByMeToday;
  int? totalPresentToday;

  QrStats({
    this.scannedByMeToday,
    this.totalPresentToday,
  });

  factory QrStats.fromJson(Map<String, dynamic> json) {
    return QrStats(
      scannedByMeToday: json['scanned_by_me_today'],
      totalPresentToday: json['total_present_today'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scanned_by_me_today': scannedByMeToday,
      'total_present_today': totalPresentToday,
    };
  }
}
