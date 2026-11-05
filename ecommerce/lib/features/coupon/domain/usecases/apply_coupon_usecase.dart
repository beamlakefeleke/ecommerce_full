import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/coupon/data/models/coupon_model.dart';
import 'package:ecommerce/features/coupon/domain/repositories/coupon_repository.dart';

class ApplyCouponParams extends Equatable {
  final String couponCode;
  final int? storeId;

  const ApplyCouponParams({required this.couponCode, this.storeId});

  @override
  List<Object?> get props => [couponCode, storeId];
}

class ApplyCouponUseCase implements UseCase<CouponModel, ApplyCouponParams> {
  final CouponRepository repository;

  ApplyCouponUseCase(this.repository);

  @override
  Future<Either<Failure, CouponModel>> call(ApplyCouponParams params) {
    return repository.applyCoupon(params.couponCode, params.storeId);
  }
}
