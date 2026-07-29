class ClassListModel {
  bool? success;
  List<ClassData>? data;

  ClassListModel({this.success, this.data});

  factory ClassListModel.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'];
    return ClassListModel(
      success: json['success'],
      data: dataList is List
          ? dataList.map((i) => ClassData.fromJson(i)).toList()
          : null,
    );
  }
}

class ClassData {
  String? classId;
  String? className;
  String? sectionId;
  String? sectionName;
  String? streamId;
  String? streamName;
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
    return ClassData(
      classId: json['class_id']?.toString(),
      className: json['class_name'],
      sectionId: json['section_id']?.toString(),
      sectionName: json['section_name'],
      streamId: json['stream_id']?.toString(),
      streamName: json['stream_name'],
      totalStudents: json['total_students'],
      marked: json['marked']?.toString(),
      present: json['present']?.toString(),
      absent: json['absent']?.toString(),
      leave: json['leave']?.toString(),
      halfDay: json['half_day']?.toString(),
      pending: json['pending'],
      lastUpdated: json['last_updated'],
    );
  }
}
