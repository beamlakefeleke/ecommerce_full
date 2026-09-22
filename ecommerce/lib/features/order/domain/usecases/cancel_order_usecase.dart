import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

class CancelOrderUseCase {
  final OrderRepositoryNew _repository;
  const CancelOrderUseCase(this._repository);

  Future<Either<Failure, bool>> call(String orderID, String? reason) =>
      _repository.cancelOrder(orderID, reason);
}
