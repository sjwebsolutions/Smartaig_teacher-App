class SyllabusModel {
  bool? success;
  String? message;
  List<SyllabusData>? data;

  SyllabusModel({this.success, this.message, this.data});

  SyllabusModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
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
    data['message'] = message;
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
  SyllabusInfo? term;
  SyllabusInfo? subject;
  String? content;
  String? fileUrl;
  List<Attachments>? attachments;
  String? targetAudience;
  List<Targets>? targets;
  int? status;
  String? uploadedBy;
  bool? isMyUpload;
  String? uploadedAt;
  String? updatedAt;

  SyllabusData(
      {this.id,
      this.title,
      this.description,
      this.session,
      this.term,
      this.subject,
      this.content,
      this.fileUrl,
      this.attachments,
      this.targetAudience,
      this.targets,
      this.status,
      this.uploadedBy,
      this.isMyUpload,
      this.uploadedAt,
      this.updatedAt});

  SyllabusData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    session = json['session'];
    term = json['term'] != null && json['term'] is Map<String, dynamic> 
        ? SyllabusInfo.fromJson(json['term']) 
        : null;
    subject = json['subject'] != null && json['subject'] is Map<String, dynamic> 
        ? SyllabusInfo.fromJson(json['subject']) 
        : null;
    content = json['content'];
    fileUrl = json['file_url'];
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
    targetAudience = json['target_audience'];
    if (json['targets'] != null) {
      targets = <Targets>[];
      json['targets'].forEach((v) {
        targets!.add(Targets.fromJson(v));
      });
    }
    status = json['status'];
    uploadedBy = json['uploaded_by'];
    isMyUpload = json['is_my_upload'];
    uploadedAt = json['uploaded_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['session'] = session;
    if (term != null) {
      data['term'] = term!.toJson();
    }
    if (subject != null) {
      data['subject'] = subject!.toJson();
    }
    data['content'] = content;
    data['file_url'] = fileUrl;
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    data['target_audience'] = targetAudience;
    if (targets != null) {
      data['targets'] = targets!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['uploaded_by'] = uploadedBy;
    data['is_my_upload'] = isMyUpload;
    data['uploaded_at'] = uploadedAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class SyllabusInfo {
  int? id;
  String? name;

  SyllabusInfo({this.id, this.name});

  SyllabusInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Attachments {
  String? path;
  String? url;
  String? name;
  String? ext;
  bool? isImage;
  String? title;

  Attachments(
      {this.path, this.url, this.name, this.ext, this.isImage, this.title});

  Attachments.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    url = json['url'];
    name = json['name'];
    ext = json['ext'];
    isImage = json['is_image'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['url'] = url;
    data['name'] = name;
    data['ext'] = ext;
    data['is_image'] = isImage;
    data['title'] = title;
    return data;
  }
}

class Targets {
  int? classId;
  String? className;
  int? streamId;
  String? streamName;
  List<dynamic>? sectionIds;
  List<dynamic>? sectionNames;

  Targets(
      {this.classId,
      this.className,
      this.streamId,
      this.streamName,
      this.sectionIds,
      this.sectionNames});

  Targets.fromJson(Map<String, dynamic> json) {
    classId = json['class_id'];
    className = json['class_name'];
    streamId = json['stream_id'];
    streamName = json['stream_name'];
    sectionIds = json['section_ids'] != null ? List<dynamic>.from(json['section_ids']) : null;
    sectionNames = json['section_names'] != null ? List<dynamic>.from(json['section_names']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class_id'] = classId;
    data['class_name'] = className;
    data['stream_id'] = streamId;
    data['stream_name'] = streamName;
    data['section_ids'] = sectionIds;
    data['section_names'] = sectionNames;
    return data;
  }
}
