import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

class TrackOrderUseCase {
  final OrderRepositoryNew _repository;
  const TrackOrderUseCase(this._repository);

  Future<Either<Failure, OrderModel>> call(
    String orderID,
    String? guestId, {
    String? contactNumber,
  }) => _repository.trackOrder(orderID, guestId, contactNumber: contactNumber);
}
