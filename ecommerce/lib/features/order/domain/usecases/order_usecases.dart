import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository.dart';

class GetRunningOrdersUseCase
    implements UseCase<PaginatedOrderModel, int> {
  final OrderRepository repository;
  GetRunningOrdersUseCase(this.repository);
  @override
  Future<Either<Failure, PaginatedOrderModel>> call(int offset) =>
      repository.getRunningOrders(offset);
}

class GetHistoryOrdersUseCase
    implements UseCase<PaginatedOrderModel, int> {
  final OrderRepository repository;
  GetHistoryOrdersUseCase(this.repository);
  @override
  Future<Either<Failure, PaginatedOrderModel>> call(int offset) =>
      repository.getHistoryOrders(offset);
}

class GetOrderDetailsUseCase
    implements UseCase<List<OrderDetailsModel>, OrderDetailsParams> {
  final OrderRepository repository;
  GetOrderDetailsUseCase(this.repository);
  @override
  Future<Either<Failure, List<OrderDetailsModel>>> call(
    OrderDetailsParams params,
  ) => repository.getOrderDetails(params.orderId, params.guestId);
}

class OrderDetailsParams extends Equatable {
  final String orderId;
  final String? guestId;
  const OrderDetailsParams({required this.orderId, this.guestId});
  @override
  List<Object?> get props => [orderId, guestId];
}

class TrackOrderUseCase implements UseCase<OrderModel, TrackOrderParams> {
  final OrderRepository repository;
  TrackOrderUseCase(this.repository);
  @override
  Future<Either<Failure, OrderModel>> call(TrackOrderParams params) =>
      repository.trackOrder(
        params.orderId,
        params.guestId,
        contactNumber: params.contactNumber,
      );
}

class TrackOrderParams extends Equatable {
  final String? orderId;
  final String? guestId;
  final String? contactNumber;
  const TrackOrderParams({this.orderId, this.guestId, this.contactNumber});
  @override
  List<Object?> get props => [orderId, guestId, contactNumber];
}

class GetCancelReasonsUseCase
    implements UseCase<List<CancellationData>, NoParams> {
  final OrderRepository repository;
  GetCancelReasonsUseCase(this.repository);
  @override
  Future<Either<Failure, List<CancellationData>>> call(NoParams params) =>
      repository.getCancelReasons();
}

class GetRefundReasonsUseCase implements UseCase<List<String?>, NoParams> {
  final OrderRepository repository;
  GetRefundReasonsUseCase(this.repository);
  @override
  Future<Either<Failure, List<String?>>> call(NoParams params) =>
      repository.getRefundReasons();
}

class SubmitRefundRequestUseCase
    implements UseCase<String, SubmitRefundParams> {
  final OrderRepository repository;
  SubmitRefundRequestUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(SubmitRefundParams params) =>
      repository.submitRefundRequest(params.body, params.image);
}

class SubmitRefundParams extends Equatable {
  final Map<String, String> body;
  final XFile? image;
  const SubmitRefundParams({required this.body, this.image});
  @override
  List<Object?> get props => [body, image];
}

class CancelOrderUseCase implements UseCase<String, CancelOrderParams> {
  final OrderRepository repository;
  CancelOrderUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(CancelOrderParams params) =>
      repository.cancelOrder(params.orderId, params.reason);
}

class CancelOrderParams extends Equatable {
  final String orderId;
  final String? reason;
  const CancelOrderParams({required this.orderId, this.reason});
  @override
  List<Object?> get props => [orderId, reason];
}

class SwitchToCodUseCase implements UseCase<String, String?> {
  final OrderRepository repository;
  SwitchToCodUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(String? orderId) =>
      repository.switchToCOD(orderId);
}
