class WhyChoose {
  final String? whyChooseUrl;
  final List<WhyChooseBanner>? banners;

  WhyChoose({this.whyChooseUrl, this.banners});
}

class WhyChooseBanner {
  final String? title;
  final String? shortDescription;
  final String? image;

  WhyChooseBanner({this.title, this.shortDescription, this.image});
}
