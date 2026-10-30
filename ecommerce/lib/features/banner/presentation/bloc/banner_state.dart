import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/banner/domain/entities/parcel_other_banner.dart';
import 'package:ecommerce/features/banner/domain/entities/promotional_banner.dart';

/// Single immutable state holding every banner variant. `null` list means "not
/// loaded yet"; an empty list means "loaded, nothing to show" (the widgets rely
/// on this distinction). Lists survive across the different fetch actions.
class BannerState extends Equatable {
  final List<String?>? bannerImageList;
  final List<dynamic>? bannerDataList;

  final List<String?>? taxiBannerImageList;
  final List<dynamic>? taxiBannerDataList;

  final List<String?>? featuredBannerList;
  final List<dynamic>? featuredBannerDataList;

  final ParcelOtherBanner? parcelOtherBanner;
  final PromotionalBannerEntity? promotionalBanner;

  final int currentIndex;
  final String? errorMessage;

  const BannerState({
    this.bannerImageList,
    this.bannerDataList,
    this.taxiBannerImageList,
    this.taxiBannerDataList,
    this.featuredBannerList,
    this.featuredBannerDataList,
    this.parcelOtherBanner,
    this.promotionalBanner,
    this.currentIndex = 0,
    this.errorMessage,
  });

  BannerState copyWith({
    List<String?>? bannerImageList,
    List<dynamic>? bannerDataList,
    List<String?>? taxiBannerImageList,
    List<dynamic>? taxiBannerDataList,
    List<String?>? featuredBannerList,
    List<dynamic>? featuredBannerDataList,
    ParcelOtherBanner? parcelOtherBanner,
    PromotionalBannerEntity? promotionalBanner,
    int? currentIndex,
    String? errorMessage,
  }) {
    return BannerState(
      bannerImageList: bannerImageList ?? this.bannerImageList,
      bannerDataList: bannerDataList ?? this.bannerDataList,
      taxiBannerImageList: taxiBannerImageList ?? this.taxiBannerImageList,
      taxiBannerDataList: taxiBannerDataList ?? this.taxiBannerDataList,
      featuredBannerList: featuredBannerList ?? this.featuredBannerList,
      featuredBannerDataList:
          featuredBannerDataList ?? this.featuredBannerDataList,
      parcelOtherBanner: parcelOtherBanner ?? this.parcelOtherBanner,
      promotionalBanner: promotionalBanner ?? this.promotionalBanner,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    bannerImageList,
    bannerDataList,
    taxiBannerImageList,
    taxiBannerDataList,
    featuredBannerList,
    featuredBannerDataList,
    parcelOtherBanner,
    promotionalBanner,
    currentIndex,
    errorMessage,
  ];
}
