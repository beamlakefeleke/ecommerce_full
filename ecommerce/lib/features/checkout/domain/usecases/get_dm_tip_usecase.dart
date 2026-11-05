import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class GetDmTipMostTappedUseCase implements UseCase<int, NoParams> {
  final CheckoutRepository repository;
  GetDmTipMostTappedUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) =>
      repository.getDmTipMostTapped();
}
