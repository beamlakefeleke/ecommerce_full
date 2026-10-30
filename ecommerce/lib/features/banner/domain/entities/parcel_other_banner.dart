import 'package:equatable/equatable.dart';

class ParcelOtherBanner extends Equatable {
  final String? promotionalBannerUrl;
  final List<ParcelBannerItem> banners;

  const ParcelOtherBanner({this.promotionalBannerUrl, this.banners = const []});

  @override
  List<Object?> get props => [promotionalBannerUrl, banners];
}

class ParcelBannerItem extends Equatable {
  final int? id;
  final int? moduleId;
  final String? key;
  final String? image;
  final String? type;
  final int? status;

  const ParcelBannerItem({
    this.id,
    this.moduleId,
    this.key,
    this.image,
    this.type,
    this.status,
  });

  @override
  List<Object?> get props => [id, moduleId, key, image, type, status];
}
