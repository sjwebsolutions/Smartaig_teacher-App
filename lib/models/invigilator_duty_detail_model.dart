class InvigilatorDutyDetailModel {
  bool? success;
  InvigilatorDutyDetailData? data;

  InvigilatorDutyDetailModel({this.success, this.data});

  InvigilatorDutyDetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? InvigilatorDutyDetailData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class InvigilatorDutyDetailData {
  SeatingPlan? seatingPlan;
  List<DutyDetail>? duties;

  InvigilatorDutyDetailData({this.seatingPlan, this.duties});

  InvigilatorDutyDetailData.fromJson(Map<String, dynamic> json) {
    seatingPlan = json['seating_plan'] != null
        ? SeatingPlan.fromJson(json['seating_plan'])
        : null;
    if (json['duties'] != null) {
      duties = <DutyDetail>[];
      json['duties'].forEach((v) {
        duties!.add(DutyDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (seatingPlan != null) {
      data['seating_plan'] = seatingPlan!.toJson();
    }
    if (duties != null) {
      data['duties'] = duties!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SeatingPlan {
  int? id;
  String? name;
  String? datesheetName;
  String? session;

  SeatingPlan({this.id, this.name, this.datesheetName, this.session});

  SeatingPlan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    datesheetName = json['datesheet_name'];
    session = json['session'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['datesheet_name'] = datesheetName;
    data['session'] = session;
    return data;
  }
}

class DutyDetail {
  int? id;
  String? examDate;
  String? dayName;
  String? formattedDate;
  String? status;
  String? timing;
  String? session;
  SeatingPlan? seatingPlan;
  DatesheetShort? datesheet;
  Room? room;
  List<String>? classes;
  List<dynamic>? coInvigilators;

  DutyDetail(
      {this.id,
      this.examDate,
      this.dayName,
      this.formattedDate,
      this.status,
      this.timing,
      this.session,
      this.seatingPlan,
      this.datesheet,
      this.room,
      this.classes,
      this.coInvigilators});

  DutyDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    examDate = json['exam_date'];
    dayName = json['day_name'];
    formattedDate = json['formatted_date'];
    status = json['status'];
    timing = json['timing'];
    session = json['session'];
    seatingPlan = json['seating_plan'] != null
        ? SeatingPlan.fromJson(json['seating_plan'])
        : null;
    datesheet = json['datesheet'] != null
        ? DatesheetShort.fromJson(json['datesheet'])
        : null;
    room = json['room'] != null ? Room.fromJson(json['room']) : null;
    classes = json['classes'].cast<String>();
    coInvigilators = json['co_invigilators'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['exam_date'] = examDate;
    data['day_name'] = dayName;
    data['formatted_date'] = formattedDate;
    data['status'] = status;
    data['timing'] = timing;
    data['session'] = session;
    if (seatingPlan != null) {
      data['seating_plan'] = seatingPlan!.toJson();
    }
    if (datesheet != null) {
      data['datesheet'] = datesheet!.toJson();
    }
    if (room != null) {
      data['room'] = room!.toJson();
    }
    data['classes'] = classes;
    data['co_invigilators'] = coInvigilators;
    return data;
  }
}

class DatesheetShort {
  int? id;
  String? name;

  DatesheetShort({this.id, this.name});

  DatesheetShort.fromJson(Map<String, dynamic> json) {
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

class Room {
  int? id;
  String? name;
  int? capacity;
  int? studentCount;

  Room({this.id, this.name, this.capacity, this.studentCount});

  Room.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    capacity = json['capacity'];
    studentCount = json['student_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['capacity'] = capacity;
    data['student_count'] = studentCount;
    return data;
  }
}
