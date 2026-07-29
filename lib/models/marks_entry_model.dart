class MarksEntryResponse {
  bool? success;
  List<MarksEntryData>? data;

  MarksEntryResponse({this.success, this.data});

  MarksEntryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <MarksEntryData>[];
      json['data'].forEach((v) {
        data!.add(MarksEntryData.fromJson(v));
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

class MarksEntryData {
  int? id;
  String? datesheetName;
  String? session;
  String? teacherDisplayUntil;

  MarksEntryData(
      {this.id, this.datesheetName, this.session, this.teacherDisplayUntil});

  MarksEntryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    datesheetName = json['datesheet_name'];
    session = json['session'];
    teacherDisplayUntil = json['teacher_display_until'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['datesheet_name'] = datesheetName;
    data['session'] = session;
    data['teacher_display_until'] = teacherDisplayUntil;
    return data;
  }
}
