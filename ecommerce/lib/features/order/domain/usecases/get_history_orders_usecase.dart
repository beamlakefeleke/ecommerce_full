import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

class GetHistoryOrdersUseCase {
  final OrderRepositoryNew _repository;
  const GetHistoryOrdersUseCase(this._repository);

  Future<Either<Failure, PaginatedOrderModel>> call(int offset) =>
      _repository.getHistoryOrders(offset);
}
