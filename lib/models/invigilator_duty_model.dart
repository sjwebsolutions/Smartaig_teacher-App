class InvigilatorDutyModel {
  bool? success;
  List<InvigilatorDutyData>? data;

  InvigilatorDutyModel({this.success, this.data});

  InvigilatorDutyModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <InvigilatorDutyData>[];
      json['data'].forEach((v) {
        data!.add(InvigilatorDutyData.fromJson(v));
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

class InvigilatorDutyData {
  int? id;
  String? name;
  Datesheet? datesheet;
  String? session;
  String? status;
  int? totalDuties;
  int? upcomingDuties;
  int? completedDuties;
  String? firstDutyDate;
  String? lastDutyDate;

  InvigilatorDutyData(
      {this.id,
      this.name,
      this.datesheet,
      this.session,
      this.status,
      this.totalDuties,
      this.upcomingDuties,
      this.completedDuties,
      this.firstDutyDate,
      this.lastDutyDate});

  InvigilatorDutyData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    datesheet = json['datesheet'] != null
        ? Datesheet.fromJson(json['datesheet'])
        : null;
    session = json['session'];
    status = json['status'];
    totalDuties = json['total_duties'];
    upcomingDuties = json['upcoming_duties'];
    completedDuties = json['completed_duties'];
    firstDutyDate = json['first_duty_date'];
    lastDutyDate = json['last_duty_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (datesheet != null) {
      data['datesheet'] = datesheet!.toJson();
    }
    data['session'] = session;
    data['status'] = status;
    data['total_duties'] = totalDuties;
    data['upcoming_duties'] = upcomingDuties;
    data['completed_duties'] = completedDuties;
    data['first_duty_date'] = firstDutyDate;
    data['last_duty_date'] = lastDutyDate;
    return data;
  }
}

class Datesheet {
  int? id;
  String? name;

  Datesheet({this.id, this.name});

  Datesheet.fromJson(Map<String, dynamic> json) {
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
