class DashboardTeacherModel {
  final bool? success;
  final DashboardData? data;

  DashboardTeacherModel({
    this.success,
    this.data,
  });

  factory DashboardTeacherModel.fromJson(Map<String, dynamic> json) {
    return DashboardTeacherModel(
      success: json['success'],
      data: json['data'] != null
          ? DashboardData.fromJson(json['data'])
          : null,
    );
  }
}
class DashboardData {
  final Teacher? teacher;
  final String? activeSession;
  final School? school;
  final bool? isWeeklyOff;
  final TodayAttendance? todayAttendance;

  DashboardData({
    this.teacher,
    this.activeSession,
    this.school,
    this.isWeeklyOff,
    this.todayAttendance,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      teacher: json['teacher'] != null
          ? Teacher.fromJson(json['teacher'])
          : null,
      activeSession: json['active_session']?.toString(),
      school: json['school'] != null
          ? School.fromJson(json['school'])
          : null,
      isWeeklyOff: json['is_weekly_off'],
      todayAttendance: json['today_attendance'] != null && json['today_attendance'] is Map<String, dynamic>
          ? TodayAttendance.fromJson(json['today_attendance'])
          : null,
    );
  }
}

class TodayAttendance {
  final bool? isMarked;
  final String? status;
  final String? statusCode;
  final String? statusLabel;
  final String? clockIn;
  final String? clockOut;

  TodayAttendance({
    this.isMarked,
    this.status,
    this.statusCode,
    this.statusLabel,
    this.clockIn,
    this.clockOut,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      isMarked: json['is_marked'],
      status: json['status']?.toString(),
      statusCode: json['status_code']?.toString(),
      statusLabel: json['status_label']?.toString(),
      clockIn: json['clock_in']?.toString(),
      clockOut: json['clock_out']?.toString(),
    );
  }
}

class Teacher {
  final int? id;
  final String? name;
  final String? staffType;
  final String? whatsappNumber;
  final String? phone;
  final String? email;
  final String? schoolId;
  final String? teacherUniqueId;
  final String? gender;
  final String? status;
  final String? image;

  Teacher({
    this.id,
    this.name,
    this.staffType,
    this.whatsappNumber,
    this.phone,
    this.email,
    this.schoolId,
    this.teacherUniqueId,
    this.gender,
    this.status,
    this.image,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name']?.toString(),
      staffType: json['staff_type']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      schoolId: json['school_id']?.toString(),
      teacherUniqueId: json['teacher_unique_id']?.toString(),
      gender: json['gender']?.toString(),
      status: json['status']?.toString(),
      image: json['image']?.toString(),
    );
  }
}
class School {
  final int? id;
  final String? schoolName;

  School({
    this.id,
    this.schoolName,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      schoolName: json['school_name']?.toString(),
    );
  }
}