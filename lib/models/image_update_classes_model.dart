class ImageUpdateClassesModel {
  bool? success;
  List<ImageUpdateClassData>? data;

  ImageUpdateClassesModel({this.success, this.data});

  ImageUpdateClassesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <ImageUpdateClassData>[];
      json['data'].forEach((v) {
        data!.add(ImageUpdateClassData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageUpdateClassData {
  int? classId;
  String? className;
  int? sectionId;
  String? sectionName;
  int? streamId;
  String? streamName;

  ImageUpdateClassData(
      {this.classId,
      this.className,
      this.sectionId,
      this.sectionName,
      this.streamId,
      this.streamName});

  ImageUpdateClassData.fromJson(Map<String, dynamic> json) {
    classId = json['class_id'];
    className = json['class_name'];
    sectionId = json['section_id'];
    sectionName = json['section_name'];
    streamId = json['stream_id'];
    streamName = json['stream_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class_id'] = classId;
    data['class_name'] = className;
    data['section_id'] = sectionId;
    data['section_name'] = sectionName;
    data['stream_id'] = streamId;
    data['stream_name'] = streamName;
    return data;
  }
}
