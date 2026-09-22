import 'package:ecommerce/features/parcel/domain/entities/video_content.dart';

class VideoContentModel extends VideoContent {
  VideoContentModel({
    super.id,
    super.bannerImage,
    super.bannerVideo,
    super.bannerType,
    super.promotionalBannerUrl,
    super.bannerVideoContentUrl,
    super.bannerVideoContent,
    super.bannerContents,
  });

  factory VideoContentModel.fromJson(Map<String, dynamic> json) {
    return VideoContentModel(
      id: json['id'],
      bannerImage: json['banner_image'],
      bannerVideo: json['banner_video'],
      bannerType: json['banner_type'],
      promotionalBannerUrl: json['promotional_banner_url'],
      bannerVideoContentUrl: json['banner_video_content_url'],
      bannerVideoContent: json['banner_video_content'],
      bannerContents: json['banner_contents'] != null  
          ? (json['banner_contents'] as List).map((v) => BannerContentModel.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['banner_image'] = bannerImage;
    data['banner_video'] = bannerVideo;
    data['banner_type'] = bannerType;
    data['promotional_banner_url'] = promotionalBannerUrl;
    data['banner_video_content_url'] = bannerVideoContentUrl;
    data['banner_video_content'] = bannerVideoContent;
    if (bannerContents != null) {
      data['banner_contents'] = bannerContents?.map((v) => (v as BannerContentModel).toJson()).toList();
    }
    return data;
  }
}

class BannerContentModel extends BannerContent {
  BannerContentModel({
    super.id,
    super.key,
    super.value,
    super.type,
  });

  factory BannerContentModel.fromJson(Map<String, dynamic> json) {
    return BannerContentModel(
      id: json['id'],
      key: json['key'],
      value: json['value'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['key'] = key;
    data['value'] = value;
    data['type'] = type;
    return data;
  }
}
