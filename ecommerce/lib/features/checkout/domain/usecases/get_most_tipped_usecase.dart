import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_new.dart';

class GetMostTippedUseCase {
  final CheckoutRepositoryNew _repository;
  const GetMostTippedUseCase(this._repository);

  Future<Either<Failure, int>> call() => _repository.getMostTippedAmount();
}
