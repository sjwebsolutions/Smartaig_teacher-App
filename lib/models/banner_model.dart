class BannerModel {
  bool? success;
  List<BannerData>? banners;

  BannerModel({this.success, this.banners});

  BannerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    // Handling both 'banners' and 'teacher_banners' keys for flexibility
    var bannerList = json['teacher_banners'] ?? json['banners'];
    if (bannerList != null) {
      banners = <BannerData>[];
      bannerList.forEach((v) {
        banners!.add(BannerData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (banners != null) {
      data['teacher_banners'] = banners!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BannerData {
  int? id;
  String? name;
  String? category;
  String? type;
  String? imageUrl;
  String? wishing;
  int? displayDays;
  String? publishedAt;

  BannerData({
    this.id,
    this.name,
    this.category,
    this.type,
    this.imageUrl,
    this.wishing,
    this.displayDays,
    this.publishedAt,
  });

  BannerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'];
    type = json['type'];
    imageUrl = json['image_url'];
    wishing = json['wishing'];
    displayDays = json['display_days'];
    publishedAt = json['published_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;
    data['type'] = type;
    data['image_url'] = imageUrl;
    data['wishing'] = wishing;
    data['display_days'] = displayDays;
    data['published_at'] = publishedAt;
    return data;
  }
}
