import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_new.dart';

class GetExtraChargeUseCase {
  final CheckoutRepositoryNew _repository;
  const GetExtraChargeUseCase(this._repository);

  Future<Either<Failure, double>> call(double? distance) =>
      _repository.getExtraCharge(distance);
}
