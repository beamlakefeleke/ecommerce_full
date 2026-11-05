import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/coupon/data/models/coupon_model.dart';
import 'package:ecommerce/features/coupon/domain/repositories/coupon_repository.dart';

class ApplyTaxiCouponParams extends Equatable {
  final String couponCode;
  final int? providerId;

  const ApplyTaxiCouponParams({required this.couponCode, this.providerId});

  @override
  List<Object?> get props => [couponCode, providerId];
}

class ApplyTaxiCouponUseCase
    implements UseCase<CouponModel, ApplyTaxiCouponParams> {
  final CouponRepository repository;

  ApplyTaxiCouponUseCase(this.repository);

  @override
  Future<Either<Failure, CouponModel>> call(ApplyTaxiCouponParams params) {
    return repository.applyTaxiCoupon(params.couponCode, params.providerId);
  }
}
