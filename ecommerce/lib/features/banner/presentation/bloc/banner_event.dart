import 'package:equatable/equatable.dart';

sealed class BannerEvent extends Equatable {
  const BannerEvent();

  @override
  List<Object?> get props => [];
}

class BannerListRequested extends BannerEvent {
  final bool reload;
  const BannerListRequested({this.reload = false});

  @override
  List<Object?> get props => [reload];
}

class FeaturedBannerRequested extends BannerEvent {
  const FeaturedBannerRequested();
}

class TaxiBannerListRequested extends BannerEvent {
  final bool reload;
  final bool isDesktop;
  const TaxiBannerListRequested({this.reload = false, this.isDesktop = false});

  @override
  List<Object?> get props => [reload, isDesktop];
}

class ParcelOtherBannerRequested extends BannerEvent {
  final bool reload;
  const ParcelOtherBannerRequested({this.reload = false});

  @override
  List<Object?> get props => [reload];
}

class PromotionalBannerRequested extends BannerEvent {
  final bool reload;
  const PromotionalBannerRequested({this.reload = false});

  @override
  List<Object?> get props => [reload];
}

class BannerIndexChanged extends BannerEvent {
  final int index;
  const BannerIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}
