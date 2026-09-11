class AdmitCardVerifyModel {
  bool? success;
  String? message;
  AdmitCardVerifyData? data;

  AdmitCardVerifyModel({this.success, this.message, this.data});

  AdmitCardVerifyModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AdmitCardVerifyData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AdmitCardVerifyData {
  StudentDetail? student;
  AdmitCardDetail? admitCard;
  List<DatesheetScheduleItem>? datesheetSchedule;
  SeatingPlanDetail? seatingPlan;
  FeeBalanceDetail? feeBalance;

  AdmitCardVerifyData({
    this.student,
    this.admitCard,
    this.datesheetSchedule,
    this.seatingPlan,
    this.feeBalance,
  });

  AdmitCardVerifyData.fromJson(Map<String, dynamic> json) {
    student = json['student'] != null ? StudentDetail.fromJson(json['student']) : null;
    admitCard = json['admit_card'] != null ? AdmitCardDetail.fromJson(json['admit_card']) : null;
    if (json['datesheet_schedule'] != null) {
      datesheetSchedule = <DatesheetScheduleItem>[];
      json['datesheet_schedule'].forEach((v) {
        datesheetSchedule!.add(DatesheetScheduleItem.fromJson(v));
      });
    }
    seatingPlan = json['seating_plan'] != null
        ? SeatingPlanDetail.fromJson(json['seating_plan'])
        : null;
    feeBalance = json['fee_balance'] != null
        ? FeeBalanceDetail.fromJson(json['fee_balance'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (student != null) {
      data['student'] = student!.toJson();
    }
    if (admitCard != null) {
      data['admit_card'] = admitCard!.toJson();
    }
    if (datesheetSchedule != null) {
      data['datesheet_schedule'] = datesheetSchedule!.map((v) => v.toJson()).toList();
    }
    if (seatingPlan != null) {
      data['seating_plan'] = seatingPlan!.toJson();
    }
    if (feeBalance != null) {
      data['fee_balance'] = feeBalance!.toJson();
    }
    return data;
  }
}

class StudentDetail {
  int? id;
  String? studentName;
  String? fatherName;
  String? motherName;
  String? admissionNumber;
  String? studentUniqueId;
  String? rollNo;
  String? examRollNo;
  String? dob;
  String? formattedDob;
  String? gender;
  String? studentClass;
  String? section;
  String? stream;
  String? session;
  String? classSection;
  String? photoUrl;
  String? fatherMobile;
  String? motherMobile;
  String? status;

  StudentDetail({
    this.id,
    this.studentName,
    this.fatherName,
    this.motherName,
    this.admissionNumber,
    this.studentUniqueId,
    this.rollNo,
    this.examRollNo,
    this.dob,
    this.formattedDob,
    this.gender,
    this.studentClass,
    this.section,
    this.stream,
    this.session,
    this.classSection,
    this.photoUrl,
    this.fatherMobile,
    this.motherMobile,
    this.status,
  });

  StudentDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    studentName = json['student_name'];
    fatherName = json['father_name'];
    motherName = json['mother_name'];
    admissionNumber = json['admission_number'];
    studentUniqueId = json['student_unique_id'];
    rollNo = json['roll_no'];
    examRollNo = json['exam_roll_no'];
    dob = json['dob'];
    formattedDob = json['formatted_dob'];
    gender = json['gender'];
    studentClass = json['class'];
    section = json['section'];
    stream = json['stream'];
    session = json['session'];
    classSection = json['class_section'];
    photoUrl = json['photo_url'];
    fatherMobile = json['father_mobile'];
    motherMobile = json['mother_mobile'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['student_name'] = studentName;
    data['father_name'] = fatherName;
    data['mother_name'] = motherName;
    data['admission_number'] = admissionNumber;
    data['student_unique_id'] = studentUniqueId;
    data['roll_no'] = rollNo;
    data['exam_roll_no'] = examRollNo;
    data['dob'] = dob;
    data['formatted_dob'] = formattedDob;
    data['gender'] = gender;
    data['class'] = studentClass;
    data['section'] = section;
    data['stream'] = stream;
    data['session'] = session;
    data['class_section'] = classSection;
    data['photo_url'] = photoUrl;
    data['father_mobile'] = fatherMobile;
    data['mother_mobile'] = motherMobile;
    data['status'] = status;
    return data;
  }
}

class AdmitCardDetail {
  int? id;
  int? dateSheetId;
  String? examTitle;
  String? session;
  String? examCenterCode;
  String? centerSchoolCode;
  String? examCenterName;
  String? startTime;
  String? endTime;
  String? examStartDate;
  String? examEndDate;

  AdmitCardDetail({
    this.id,
    this.dateSheetId,
    this.examTitle,
    this.session,
    this.examCenterCode,
    this.centerSchoolCode,
    this.examCenterName,
    this.startTime,
    this.endTime,
    this.examStartDate,
    this.examEndDate,
  });

  AdmitCardDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateSheetId = json['date_sheet_id'];
    examTitle = json['exam_title'];
    session = json['session'];
    examCenterCode = json['exam_center_code'];
    centerSchoolCode = json['center_school_code'];
    examCenterName = json['exam_center_name'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    examStartDate = json['exam_start_date'];
    examEndDate = json['exam_end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date_sheet_id'] = dateSheetId;
    data['exam_title'] = examTitle;
    data['session'] = session;
    data['exam_center_code'] = examCenterCode;
    data['center_school_code'] = centerSchoolCode;
    data['exam_center_name'] = examCenterName;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['exam_start_date'] = examStartDate;
    data['exam_end_date'] = examEndDate;
    return data;
  }
}

class DatesheetScheduleItem {
  int? id;
  String? examDate;
  String? formattedDate;
  String? day;
  String? subjectName;
  String? subjectCode;
  String? timing;
  String? type;

  DatesheetScheduleItem({
    this.id,
    this.examDate,
    this.formattedDate,
    this.day,
    this.subjectName,
    this.subjectCode,
    this.timing,
    this.type,
  });

  DatesheetScheduleItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    examDate = json['exam_date'];
    formattedDate = json['formatted_date'];
    day = json['day'];
    subjectName = json['subject_name'];
    subjectCode = json['subject_code'];
    timing = json['timing'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['exam_date'] = examDate;
    data['formatted_date'] = formattedDate;
    data['day'] = day;
    data['subject_name'] = subjectName;
    data['subject_code'] = subjectCode;
    data['timing'] = timing;
    data['type'] = type;
    return data;
  }
}

class SeatingPlanDetail {
  bool? isAssigned;
  String? status;
  int? totalExams;
  int? assignedExams;
  String? arrangementName;
  SeatItem? todaySeat;
  List<SeatItem>? allSeats;

  SeatingPlanDetail({
    this.isAssigned,
    this.status,
    this.totalExams,
    this.assignedExams,
    this.arrangementName,
    this.todaySeat,
    this.allSeats,
  });

  SeatingPlanDetail.fromJson(Map<String, dynamic> json) {
    isAssigned = json['is_assigned'];
    status = json['status'];
    totalExams = json['total_exams'];
    assignedExams = json['assigned_exams'];
    arrangementName = json['arrangement_name'];
    todaySeat = json['today_seat'] != null ? SeatItem.fromJson(json['today_seat']) : null;
    if (json['all_seats'] != null) {
      allSeats = <SeatItem>[];
      json['all_seats'].forEach((v) {
        allSeats!.add(SeatItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_assigned'] = isAssigned;
    data['status'] = status;
    data['total_exams'] = totalExams;
    data['assigned_exams'] = assignedExams;
    data['arrangement_name'] = arrangementName;
    if (todaySeat != null) {
      data['today_seat'] = todaySeat!.toJson();
    }
    if (allSeats != null) {
      data['all_seats'] = allSeats!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SeatItem {
  String? examDate;
  String? formattedDate;
  String? day;
  String? subject;
  bool? isAssigned;
  int? roomId;
  String? roomName;
  int? rowNo;
  int? deskNo;
  int? seatPosition;
  String? seatPositionLabel;
  String? seatLabel;
  String? message;
  bool? hasExamToday;

  SeatItem({
    this.examDate,
    this.formattedDate,
    this.day,
    this.subject,
    this.isAssigned,
    this.roomId,
    this.roomName,
    this.rowNo,
    this.deskNo,
    this.seatPosition,
    this.seatPositionLabel,
    this.seatLabel,
    this.message,
    this.hasExamToday,
  });

  SeatItem.fromJson(Map<String, dynamic> json) {
    examDate = json['exam_date'];
    formattedDate = json['formatted_date'];
    day = json['day'];
    subject = json['subject'];
    isAssigned = json['is_assigned'];
    roomId = json['room_id'];
    roomName = json['room_name'];
    rowNo = json['row_no'];
    deskNo = json['desk_no'];
    seatPosition = json['seat_position'];
    seatPositionLabel = json['seat_position_label'];
    seatLabel = json['seat_label'];
    message = json['message'];
    hasExamToday = json['has_exam_today'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exam_date'] = examDate;
    data['formatted_date'] = formattedDate;
    data['day'] = day;
    data['subject'] = subject;
    data['is_assigned'] = isAssigned;
    data['room_id'] = roomId;
    data['room_name'] = roomName;
    data['row_no'] = rowNo;
    data['desk_no'] = deskNo;
    data['seat_position'] = seatPosition;
    data['seat_position_label'] = seatPositionLabel;
    data['seat_label'] = seatLabel;
    data['message'] = message;
    data['has_exam_today'] = hasExamToday;
    return data;
  }
}

class FeeBalanceDetail {
  bool? hasDue;
  String? status;
  dynamic balanceTillToday;
  String? formattedBalance;
  String? message;

  FeeBalanceDetail({
    this.hasDue,
    this.status,
    this.balanceTillToday,
    this.formattedBalance,
    this.message,
  });

  FeeBalanceDetail.fromJson(Map<String, dynamic> json) {
    hasDue = json['has_due'];
    status = json['status'];
    balanceTillToday = json['balance_till_today'];
    formattedBalance = json['formatted_balance'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['has_due'] = hasDue;
    data['status'] = status;
    data['balance_till_today'] = balanceTillToday;
    data['formatted_balance'] = formattedBalance;
    data['message'] = message;
    return data;
  }
}
