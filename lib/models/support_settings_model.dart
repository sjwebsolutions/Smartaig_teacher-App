class SupportSettingsModel {
  final bool success;
  final SupportData? data;

  SupportSettingsModel({required this.success, this.data});

  factory SupportSettingsModel.fromJson(Map<String, dynamic> json) {
    return SupportSettingsModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? SupportData.fromJson(json['data']) : null,
    );
  }
}

class SupportData {
  final String? name;
  final String? whatsapp;
  final String? mobile;
  final String? email;

  SupportData({this.name, this.whatsapp, this.mobile, this.email});

  factory SupportData.fromJson(Map<String, dynamic> json) {
    return SupportData(
      name: json['name']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
    );
  }
}
