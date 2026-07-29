class MarksEntryClassesResponse {
  bool? success;
  List<MarksEntryClassData>? data;

  MarksEntryClassesResponse({this.success, this.data});

  MarksEntryClassesResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <MarksEntryClassData>[];
      json['data'].forEach((v) {
        data!.add(MarksEntryClassData.fromJson(v));
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

class MarksEntryClassData {
  String? classId;
  String? className;
  String? sectionId;
  String? sectionName;
  String? streamId;
  String? streamName;
  bool? isLocked;
  int? totalStudents;
  int? added;
  int? pending;

  MarksEntryClassData(
      {this.classId,
      this.className,
      this.sectionId,
      this.sectionName,
      this.streamId,
      this.streamName,
      this.isLocked,
      this.totalStudents,
      this.added,
      this.pending});

  MarksEntryClassData.fromJson(Map<String, dynamic> json) {
    classId = json['class_id']?.toString();
    className = json['class_name']?.toString();
    sectionId = json['section_id']?.toString();
    sectionName = json['section_name']?.toString();
    streamId = json['stream_id']?.toString();
    streamName = json['stream_name']?.toString();
    isLocked = json['is_locked'] == true || json['is_locked'] == 1 || json['is_locked'] == '1' || json['is_locked'] == 'true';
    totalStudents = json['total_students'] != null ? int.tryParse(json['total_students'].toString()) : null;
    added = json['added'] != null ? int.tryParse(json['added'].toString()) : (json['marked'] != null ? int.tryParse(json['marked'].toString()) : null);
    pending = json['pending'] != null ? int.tryParse(json['pending'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class_id'] = classId;
    data['class_name'] = className;
    data['section_id'] = sectionId;
    data['section_name'] = sectionName;
    data['stream_id'] = streamId;
    data['stream_name'] = streamName;
    data['is_locked'] = isLocked;
    data['total_students'] = totalStudents;
    data['added'] = added;
    data['pending'] = pending;
    return data;
  }
}
