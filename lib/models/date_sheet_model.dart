class DateSheetModel {
  bool? success;
  List<DateSheetData>? data;

  DateSheetModel({this.success, this.data});

  DateSheetModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <DateSheetData>[];
      json['data'].forEach((v) {
        data!.add(DateSheetData.fromJson(v));
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

class DateSheetData {
  int? id;
  String? name;
  String? startDate;
  String? endDate;
  String? instruction;

  DateSheetData(
      {this.id, this.name, this.startDate, this.endDate, this.instruction});

  DateSheetData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    instruction = json['instruction'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['instruction'] = instruction;
    return data;
  }
}
