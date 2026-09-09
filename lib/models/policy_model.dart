class PolicyModel {
  final bool success;
  final PolicyData? data;

  PolicyModel({required this.success, this.data});

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? PolicyData.fromJson(json['data']) : null,
    );
  }
}

class PolicyData {
  final String? termsOfUse;
  final String? privacyPolicy;

  PolicyData({this.termsOfUse, this.privacyPolicy});

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      termsOfUse: json['terms_of_use']?.toString(),
      privacyPolicy: json['privacy_policy']?.toString(),
    );
  }
}
