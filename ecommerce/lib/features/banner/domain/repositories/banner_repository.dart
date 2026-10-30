import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/banner/domain/entities/banner.dart';
import 'package:ecommerce/features/banner/domain/entities/parcel_other_banner.dart';
import 'package:ecommerce/features/banner/domain/entities/promotional_banner.dart';

/// Abstract contract for the banner feature. Implemented in the data layer.
abstract class BannerRepository {
  Future<Either<Failure, BannerCollection>> getBanners();
  Future<Either<Failure, BannerCollection>> getTaxiBanners();
  Future<Either<Failure, BannerCollection>> getFeaturedBanners();
  Future<Either<Failure, ParcelOtherBanner>> getParcelOtherBanners();
  Future<Either<Failure, PromotionalBannerEntity>> getPromotionalBanners();

  /// Module ids available to the user, derived from the saved address zones.
  /// Used to decide whether a featured banner's item/store is reachable.
  List<int?> moduleIds();
}
