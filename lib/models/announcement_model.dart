class AnnouncementModel {
  bool? success;
  List<AnnouncementData>? data;

  AnnouncementModel({this.success, this.data});

  AnnouncementModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <AnnouncementData>[];
      json['data'].forEach((v) {
        data!.add(AnnouncementData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class AnnouncementData {
  int? id;
  String? title;
  String? description;
  String? imageUrl;
  String? type;
  String? fromDate;
  String? fromTime;
  String? toDate;
  String? toTime;
  String? createdBy;

  AnnouncementData({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.type,
    this.fromDate,
    this.fromTime,
    this.toDate,
    this.toTime,
    this.createdBy,
  });

  AnnouncementData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    imageUrl = json['image_url'];
    type = json['type'];
    fromDate = json['from_date'];
    fromTime = json['from_time'];
    toDate = json['to_date'];
    toTime = json['to_time'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image_url'] = imageUrl;
    data['type'] = type;
    data['from_date'] = fromDate;
    data['from_time'] = fromTime;
    data['to_date'] = toDate;
    data['to_time'] = toTime;
    data['created_by'] = createdBy;
    return data;
  }
}
