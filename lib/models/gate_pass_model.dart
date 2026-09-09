class GatePassModel {
  final bool success;
  final List<GatePassData> data;

  GatePassModel({
    required this.success,
    required this.data,
  });

  factory GatePassModel.fromJson(Map<String, dynamic> json) {
    return GatePassModel(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
              ?.map((e) => GatePassData.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class GatePassData {
  final int? id;
  final String? gatePassNo;
  final String? date;
  final String? time;
  final String? exitTime;
  final String? reason;
  final String? relation;
  final String? personName;
  final String? contactNo;
  final String? status;
  final String? createdAt;

  GatePassData({
    this.id,
    this.gatePassNo,
    this.date,
    this.time,
    this.exitTime,
    this.reason,
    this.relation,
    this.personName,
    this.contactNo,
    this.status,
    this.createdAt,
  });

  factory GatePassData.fromJson(Map<String, dynamic> json) {
    return GatePassData(
      id: json['id'],
      gatePassNo: json['gate_pass_no'],
      date: json['date'],
      time: json['time'],
      exitTime: json['exit_time'],
      reason: json['reason'],
      relation: json['relation'],
      personName: json['person_name'],
      contactNo: json['contact_no'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gate_pass_no': gatePassNo,
      'date': date,
      'time': time,
      'exit_time': exitTime,
      'reason': reason,
      'relation': relation,
      'person_name': personName,
      'contact_no': contactNo,
      'status': status,
      'created_at': createdAt,
    };
  }
}
