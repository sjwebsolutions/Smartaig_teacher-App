class ImageUpdateFormOptionsModel {
  bool? success;
  ImageUpdateFormOptionsData? data;

  ImageUpdateFormOptionsModel({this.success, this.data});

  ImageUpdateFormOptionsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? ImageUpdateFormOptionsData.fromJson(json['data'])
        : null;
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

class ImageUpdateFormOptionsData {
  List<String>? bloodGroups;

  ImageUpdateFormOptionsData({this.bloodGroups});

  ImageUpdateFormOptionsData.fromJson(Map<String, dynamic> json) {
    bloodGroups = json['blood_groups']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['blood_groups'] = bloodGroups;
    return data;
  }
}
