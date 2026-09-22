import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

class SwitchToCodUseCase {
  final OrderRepositoryNew _repository;
  const SwitchToCodUseCase(this._repository);

  Future<Either<Failure, bool>> call(String orderID) =>
      _repository.switchToCOD(orderID);
}
