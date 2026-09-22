import 'package:ecommerce/features/parcel/domain/entities/why_choose.dart';

class WhyChooseModel extends WhyChoose {
  WhyChooseModel({
    super.whyChooseUrl,
    super.banners,
  });

  factory WhyChooseModel.fromJson(Map<String, dynamic> json) {
    return WhyChooseModel(
      whyChooseUrl: json['why_choose_url'],
      banners: json['banners'] != null ? (json['banners'] as List).map((v) => WhyChooseBannerModel.fromJson(v)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['why_choose_url'] = whyChooseUrl;
    if (banners != null) {
      data['banners'] = banners?.map((v) => (v as WhyChooseBannerModel).toJson()).toList();
    }
    return data;
  }
}

class WhyChooseBannerModel extends WhyChooseBanner {
  WhyChooseBannerModel({
    super.title,
    super.shortDescription,
    super.image,
  });

  factory WhyChooseBannerModel.fromJson(Map<String, dynamic> json) {
    return WhyChooseBannerModel(
      title: json['title'],
      shortDescription: json['short_description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['short_description'] = shortDescription;
    data['image'] = image;
    return data;
  }
}
