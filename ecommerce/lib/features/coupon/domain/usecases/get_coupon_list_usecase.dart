import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/coupon/data/models/coupon_model.dart';
import 'package:ecommerce/features/coupon/domain/repositories/coupon_repository.dart';

class GetCouponListUseCase implements UseCase<List<CouponModel>, NoParams> {
  final CouponRepository repository;

  GetCouponListUseCase(this.repository);

  @override
  Future<Either<Failure, List<CouponModel>>> call(NoParams params) {
    return repository.getCouponList();
  }
}
