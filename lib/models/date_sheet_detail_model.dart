import 'date_sheet_model.dart';

class DateSheetDetailModel {
  bool? success;
  DateSheetDetailWrapper? data;

  DateSheetDetailModel({this.success, this.data});

  DateSheetDetailModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? DateSheetDetailWrapper.fromJson(json['data']) : null;
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

class DateSheetDetailWrapper {
  DateSheetData? datesheet;
  List<DateSheetDetailEntry>? entries;

  DateSheetDetailWrapper({this.datesheet, this.entries});

  DateSheetDetailWrapper.fromJson(Map<String, dynamic> json) {
    datesheet = json['datesheet'] != null ? DateSheetData.fromJson(json['datesheet']) : null;
    if (json['entries'] != null) {
      entries = <DateSheetDetailEntry>[];
      json['entries'].forEach((v) {
        entries!.add(DateSheetDetailEntry.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (datesheet != null) {
      data['datesheet'] = datesheet!.toJson();
    }
    if (entries != null) {
      data['entries'] = entries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DateSheetDetailEntry {
  int? id;
  String? className;
  String? streamName;
  String? subjectName;
  String? examDate;
  String? examType;
  String? displayLabel;

  DateSheetDetailEntry({
    this.id,
    this.className,
    this.streamName,
    this.subjectName,
    this.examDate,
    this.examType,
    this.displayLabel,
  });

  DateSheetDetailEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    className = json['class_name'];
    streamName = json['stream_name'];
    subjectName = json['subject_name'];
    examDate = json['exam_date'];
    examType = json['exam_type'];
    displayLabel = json['display_label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['class_name'] = className;
    data['stream_name'] = streamName;
    data['subject_name'] = subjectName;
    data['exam_date'] = examDate;
    data['exam_type'] = examType;
    data['display_label'] = displayLabel;
    return data;
  }
}
