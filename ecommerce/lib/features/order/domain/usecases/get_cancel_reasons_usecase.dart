import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

class GetCancelReasonsUseCase {
  final OrderRepositoryNew _repository;
  const GetCancelReasonsUseCase(this._repository);

  Future<Either<Failure, List<CancellationData>>> call() =>
      _repository.getCancelReasons();
}
