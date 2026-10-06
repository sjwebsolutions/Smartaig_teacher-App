class LeaveMetaModel {
  bool? success;
  String? message;
  LeaveMetaData? data;

  LeaveMetaModel({
    this.success,
    this.message,
    this.data,
  });

  factory LeaveMetaModel.fromJson(Map<String, dynamic> json) {
    return LeaveMetaModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? LeaveMetaData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class LeaveMetaData {
  bool? isEnabled;
  bool? sameDayCutoffEnabled;
  String? sameDayCutoffTime;
  bool? isCutoffPassedToday;
  String? minStartDate;
  String? policyNote;
  List<LeaveCategory>? leaveCategories;
  List<DurationType>? durationTypes;

  LeaveMetaData({
    this.isEnabled,
    this.sameDayCutoffEnabled,
    this.sameDayCutoffTime,
    this.isCutoffPassedToday,
    this.minStartDate,
    this.policyNote,
    this.leaveCategories,
    this.durationTypes,
  });

  factory LeaveMetaData.fromJson(Map<String, dynamic> json) {
    return LeaveMetaData(
      isEnabled: json['is_enabled'],
      sameDayCutoffEnabled: json['same_day_cutoff_enabled'],
      sameDayCutoffTime: json['same_day_cutoff_time'],
      isCutoffPassedToday: json['is_cutoff_passed_today'],
      minStartDate: json['min_start_date'],
      policyNote: json['policy_note'],
      leaveCategories: (json['leave_categories'] as List?)
          ?.map((e) => LeaveCategory.fromJson(e))
          .toList(),
      durationTypes: (json['duration_types'] as List?)
          ?.map((e) => DurationType.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'same_day_cutoff_enabled': sameDayCutoffEnabled,
      'same_day_cutoff_time': sameDayCutoffTime,
      'is_cutoff_passed_today': isCutoffPassedToday,
      'min_start_date': minStartDate,
      'policy_note': policyNote,
      'leave_categories': leaveCategories?.map((e) => e.toJson()).toList(),
      'duration_types': durationTypes?.map((e) => e.toJson()).toList(),
    };
  }
}

class LeaveCategory {
  String? key;
  String? label;

  LeaveCategory({
    this.key,
    this.label,
  });

  factory LeaveCategory.fromJson(Map<String, dynamic> json) {
    return LeaveCategory(
      key: json['key'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
    };
  }
}

class DurationType {
  String? key;
  String? label;

  DurationType({
    this.key,
    this.label,
  });

  factory DurationType.fromJson(Map<String, dynamic> json) {
    return DurationType(
      key: json['key'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
    };
  }
}
