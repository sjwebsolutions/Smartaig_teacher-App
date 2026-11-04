class ActiveEventModel {
  bool? success;
  List<ActiveEventItem>? data;

  ActiveEventModel({
    this.success,
    this.data,
  });

  factory ActiveEventModel.fromJson(Map<String, dynamic> json) {
    return ActiveEventModel(
      success: json['success'] as bool?,
      data: (json['data'] as List?)
          ?.map((e) => ActiveEventItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class ActiveEventItem {
  int? id;
  String? eventCode;
  String? title;
  String? subTitle;
  String? venue;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  String? registrationDeadline;
  int? maxGuestsPerStudent;
  bool? requiresApproval;
  bool? requireAadhaar;
  bool? requirePhoto;
  bool? allowMultipleCheckins;
  String? bannerUrl;
  LiveTelecast? liveTelecast;

  ActiveEventItem({
    this.id,
    this.eventCode,
    this.title,
    this.subTitle,
    this.venue,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.registrationDeadline,
    this.maxGuestsPerStudent,
    this.requiresApproval,
    this.requireAadhaar,
    this.requirePhoto,
    this.allowMultipleCheckins,
    this.bannerUrl,
    this.liveTelecast,
  });

  factory ActiveEventItem.fromJson(Map<String, dynamic> json) {
    return ActiveEventItem(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? ''),
      eventCode: json['event_code']?.toString(),
      title: json['title']?.toString(),
      subTitle: json['sub_title']?.toString(),
      venue: json['venue']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      registrationDeadline: json['registration_deadline']?.toString(),
      maxGuestsPerStudent: json['max_guests_per_student'] is num
          ? (json['max_guests_per_student'] as num).toInt()
          : int.tryParse(json['max_guests_per_student']?.toString() ?? ''),
      requiresApproval: json['requires_approval'] as bool?,
      requireAadhaar: json['require_aadhaar'] as bool?,
      requirePhoto: json['require_photo'] as bool?,
      allowMultipleCheckins: json['allow_multiple_checkins'] as bool?,
      bannerUrl: json['banner_url']?.toString(),
      liveTelecast: json['live_telecast'] != null
          ? LiveTelecast.fromJson(json['live_telecast'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_code': eventCode,
      'title': title,
      'sub_title': subTitle,
      'venue': venue,
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
      'registration_deadline': registrationDeadline,
      'max_guests_per_student': maxGuestsPerStudent,
      'requires_approval': requiresApproval,
      'require_aadhaar': requireAadhaar,
      'require_photo': requirePhoto,
      'allow_multiple_checkins': allowMultipleCheckins,
      'banner_url': bannerUrl,
      'live_telecast': liveTelecast?.toJson(),
    };
  }
}

class LiveTelecast {
  bool? isLive;
  String? youtubeUrl;
  String? youtubeVideoId;
  String? embedUrl;
  String? title;
  String? startedAt;
  String? endedAt;

  LiveTelecast({
    this.isLive,
    this.youtubeUrl,
    this.youtubeVideoId,
    this.embedUrl,
    this.title,
    this.startedAt,
    this.endedAt,
  });

  factory LiveTelecast.fromJson(Map<String, dynamic> json) {
    return LiveTelecast(
      isLive: json['is_live'] as bool?,
      youtubeUrl: json['youtube_url']?.toString(),
      youtubeVideoId: json['youtube_video_id']?.toString(),
      embedUrl: json['embed_url']?.toString(),
      title: json['title']?.toString(),
      startedAt: json['started_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_live': isLive,
      'youtube_url': youtubeUrl,
      'youtube_video_id': youtubeVideoId,
      'embed_url': embedUrl,
      'title': title,
      'started_at': startedAt,
      'ended_at': endedAt,
    };
  }
}
