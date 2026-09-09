class SyllabusFormDataModel {
  bool? success;
  SyllabusFormData? data;

  SyllabusFormDataModel({this.success, this.data});

  SyllabusFormDataModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? SyllabusFormData.fromJson(json['data']) : null;
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

class SyllabusFormData {
  bool? canUpload;
  String? whoCanUpload;
  bool? isSubjectRequired;
  String? message;
  List<SyllabusTerm>? terms;
  List<SyllabusClass>? classes;
  List<dynamic>? streams;
  List<SyllabusSection>? sections;
  List<SyllabusSubject>? subjects;
  List<AllowedCombination>? allowedCombinations;

  SyllabusFormData({
    this.canUpload,
    this.whoCanUpload,
    this.isSubjectRequired,
    this.message,
    this.terms,
    this.classes,
    this.streams,
    this.sections,
    this.subjects,
    this.allowedCombinations,
  });

  SyllabusFormData.fromJson(Map<String, dynamic> json) {
    canUpload = json['can_upload'];
    whoCanUpload = json['who_can_upload'];
    isSubjectRequired = json['is_subject_required'];
    message = json['message'];
    if (json['terms'] != null) {
      terms = <SyllabusTerm>[];
      json['terms'].forEach((v) {
        terms!.add(SyllabusTerm.fromJson(v));
      });
    }
    if (json['classes'] != null) {
      classes = <SyllabusClass>[];
      json['classes'].forEach((v) {
        classes!.add(SyllabusClass.fromJson(v));
      });
    }
    streams = json['streams'] != null ? List<dynamic>.from(json['streams']) : null;
    if (json['sections'] != null) {
      sections = <SyllabusSection>[];
      json['sections'].forEach((v) {
        sections!.add(SyllabusSection.fromJson(v));
      });
    }
    if (json['subjects'] != null) {
      subjects = <SyllabusSubject>[];
      json['subjects'].forEach((v) {
        subjects!.add(SyllabusSubject.fromJson(v));
      });
    }
    if (json['allowed_combinations'] != null) {
      allowedCombinations = <AllowedCombination>[];
      json['allowed_combinations'].forEach((v) {
        allowedCombinations!.add(AllowedCombination.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['can_upload'] = canUpload;
    data['who_can_upload'] = whoCanUpload;
    data['is_subject_required'] = isSubjectRequired;
    data['message'] = message;
    if (terms != null) {
      data['terms'] = terms!.map((v) => v.toJson()).toList();
    }
    if (classes != null) {
      data['classes'] = classes!.map((v) => v.toJson()).toList();
    }
    if (streams != null) {
      data['streams'] = streams;
    }
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
    if (subjects != null) {
      data['subjects'] = subjects!.map((v) => v.toJson()).toList();
    }
    if (allowedCombinations != null) {
      data['allowed_combinations'] = allowedCombinations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SyllabusTerm {
  int? id;
  String? name;

  SyllabusTerm({this.id, this.name});

  SyllabusTerm.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class SyllabusClass {
  int? id;
  String? name;

  SyllabusClass({this.id, this.name});

  SyllabusClass.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class SyllabusSection {
  int? id;
  String? name;

  SyllabusSection({this.id, this.name});

  SyllabusSection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class SyllabusSubject {
  int? id;
  String? name;

  SyllabusSubject({this.id, this.name});

  SyllabusSubject.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class AllowedCombination {
  int? classId;
  String? className;
  int? streamId;
  String? streamName;
  int? sectionId;
  String? sectionName;
  bool? hasAllSections;
  int? subjectId;
  String? subjectName;

  AllowedCombination({
    this.classId,
    this.className,
    this.streamId,
    this.streamName,
    this.sectionId,
    this.sectionName,
    this.hasAllSections,
    this.subjectId,
    this.subjectName,
  });

  AllowedCombination.fromJson(Map<String, dynamic> json) {
    classId = json['class_id'];
    className = json['class_name'];
    streamId = json['stream_id'];
    streamName = json['stream_name'];
    sectionId = json['section_id'];
    sectionName = json['section_name'];
    hasAllSections = json['has_all_sections'];
    subjectId = json['subject_id'];
    subjectName = json['subject_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class_id'] = classId;
    data['class_name'] = className;
    data['stream_id'] = streamId;
    data['stream_name'] = streamName;
    data['section_id'] = sectionId;
    data['section_name'] = sectionName;
    data['has_all_sections'] = hasAllSections;
    data['subject_id'] = subjectId;
    data['subject_name'] = subjectName;
    return data;
  }
}
