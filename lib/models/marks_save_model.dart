
class MarksSaveRequest {
  int? marksEntryId;
  int? classId;
  int? sectionId;
  int? streamId;
  List<MarksEntry>? entries;

  MarksSaveRequest(
      {this.marksEntryId,
      this.classId,
      this.sectionId,
      this.streamId,
      this.entries});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['marks_entry_id'] = marksEntryId;
    data['class_id'] = classId;
    data['section_id'] = sectionId;
    if (streamId != null) {
      data['stream_id'] = streamId;
    }
    if (entries != null) {
      data['entries'] = entries!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MarksEntry {
  int? studentId;
  int? subjectId;
  bool? isMisc;
  String? attendance;
  dynamic wMarks;
  dynamic oMarks;
  dynamic aMarks;
  dynamic bMarks;
  dynamic assMarks;
  dynamic pMarks;
  dynamic tMarks;
  String? gGrade;
  String? remarks;

  MarksEntry(
      {this.studentId,
      this.subjectId,
      this.isMisc,
      this.attendance,
      this.wMarks,
      this.oMarks,
      this.aMarks,
      this.bMarks,
      this.assMarks,
      this.pMarks,
      this.tMarks,
      this.gGrade,
      this.remarks});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['student_id'] = studentId;
    data['subject_id'] = subjectId;
    data['is_misc'] = isMisc;
    data['attendance'] = attendance;
    data['w_marks'] = wMarks;
    data['o_marks'] = oMarks;
    data['a_marks'] = aMarks;
    data['b_marks'] = bMarks;
    data['ass_marks'] = assMarks;
    data['p_marks'] = pMarks;
    data['t_marks'] = tMarks;
    data['g_grade'] = gGrade;
    data['remarks'] = remarks;
    return data;
  }
}
