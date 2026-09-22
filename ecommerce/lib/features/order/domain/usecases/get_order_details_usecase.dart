import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

class GetOrderDetailsUseCase {
  final OrderRepositoryNew _repository;
  const GetOrderDetailsUseCase(this._repository);

  Future<Either<Failure, List<OrderDetailsModel>>> call(
    String orderID,
    String? guestId,
  ) => _repository.getOrderDetails(orderID, guestId);
}
