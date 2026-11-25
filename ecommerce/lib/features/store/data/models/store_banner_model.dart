class StoreBannerModel {
  int? id;
  String? title;
  String? type;
  String? image;
  bool? status;
  int? data;
  String? createdAt;
  String? updatedAt;
  int? zoneId;
  int? moduleId;
  bool? featured;
  String? defaultLink;
  String? createdBy;

  StoreBannerModel({
    this.id,
    this.title,
    this.type,
    this.image,
    this.status,
    this.data,
    this.createdAt,
    this.updatedAt,
    this.zoneId,
    this.moduleId,
    this.featured,
    this.defaultLink,
    this.createdBy,
  });

  StoreBannerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    image = json['image'];
    status = json['status'];
    data = json['data'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    zoneId = json['zone_id'];
    moduleId = json['module_id'];
    featured = json['featured'];
    defaultLink = json['default_link'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = <String, dynamic>{};
    result['id'] = id;
    result['title'] = title;
    result['type'] = type;
    result['image'] = image;
    result['status'] = status;
    result['data'] = data;
    result['created_at'] = createdAt;
    result['updated_at'] = updatedAt;
    result['zone_id'] = zoneId;
    result['module_id'] = moduleId;
    result['featured'] = featured;
    result['default_link'] = defaultLink;
    result['created_by'] = createdBy;
    return result;
  }
}
