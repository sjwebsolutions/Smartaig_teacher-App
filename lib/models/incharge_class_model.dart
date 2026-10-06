class InchargeClassModel {
  bool? success;
  String? message;
  List<InchargeClassData>? data;

  InchargeClassModel({this.success, this.message, this.data});

  factory InchargeClassModel.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'];
    return InchargeClassModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: dataList is List
          ? dataList.map((i) => InchargeClassData.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class InchargeClassData {
  int? classId;
  String? className;
  int? sectionId;
  String? sectionName;
  int? streamId;
  String? streamName;
  String? displayName;

  InchargeClassData({
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.streamId,
    this.streamName,
    this.displayName,
  });

  factory InchargeClassData.fromJson(Map<String, dynamic> json) {
    final cName = json['class_name']?.toString();
    final sName = json['section_name']?.toString();
    String? dispName = json['display_name']?.toString();
    if ((dispName == null || dispName.isEmpty) && cName != null && sName != null) {
      dispName = "$cName - $sName";
    }

    return InchargeClassData(
      classId: json['class_id'] is int
          ? json['class_id']
          : int.tryParse(json['class_id']?.toString() ?? ''),
      className: cName,
      sectionId: json['section_id'] is int
          ? json['section_id']
          : int.tryParse(json['section_id']?.toString() ?? ''),
      sectionName: sName,
      streamId: json['stream_id'] is int
          ? json['stream_id']
          : int.tryParse(json['stream_id']?.toString() ?? ''),
      streamName: json['stream_name']?.toString(),
      displayName: dispName,
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
    };
  }
}
