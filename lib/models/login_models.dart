class LoginModel {
  bool? success;
  String? message;
  LoginData? data;

  LoginModel({
    this.success,
    this.message,
    this.data,
  });

  LoginModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? LoginData.fromJson(json['data'])
        : null;
  }
}

class LoginData {
  String? token;
  String? activeSession;
  Teacher? teacher;

  LoginData({
    this.token,
    this.activeSession,
    this.teacher,
  });

  LoginData.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    activeSession = json['active_session'];
    teacher = json['teacher'] != null
        ? Teacher.fromJson(json['teacher'])
        : null;
  }
}

class Teacher {
  int? id;
  String? name;
  String? staffType;
  String? whatsappNumber;
  String? phone;
  String? email;
  String? schoolId;
  String? teacherUniqueId;
  String? gender;
  String? status;
  String? dob;
  String? address;
  String? district;
  String? state;
  String? pincode;
  String? experience;

  Teacher({
    this.id,
    this.name,
    this.staffType,
    this.whatsappNumber,
    this.phone,
    this.email,
    this.schoolId,
    this.teacherUniqueId,
    this.gender,
    this.status,
    this.dob,
    this.address,
    this.district,
    this.state,
    this.pincode,
    this.experience,
  });

  Teacher.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    staffType = json['staff_type'];
    whatsappNumber = json['whatsapp_number'];
    phone = json['phone'];
    email = json['email'];
    schoolId = json['school_id']?.toString();
    teacherUniqueId = json['teacher_unique_id'];
    gender = json['gender'];
    status = json['status'];
    dob = json['dob'];
    address = json['address'];
    district = json['district'];
    state = json['state'];
    pincode = json['pincode'];
    experience = json['experience'];
  }
}