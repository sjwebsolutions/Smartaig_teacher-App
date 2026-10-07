class ClassListModel {
  bool? success;
  List<ClassData>? data;

  ClassListModel({this.success, this.data});

  factory ClassListModel.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'];
    return ClassListModel(
      success: json['success'] as bool?,
      data: dataList is List
          ? dataList.map((i) => ClassData.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class ClassData {
  String? classId;
  String? className;
  String? sectionId;
  String? sectionName;
  String? streamId;
  String? streamName;
  String? displayName;
  int? totalStudents;
  String? marked;
  String? present;
  String? absent;
  String? leave;
  String? halfDay;
  int? pending;
  String? lastUpdated;

  ClassData({
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.streamId,
    this.streamName,
    this.displayName,
    this.totalStudents,
    this.marked,
    this.present,
    this.absent,
    this.leave,
    this.halfDay,
    this.pending,
    this.lastUpdated,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    final cName = json['class_name']?.toString();
    final sName = json['section_name']?.toString();
    String? dispName = json['display_name']?.toString();
    if ((dispName == null || dispName.isEmpty) && cName != null && sName != null) {
      dispName = "$cName - $sName";
    }

    return ClassData(
      classId: json['class_id']?.toString(),
      className: cName,
      sectionId: json['section_id']?.toString(),
      sectionName: sName,
      streamId: json['stream_id']?.toString(),
      streamName: json['stream_name']?.toString(),
      displayName: dispName,
      totalStudents: json['total_students'] is int
          ? json['total_students']
          : int.tryParse(json['total_students']?.toString() ?? ''),
      marked: json['marked']?.toString(),
      present: json['present']?.toString(),
      absent: json['absent']?.toString(),
      leave: json['leave']?.toString(),
      halfDay: json['half_day']?.toString(),
      pending: json['pending'] is int
          ? json['pending']
          : int.tryParse(json['pending']?.toString() ?? ''),
      lastUpdated: json['last_updated']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'section_id': sectionId,
      'section_name': sectionName,
      'stream_id': streamId,
      'stream_name': streamName,
      'display_name': displayName,
      'total_students': totalStudents,
      'marked': marked,
      'present': present,
      'absent': absent,
      'leave': leave,
      'half_day': halfDay,
      'pending': pending,
      'last_updated': lastUpdated,
    };
  }
}
