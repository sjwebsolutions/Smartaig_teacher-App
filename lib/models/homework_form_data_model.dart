class HomeworkFormDataModel {
  final bool? success;
  final List<HomeworkClassData>? data;

  HomeworkFormDataModel({this.success, this.data});

  factory HomeworkFormDataModel.fromJson(Map<String, dynamic> json) {
    return HomeworkFormDataModel(
      success: json['success'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => HomeworkClassData.fromJson(i)).toList()
          : null,
    );
  }
}

class HomeworkClassData {
  final String? classId;
  final String? className;
  final String? sectionId;
  final String? sectionName;
  final String? streamId;
  final String? streamName;
  final int? subjectId;
  final String? subjectName;
  final String? type;

  HomeworkClassData({
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.streamId,
    this.streamName,
    this.subjectId,
    this.subjectName,
    this.type,
  });

  factory HomeworkClassData.fromJson(Map<String, dynamic> json) {
    return HomeworkClassData(
      classId: json['class_id']?.toString(),
      className: json['class_name'],
      sectionId: json['section_id']?.toString(),
      sectionName: json['section_name'],
      streamId: json['stream_id']?.toString(),
      streamName: json['stream_name'],
      subjectId: json['subject_id'] is int ? json['subject_id'] : int.tryParse(json['subject_id']?.toString() ?? ''),
      subjectName: json['subject_name'],
      type: json['type'],
    );
  }

  String get displayName => "$className - $sectionName ($subjectName)";
}
