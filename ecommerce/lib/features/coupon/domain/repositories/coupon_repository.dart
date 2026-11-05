import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/coupon/data/models/coupon_model.dart';

abstract class CouponRepository {
  Future<Either<Failure, List<CouponModel>>> getCouponList();
  Future<Either<Failure, List<CouponModel>>> getTaxiCouponList();
  Future<Either<Failure, CouponModel>> applyCoupon(
    String couponCode,
    int? storeId,
  );
  Future<Either<Failure, CouponModel>> applyTaxiCoupon(
    String couponCode,
    int? providerId,
  );
}
