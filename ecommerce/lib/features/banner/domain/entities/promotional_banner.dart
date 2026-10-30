import 'package:equatable/equatable.dart';

class PromotionalBannerEntity extends Equatable {
  final String? promotionalBannerUrl;
  final String? basicSectionNearby;
  final String? bottomSectionBanner;

  const PromotionalBannerEntity({
    this.promotionalBannerUrl,
    this.basicSectionNearby,
    this.bottomSectionBanner,
  });

  @override
  List<Object?> get props => [
    promotionalBannerUrl,
    basicSectionNearby,
    bottomSectionBanner,
  ];
}
