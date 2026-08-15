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
  String? studentUniqueId;
  String? rollNo;
  String? currentProfileImage;
  bool? isProfileImageUploaded;
  bool? isFatherImageUploaded;
  bool? isMotherImageUploaded;
  bool? hasPendingRequest;
  PendingRequestDetails? pendingRequestDetails;

  ImageUpdateStudentData(
      {this.id,
      this.studentName,
      this.studentUniqueId,
      this.rollNo,
      this.currentProfileImage,
      this.isProfileImageUploaded,
      this.isFatherImageUploaded,
      this.isMotherImageUploaded,
      this.hasPendingRequest,
      this.pendingRequestDetails});

  ImageUpdateStudentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    studentName = json['student_name'];
    studentUniqueId = json['student_unique_id'];
    rollNo = json['roll_no'];
    currentProfileImage = json['current_profile_image'];
    isProfileImageUploaded = json['is_profile_image_uploaded'];
    isFatherImageUploaded = json['is_father_image_uploaded'];
    isMotherImageUploaded = json['is_mother_image_uploaded'];
    hasPendingRequest = json['has_pending_request'];
    pendingRequestDetails = json['pending_request_details'] != null
        ? PendingRequestDetails.fromJson(json['pending_request_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['student_name'] = studentName;
    data['student_unique_id'] = studentUniqueId;
    data['roll_no'] = rollNo;
    data['current_profile_image'] = currentProfileImage;
    data['is_profile_image_uploaded'] = isProfileImageUploaded;
    data['is_father_image_uploaded'] = isFatherImageUploaded;
    data['is_mother_image_uploaded'] = isMotherImageUploaded;
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

  PendingRequestDetails({this.id, this.createdAt});

  PendingRequestDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    return data;
  }
}
