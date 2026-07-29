class HomeworkResponseModel {
  final bool? success;
  final String? message;
  final HomeworkData? data;

  HomeworkResponseModel({this.success, this.message, this.data});

  factory HomeworkResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeworkResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? HomeworkData.fromJson(json['data']) : null,
    );
  }
}

class HomeworkListResponseModel {
  final bool? success;
  final String? message;
  final List<HomeworkData>? data;

  HomeworkListResponseModel({this.success, this.message, this.data});

  factory HomeworkListResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeworkListResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => HomeworkData.fromJson(i)).toList()
          : null,
    );
  }
}

class HomeworkData {
  final int? id;
  final String? groupId;
  final String? classId;
  final String? className;
  final String? sectionId;
  final String? sectionName;
  final String? streamId;
  final String? streamName;
  final int? subjectId;
  final String? subjectName;
  final String? date;
  final String? content;
  final bool? isDiary;
  final List<dynamic>? attachments;
  final String? groupSections;
  final String? createdBy;
  final bool? isEditable;
  final String? createdAt;

  HomeworkData({
    this.id,
    this.groupId,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.streamId,
    this.streamName,
    this.subjectId,
    this.subjectName,
    this.date,
    this.content,
    this.isDiary,
    this.attachments,
    this.groupSections,
    this.createdBy,
    this.isEditable,
    this.createdAt,
  });

  factory HomeworkData.fromJson(Map<String, dynamic> json) {
    return HomeworkData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      groupId: json['group_id']?.toString(),
      classId: json['class_id']?.toString(),
      className: json['class_name'],
      sectionId: json['section_id']?.toString(),
      sectionName: json['section_name'],
      streamId: json['stream_id']?.toString(),
      streamName: json['stream_name'],
      subjectId: json['subject_id'] is int ? json['subject_id'] : int.tryParse(json['subject_id']?.toString() ?? ''),
      subjectName: json['subject_name'],
      date: json['date'],
      content: json['content'],
      isDiary: json['is_diary'] == true || json['is_diary'] == 1 || json['is_diary'] == '1',
      attachments: json['attachments'],
      groupSections: json['group_sections']?.toString(),
      createdBy: json['created_by'],
      isEditable: json['is_editable'] == true || json['is_editable'] == 1 || json['is_editable'] == '1',
      createdAt: json['created_at'],
    );
  }
}
