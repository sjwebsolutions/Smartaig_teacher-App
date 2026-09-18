class ImageUpdateStoreRequest {
  int studentId;
  String? profileImage;
  String? fatherImage;
  String? motherImage;
  String? fatherMobile;
  String? motherMobile;
  String? studentMobile;
  String? bloodGroup;
  String? rollNo;
  String? studentHeight;
  String? studentWeight;
  String? currentAddress;
  String? permanentAddress;
  String? district;
  String? state;
  String? pincode;
  String? fatherQualification;
  String? motherQualification;
  String? studentName;
  String? studentNamePunjabi;
  String? fatherName;
  String? fatherNamePunjabi;
  String? motherName;
  String? motherNamePunjabi;

  ImageUpdateStoreRequest({
    required this.studentId,
    this.profileImage,
    this.fatherImage,
    this.motherImage,
    this.fatherMobile,
    this.motherMobile,
    this.studentMobile,
    this.bloodGroup,
    this.rollNo,
    this.studentHeight,
    this.studentWeight,
    this.currentAddress,
    this.permanentAddress,
    this.district,
    this.state,
    this.pincode,
    this.fatherQualification,
    this.motherQualification,
    this.studentName,
    this.studentNamePunjabi,
    this.fatherName,
    this.fatherNamePunjabi,
    this.motherName,
    this.motherNamePunjabi,
  });

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      if (fatherMobile != null) 'father_mobile': fatherMobile,
      if (motherMobile != null) 'mother_mobile': motherMobile,
      if (studentMobile != null) 'student_mobile': studentMobile,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (rollNo != null) 'roll_no': rollNo,
      if (studentHeight != null) 'student_height': studentHeight,
      if (studentWeight != null) 'student_weight': studentWeight,
      if (currentAddress != null) 'current_address': currentAddress,
      if (permanentAddress != null) 'permanent_address': permanentAddress,
      if (district != null) 'district': district,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (fatherQualification != null) 'father_qualification': fatherQualification,
      if (motherQualification != null) 'mother_qualification': motherQualification,
      if (studentName != null) 'student_name': studentName,
      if (studentNamePunjabi != null) 'student_name_punjabi': studentNamePunjabi,
      if (fatherName != null) 'father_name': fatherName,
      if (fatherNamePunjabi != null) 'father_name_punjabi': fatherNamePunjabi,
      if (motherName != null) 'mother_name': motherName,
      if (motherNamePunjabi != null) 'mother_name_punjabi': motherNamePunjabi,
    };
  }
}

class ImageUpdateStoreResponse {
  bool? success;
  String? message;

  ImageUpdateStoreResponse({this.success, this.message});

  ImageUpdateStoreResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
  }
}
