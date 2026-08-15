class SyllabusModel {
  bool? success;
  List<SyllabusData>? data;

  SyllabusModel({this.success, this.data});

  SyllabusModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <SyllabusData>[];
      if (json['data'] is List) {
        for (var v in json['data']) {
          data!.add(SyllabusData.fromJson(v));
        }
      } else if (json['data'] is Map<String, dynamic>) {
        data!.add(SyllabusData.fromJson(json['data']));
      }
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

class SyllabusData {
  int? id;
  String? title;
  String? description;
  String? session;
  String? fileUrl;
  String? targetAudience;
  String? uploadedAt;

  SyllabusData(
      {this.id,
      this.title,
      this.description,
      this.session,
      this.fileUrl,
      this.targetAudience,
      this.uploadedAt});

  SyllabusData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    session = json['session'];
    fileUrl = json['file_url'];
    targetAudience = json['target_audience'];
    uploadedAt = json['uploaded_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['session'] = session;
    data['file_url'] = fileUrl;
    data['target_audience'] = targetAudience;
    data['uploaded_at'] = uploadedAt;
    return data;
  }
}
