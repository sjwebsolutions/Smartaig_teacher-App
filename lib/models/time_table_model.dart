class TimeTableModel {
  final bool success;
  final TimeTableData? data;

  TimeTableModel({
    required this.success,
    this.data,
  });

  factory TimeTableModel.fromJson(Map<String, dynamic> json) {
    return TimeTableModel(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? TimeTableData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class TimeTableData {
  final Teacher? teacher;
  final String? selectedDate;
  final String? selectedDay;
  final List<TimeTablePeriod> dailySchedule;
  final Map<String, List<TimeTablePeriod>> weeklySchedule;

  TimeTableData({
    this.teacher,
    this.selectedDate,
    this.selectedDay,
    this.dailySchedule = const [],
    this.weeklySchedule = const {},
  });

  factory TimeTableData.fromJson(Map<String, dynamic> json) {
    return TimeTableData(
      teacher: json['teacher'] != null
          ? Teacher.fromJson(json['teacher'])
          : null,
      selectedDate: json['selected_date'],
      selectedDay: json['selected_day'],
      dailySchedule: (json['daily_schedule'] as List?)
          ?.map((e) => TimeTablePeriod.fromJson(e))
          .toList() ??
          [],
      weeklySchedule: (json['weekly_schedule'] as Map<String, dynamic>?)
          ?.map(
            (key, value) => MapEntry(
          key,
          (value as List)
              .map((e) => TimeTablePeriod.fromJson(e))
              .toList(),
        ),
      ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher': teacher?.toJson(),
      'selected_date': selectedDate,
      'selected_day': selectedDay,
      'daily_schedule':
      dailySchedule.map((e) => e.toJson()).toList(),
      'weekly_schedule': weeklySchedule.map(
            (key, value) => MapEntry(
          key,
          value.map((e) => e.toJson()).toList(),
        ),
      ),
    };
  }
}

class Teacher {
  final int? id;
  final String? name;

  Teacher({
    this.id,
    this.name,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TimeTablePeriod {
  final int? periodId;
  final String? periodName;
  final String? startTime;
  final String? endTime;
  final String? type;
  final List<Lecture> lectures;

  TimeTablePeriod({
    this.periodId,
    this.periodName,
    this.startTime,
    this.endTime,
    this.type,
    this.lectures = const [],
  });

  factory TimeTablePeriod.fromJson(Map<String, dynamic> json) {
    return TimeTablePeriod(
      periodId: json['period_id'],
      periodName: json['period_name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      type: json['type'],
      lectures: (json['lectures'] as List?)
          ?.map((e) => Lecture.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period_id': periodId,
      'period_name': periodName,
      'start_time': startTime,
      'end_time': endTime,
      'type': type,
      'lectures': lectures.map((e) => e.toJson()).toList(),
    };
  }
}

class Lecture {
  final String? type;
  final int? timetableScheduleId;
  final ClassInfo? classInfo;
  final dynamic section;
  final dynamic stream;
  final List<Subject> subjects;
  final bool isSubstitutedOut;
  final dynamic proxyDetails;

  Lecture({
    this.type,
    this.timetableScheduleId,
    this.classInfo,
    this.section,
    this.stream,
    this.subjects = const [],
    this.isSubstitutedOut = false,
    this.proxyDetails,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      type: json['type'],
      timetableScheduleId: json['timetable_schedule_id'],
      classInfo: json['class'] != null
          ? ClassInfo.fromJson(json['class'])
          : null,
      section: json['section'],
      stream: json['stream'],
      subjects: (json['subjects'] as List?)
          ?.map((e) => Subject.fromJson(e))
          .toList() ??
          [],
      isSubstitutedOut: json['is_substituted_out'] ?? false,
      proxyDetails: json['proxy_details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timetable_schedule_id': timetableScheduleId,
      'class': classInfo?.toJson(),
      'section': section,
      'stream': stream,
      'subjects': subjects.map((e) => e.toJson()).toList(),
      'is_substituted_out': isSubstitutedOut,
      'proxy_details': proxyDetails,
    };
  }
}

class ClassInfo {
  final int? id;
  final String? name;

  ClassInfo({
    this.id,
    this.name,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Subject {
  final int? id;
  final String? name;
  final String? code;

  Subject({
    this.id,
    this.name,
    this.code,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}