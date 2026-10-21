class NotificationResponseModel {
  bool? success;
  String? message;
  NotificationDataContainer? data;

  NotificationResponseModel({this.success, this.message, this.data});

  NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] is bool ? json['success'] : (json['success']?.toString() == 'true');
    message = json['message']?.toString();
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? NotificationDataContainer.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class NotificationDataContainer {
  List<NotificationItem>? notifications;
  int? retentionDays;
  NotificationPagination? pagination;

  NotificationDataContainer({this.notifications, this.retentionDays, this.pagination});

  NotificationDataContainer.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null && json['notifications'] is List) {
      notifications = <NotificationItem>[];
      for (var v in (json['notifications'] as List)) {
        if (v is Map<String, dynamic>) {
          notifications!.add(NotificationItem.fromJson(v));
        }
      }
    }
    if (json['retention_days'] != null) {
      retentionDays = json['retention_days'] is int
          ? json['retention_days']
          : int.tryParse(json['retention_days'].toString());
    } else {
      retentionDays = 7;
    }
    pagination = json['pagination'] != null && json['pagination'] is Map<String, dynamic>
        ? NotificationPagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (notifications != null) {
      map['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    map['retention_days'] = retentionDays;
    if (pagination != null) {
      map['pagination'] = pagination!.toJson();
    }
    return map;
  }
}

class NotificationItem {
  dynamic id;
  String? module;
  String? title;
  String? body;
  String? message;
  String? description;
  String? type;
  bool? isRead;
  String? readAt;
  String? createdAt;
  String? updatedAt;
  String? timeAgo;
  String? imageUrl;
  Map<String, dynamic>? data;

  NotificationItem({
    this.id,
    this.module,
    this.title,
    this.body,
    this.message,
    this.description,
    this.type,
    this.isRead,
    this.readAt,
    this.createdAt,
    this.updatedAt,
    this.timeAgo,
    this.imageUrl,
    this.data,
  });

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    if (body != null && body!.trim().isNotEmpty) return body!.trim();
    if (message != null && message!.trim().isNotEmpty) return message!.trim();
    return "Notification";
  }

  String get displayModule => (module != null && module!.trim().isNotEmpty) ? module!.trim() : (type ?? "");

  String get displayBody {
    if (body != null && body!.trim().isNotEmpty && body!.trim() != title?.trim()) {
      return body!.trim();
    }
    if (message != null && message!.trim().isNotEmpty && message!.trim() != title?.trim()) {
      return message!.trim();
    }
    if (description != null && description!.trim().isNotEmpty && description!.trim() != title?.trim()) {
      return description!.trim();
    }
    return "";
  }

  NotificationItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    module = json['module']?.toString();
    title = json['title']?.toString();
    body = json['body']?.toString();
    message = json['message']?.toString();
    description = json['description']?.toString();
    type = json['type']?.toString();

    if (json['is_read'] != null) {
      if (json['is_read'] is bool) {
        isRead = json['is_read'] as bool;
      } else if (json['is_read'] is int) {
        isRead = (json['is_read'] as int) == 1;
      } else if (json['is_read'] is String) {
        isRead = json['is_read'] == 'true' || json['is_read'] == '1';
      }
    } else {
      isRead = json['read_at'] != null;
    }

    readAt = json['read_at']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    timeAgo = json['time_ago']?.toString();
    imageUrl = (json['image_url'] ?? json['image'])?.toString();
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = json['data'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['module'] = module;
    map['title'] = title;
    map['body'] = body;
    map['message'] = message;
    map['description'] = description;
    map['type'] = type;
    map['is_read'] = isRead;
    map['read_at'] = readAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['time_ago'] = timeAgo;
    map['image_url'] = imageUrl;
    map['data'] = data;
    return map;
  }
}

class NotificationPagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  bool? hasMore;

  NotificationPagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.hasMore,
  });

  NotificationPagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'] is int
        ? json['current_page']
        : int.tryParse(json['current_page']?.toString() ?? '');
    lastPage = json['last_page'] is int
        ? json['last_page']
        : int.tryParse(json['last_page']?.toString() ?? '');
    perPage = json['per_page'] is int
        ? json['per_page']
        : int.tryParse(json['per_page']?.toString() ?? '');
    total = json['total'] is int
        ? json['total']
        : int.tryParse(json['total']?.toString() ?? '');
    hasMore = json['has_more'] is bool
        ? json['has_more']
        : (json['has_more']?.toString() == 'true' || json['has_more'] == 1);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['current_page'] = currentPage;
    map['last_page'] = lastPage;
    map['per_page'] = perPage;
    map['total'] = total;
    map['has_more'] = hasMore;
    return map;
  }
}

class UnreadCountResponseModel {
  bool? success;
  String? message;
  UnreadCountData? data;

  UnreadCountResponseModel({this.success, this.message, this.data});

  UnreadCountResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] is bool ? json['success'] : (json['success']?.toString() == 'true');
    message = json['message']?.toString();
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? UnreadCountData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class UnreadCountData {
  int? unreadCount;

  UnreadCountData({this.unreadCount});

  UnreadCountData.fromJson(Map<String, dynamic> json) {
    unreadCount = json['unread_count'] is int
        ? json['unread_count']
        : int.tryParse(json['unread_count']?.toString() ?? '0');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['unread_count'] = unreadCount;
    return map;
  }
}
