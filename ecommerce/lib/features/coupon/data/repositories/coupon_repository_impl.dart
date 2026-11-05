import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/coupon/data/datasources/coupon_remote_data_source.dart';
import 'package:ecommerce/features/coupon/data/models/coupon_model.dart';
import 'package:ecommerce/features/coupon/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource remoteDataSource;

  CouponRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CouponModel>>> getCouponList() async {
    try {
      return Right(await remoteDataSource.getCouponList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CouponModel>>> getTaxiCouponList() async {
    try {
      return Right(await remoteDataSource.getTaxiCouponList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CouponModel>> applyCoupon(
    String couponCode,
    int? storeId,
  ) async {
    try {
      return Right(await remoteDataSource.applyCoupon(couponCode, storeId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CouponModel>> applyTaxiCoupon(
    String couponCode,
    int? providerId,
  ) async {
    try {
      return Right(
        await remoteDataSource.applyTaxiCoupon(couponCode, providerId),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
