import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/banner/data/datasources/banner_remote_data_source.dart';
import 'package:ecommerce/features/banner/domain/entities/banner.dart';
import 'package:ecommerce/features/banner/domain/entities/parcel_other_banner.dart';
import 'package:ecommerce/features/banner/domain/entities/promotional_banner.dart';
import 'package:ecommerce/features/banner/domain/repositories/banner_repository.dart';
import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';
import 'package:ecommerce/helper/address_helper.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;

  BannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BannerCollection>> getBanners() {
    return _guard(
      () async => (await remoteDataSource.getBannerList()).toEntity(),
    );
  }

  @override
  Future<Either<Failure, BannerCollection>> getTaxiBanners() {
    return _guard(
      () async => (await remoteDataSource.getTaxiBannerList()).toEntity(),
    );
  }

  @override
  Future<Either<Failure, BannerCollection>> getFeaturedBanners() {
    return _guard(
      () async => (await remoteDataSource.getFeaturedBannerList()).toEntity(),
    );
  }

  @override
  Future<Either<Failure, ParcelOtherBanner>> getParcelOtherBanners() {
    return _guard(
      () async =>
          (await remoteDataSource.getParcelOtherBannerList()).toEntity(),
    );
  }

  @override
  Future<Either<Failure, PromotionalBannerEntity>> getPromotionalBanners() {
    return _guard(
      () async =>
          (await remoteDataSource.getPromotionalBannerList()).toEntity(),
    );
  }

  @override
  List<int?> moduleIds() {
    final List<int?> ids = [];
    final zones = AddressHelper.getUserAddressFromSharedPref()?.zoneData;
    for (final ZoneData zone in zones ?? const []) {
      for (final Modules module in zone.modules ?? const []) {
        ids.add(module.id);
      }
    }
    return ids;
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
