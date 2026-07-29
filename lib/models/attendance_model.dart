class TeacherAttendanceModel {
  bool? success;
  String? message;
  AttendanceData? data;

  TeacherAttendanceModel({this.success, this.message, this.data});

  factory TeacherAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? AttendanceData.fromJson(json['data'])
          : null,
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

class AttendanceData {
  String? clockIn;
  String? clockOut;
  String? status;
  String? attendanceValue;

  AttendanceData({
    this.clockIn,
    this.clockOut,
    this.status,
    this.attendanceValue,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      clockIn: json['clock_in'],
      clockOut: json['clock_out']?.toString(),
      status: json['status'],
      attendanceValue: json['attendance_value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clock_in': clockIn,
      'clock_out': clockOut,
      'status': status,
      'attendance_value': attendanceValue,
    };
  }
}