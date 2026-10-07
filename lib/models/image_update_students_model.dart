class ImageUpdateStudentsModel {
  bool? success;
  List<ImageUpdateStudentData>? data;

  ImageUpdateStudentsModel({this.success, this.data});

  ImageUpdateStudentsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <ImageUpdateStudentData>[];
      json['data'].forEach((v) {
        data!.add(ImageUpdateStudentData.fromJson(v));
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

class ImageUpdateStudentData {
  int? id;
  String? studentName;
  String? studentNamePunjabi;
  String? studentUniqueId;
  String? rollNo;
  String? bloodGroup;
  num? studentHeight;
  num? studentWeight;
  String? studentMobile;
  String? currentProfileImage;
  bool? isProfileImageUploaded;
  bool? isFatherImageUploaded;
  bool? isMotherImageUploaded;
  String? fatherName;
  String? fatherNamePunjabi;
  String? motherName;
  String? motherNamePunjabi;
  String? fatherMobile;
  String? motherMobile;
  String? fatherQualification;
  String? motherQualification;
  String? currentAddress;
  String? permanentAddress;
  String? district;
  String? state;
  String? pincode;
  bool? hasPendingRequest;
  PendingRequestDetails? pendingRequestDetails;

  ImageUpdateStudentData({
    this.id,
    this.studentName,
    this.studentNamePunjabi,
    this.studentUniqueId,
    this.rollNo,
    this.bloodGroup,
    this.studentHeight,
    this.studentWeight,
    this.studentMobile,
    this.currentProfileImage,
    this.isProfileImageUploaded,
    this.isFatherImageUploaded,
    this.isMotherImageUploaded,
    this.fatherName,
    this.fatherNamePunjabi,
    this.motherName,
    this.motherNamePunjabi,
    this.fatherMobile,
    this.motherMobile,
    this.fatherQualification,
    this.motherQualification,
    this.currentAddress,
    this.permanentAddress,
    this.district,
    this.state,
    this.pincode,
    this.hasPendingRequest,
    this.pendingRequestDetails,
  });

  ImageUpdateStudentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    studentName = json['student_name'];
    studentNamePunjabi = json['student_name_punjabi'];
    studentUniqueId = json['student_unique_id'];
    rollNo = json['roll_no'];
    bloodGroup = json['blood_group'];
    studentHeight = json['student_height'];
    studentWeight = json['student_weight'];
    studentMobile = json['student_mobile'];
    currentProfileImage = json['current_profile_image'];
    isProfileImageUploaded = json['is_profile_image_uploaded'];
    isFatherImageUploaded = json['is_father_image_uploaded'];
    isMotherImageUploaded = json['is_mother_image_uploaded'];
    fatherName = json['father_name'];
    fatherNamePunjabi = json['father_name_punjabi'];
    motherName = json['mother_name'];
    motherNamePunjabi = json['mother_name_punjabi'];
    fatherMobile = json['father_mobile'];
    motherMobile = json['mother_mobile'];
    fatherQualification = json['father_qualification'];
    motherQualification = json['mother_qualification'];
    currentAddress = json['current_address'];
    permanentAddress = json['permanent_address'];
    district = json['district'];
    state = json['state'];
    pincode = json['pincode'];
    hasPendingRequest = json['has_pending_request'];
    pendingRequestDetails = json['pending_request_details'] != null
        ? PendingRequestDetails.fromJson(json['pending_request_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['student_name'] = studentName;
    data['student_name_punjabi'] = studentNamePunjabi;
    data['student_unique_id'] = studentUniqueId;
    data['roll_no'] = rollNo;
    data['blood_group'] = bloodGroup;
    data['student_height'] = studentHeight;
    data['student_weight'] = studentWeight;
    data['student_mobile'] = studentMobile;
    data['current_profile_image'] = currentProfileImage;
    data['is_profile_image_uploaded'] = isProfileImageUploaded;
    data['is_father_image_uploaded'] = isFatherImageUploaded;
    data['is_mother_image_uploaded'] = isMotherImageUploaded;
    data['father_name'] = fatherName;
    data['father_name_punjabi'] = fatherNamePunjabi;
    data['mother_name'] = motherName;
    data['mother_name_punjabi'] = motherNamePunjabi;
    data['father_mobile'] = fatherMobile;
    data['mother_mobile'] = motherMobile;
    data['father_qualification'] = fatherQualification;
    data['mother_qualification'] = motherQualification;
    data['current_address'] = currentAddress;
    data['permanent_address'] = permanentAddress;
    data['district'] = district;
    data['state'] = state;
    data['pincode'] = pincode;
    data['has_pending_request'] = hasPendingRequest;
    if (pendingRequestDetails != null) {
      data['pending_request_details'] = pendingRequestDetails!.toJson();
    }
    return data;
  }
}

class PendingRequestDetails {
  int? id;
  String? createdAt;
  dynamic requestedData;
  bool? hasNewProfileImage;
  bool? hasNewFatherImage;
  bool? hasNewMotherImage;

  PendingRequestDetails({
    this.id,
    this.createdAt,
    this.requestedData,
    this.hasNewProfileImage,
    this.hasNewFatherImage,
    this.hasNewMotherImage,
  });

  PendingRequestDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    requestedData = json['requested_data'];
    hasNewProfileImage = json['has_new_profile_image'];
    hasNewFatherImage = json['has_new_father_image'];
    hasNewMotherImage = json['has_new_mother_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['requested_data'] = requestedData;
    data['has_new_profile_image'] = hasNewProfileImage;
    data['has_new_father_image'] = hasNewFatherImage;
    data['has_new_mother_image'] = hasNewMotherImage;
    return data;
  }
}
