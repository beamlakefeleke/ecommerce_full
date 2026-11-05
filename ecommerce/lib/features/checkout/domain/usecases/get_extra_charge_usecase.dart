import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class GetExtraChargeUseCase implements UseCase<double, double?> {
  final CheckoutRepository repository;
  GetExtraChargeUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(double? params) =>
      repository.getExtraCharge(params);
}
