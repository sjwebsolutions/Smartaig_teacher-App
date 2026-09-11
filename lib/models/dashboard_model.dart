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
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }
}

class DashboardData {
  final Teacher? teacher;
  final String? activeSession;
  final School? school;
  final List<AssignedSubject>? assignedSubjects;
  final TodayAttendance? todayAttendance;
  final List<TodayTomorrowDuty>? todayTomorrowDuties;
  final dynamic todayLeave;
  final dynamic todayHoliday;
  final bool? isWeeklyOff;
  final AttendanceSettings? attendanceSettings;

  DashboardData({
    this.teacher,
    this.activeSession,
    this.school,
    this.assignedSubjects,
    this.todayAttendance,
    this.todayTomorrowDuties,
    this.todayLeave,
    this.todayHoliday,
    this.isWeeklyOff,
    this.attendanceSettings,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher']) : null,
      activeSession: json['active_session']?.toString(),
      school: json['school'] != null ? School.fromJson(json['school']) : null,
      assignedSubjects: json['assigned_subjects'] != null
          ? (json['assigned_subjects'] as List).map((i) => AssignedSubject.fromJson(i)).toList()
          : null,
      todayAttendance: json['today_attendance'] != null && json['today_attendance'] is Map<String, dynamic>
          ? TodayAttendance.fromJson(json['today_attendance'])
          : null,
      todayTomorrowDuties: json['today_tomorrow_duties'] != null
          ? (json['today_tomorrow_duties'] as List).map((i) => TodayTomorrowDuty.fromJson(i)).toList()
          : null,
      todayLeave: json['today_leave'],
      todayHoliday: json['today_holiday'],
      isWeeklyOff: json['is_weekly_off'],
      attendanceSettings: json['attendance_settings'] != null
          ? AttendanceSettings.fromJson(json['attendance_settings'])
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
  final num? attendanceValue;
  final String? remarks;

  TodayAttendance({
    this.isMarked,
    this.status,
    this.statusCode,
    this.statusLabel,
    this.clockIn,
    this.clockOut,
    this.attendanceValue,
    this.remarks,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      isMarked: json['is_marked'],
      status: json['status']?.toString(),
      statusCode: json['status_code']?.toString(),
      statusLabel: json['status_label']?.toString(),
      clockIn: json['clock_in']?.toString(),
      clockOut: json['clock_out']?.toString(),
      attendanceValue: json['attendance_value'],
      remarks: json['remarks']?.toString(),
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
  final String? dob;
  final String? thumbnail;
  final String? address;
  final String? district;
  final String? state;
  final String? pincode;
  final List<Experience>? experience;

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
    this.dob,
    this.thumbnail,
    this.address,
    this.district,
    this.state,
    this.pincode,
    this.experience,
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
      dob: json['dob']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      address: json['address']?.toString(),
      district: json['district']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      experience: json['experience'] != null
          ? (json['experience'] as List).map((i) => Experience.fromJson(i)).toList()
          : null,
    );
  }
}

class Experience {
  final String? schoolName;
  final String? fromDate;
  final String? toDate;
  final String? subject;

  Experience({
    this.schoolName,
    this.fromDate,
    this.toDate,
    this.subject,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      schoolName: json['school_name']?.toString(),
      fromDate: json['from_date']?.toString(),
      toDate: json['to_date']?.toString(),
      subject: json['subject']?.toString(),
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

class AssignedSubject {
  final int? id;
  final ClassData? classData;
  final SectionData? section;
  final dynamic stream;
  final SubjectData? subject;

  AssignedSubject({
    this.id,
    this.classData,
    this.section,
    this.stream,
    this.subject,
  });

  factory AssignedSubject.fromJson(Map<String, dynamic> json) {
    return AssignedSubject(
      id: json['id'],
      classData: json['class'] != null ? ClassData.fromJson(json['class']) : null,
      section: json['section'] != null ? SectionData.fromJson(json['section']) : null,
      stream: json['stream'],
      subject: json['subject'] != null ? SubjectData.fromJson(json['subject']) : null,
    );
  }
}

class ClassData {
  final int? id;
  final String? name;

  ClassData({this.id, this.name});

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      id: json['id'],
      name: json['name']?.toString(),
    );
  }
}

class SectionData {
  final int? id;
  final String? name;

  SectionData({this.id, this.name});

  factory SectionData.fromJson(Map<String, dynamic> json) {
    return SectionData(
      id: json['id'],
      name: json['name']?.toString(),
    );
  }
}

class SubjectData {
  final int? id;
  final String? name;
  final String? code;

  SubjectData({this.id, this.name, this.code});

  factory SubjectData.fromJson(Map<String, dynamic> json) {
    return SubjectData(
      id: json['id'],
      name: json['name']?.toString(),
      code: json['code']?.toString(),
    );
  }
}

class TodayTomorrowDuty {
  final int? id;
  final String? examDate;
  final String? dayName;
  final String? formattedDate;
  final String? status;
  final String? timing;
  final String? session;
  final SeatingPlan? seatingPlan;
  final DateSheet? datesheet;
  final Room? room;
  final List<String>? classes;
  final List<dynamic>? coInvigilators;

  TodayTomorrowDuty({
    this.id,
    this.examDate,
    this.dayName,
    this.formattedDate,
    this.status,
    this.timing,
    this.session,
    this.seatingPlan,
    this.datesheet,
    this.room,
    this.classes,
    this.coInvigilators,
  });

  factory TodayTomorrowDuty.fromJson(Map<String, dynamic> json) {
    return TodayTomorrowDuty(
      id: json['id'],
      examDate: json['exam_date']?.toString(),
      dayName: json['day_name']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      status: json['status']?.toString(),
      timing: json['timing']?.toString(),
      session: json['session']?.toString(),
      seatingPlan: json['seating_plan'] != null
          ? SeatingPlan.fromJson(json['seating_plan'])
          : null,
      datesheet: json['datesheet'] != null
          ? DateSheet.fromJson(json['datesheet'])
          : null,
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
      classes: json['classes'] != null ? List<String>.from(json['classes']) : null,
      coInvigilators: json['co_invigilators'] != null
          ? List<dynamic>.from(json['co_invigilators'])
          : null,
    );
  }
}

class SeatingPlan {
  final int? id;
  final String? name;

  SeatingPlan({this.id, this.name});

  factory SeatingPlan.fromJson(Map<String, dynamic> json) {
    return SeatingPlan(
      id: json['id'],
      name: json['name']?.toString(),
    );
  }
}

class DateSheet {
  final int? id;
  final String? name;

  DateSheet({this.id, this.name});

  factory DateSheet.fromJson(Map<String, dynamic> json) {
    return DateSheet(
      id: json['id'],
      name: json['name']?.toString(),
    );
  }
}

class Room {
  final int? id;
  final String? name;
  final int? capacity;
  final int? studentCount;

  Room({this.id, this.name, this.capacity, this.studentCount});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name']?.toString(),
      capacity: json['capacity'],
      studentCount: json['student_count'],
    );
  }
}

class AttendanceSettings {
  final String? latitude;
  final String? longitude;
  final int? radius;
  final List<String>? weeklyOffDays;
  final String? workStartTime;
  final String? workEndTime;
  final String? allowClockInFrom;
  final String? lateOneQuarterTime;
  final String? lateOneThirdTime;
  final String? lateHalfDayTime;
  final String? lateFullDayTime;

  AttendanceSettings({
    this.latitude,
    this.longitude,
    this.radius,
    this.weeklyOffDays,
    this.workStartTime,
    this.workEndTime,
    this.allowClockInFrom,
    this.lateOneQuarterTime,
    this.lateOneThirdTime,
    this.lateHalfDayTime,
    this.lateFullDayTime,
  });

  factory AttendanceSettings.fromJson(Map<String, dynamic> json) {
    return AttendanceSettings(
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      radius: json['radius'],
      weeklyOffDays: json['weekly_off_days'] != null
          ? List<String>.from(json['weekly_off_days'])
          : null,
      workStartTime: json['work_start_time']?.toString(),
      workEndTime: json['work_end_time']?.toString(),
      allowClockInFrom: json['allow_clock_in_from']?.toString(),
      lateOneQuarterTime: json['late_one_quarter_time']?.toString(),
      lateOneThirdTime: json['late_one_third_time']?.toString(),
      lateHalfDayTime: json['late_half_day_time']?.toString(),
      lateFullDayTime: json['late_full_day_time']?.toString(),
    );
  }
}
