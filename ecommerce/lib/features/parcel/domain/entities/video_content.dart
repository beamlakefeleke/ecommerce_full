class VideoContent {
  final int? id;
  final String? bannerImage;
  final String? bannerVideo;
  final String? bannerType;
  final String? promotionalBannerUrl;
  final String? bannerVideoContentUrl;
  final String? bannerVideoContent;
  final List<BannerContent>? bannerContents;

  VideoContent({
    this.id,
    this.bannerImage,
    this.bannerVideo,
    this.bannerType,
    this.promotionalBannerUrl,
    this.bannerVideoContentUrl,
    this.bannerVideoContent,
    this.bannerContents,
  });
}

class BannerContent {
  final int? id;
  final String? key;
  final String? value;
  final String? type;

  BannerContent({this.id, this.key, this.value, this.type});
}
