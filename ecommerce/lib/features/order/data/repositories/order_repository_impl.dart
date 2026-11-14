import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/order/data/datasources/order_remote_data_source.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedOrderModel>> getRunningOrders(
    int offset,
  ) => _guard(() => remoteDataSource.getRunningOrders(offset));

  @override
  Future<Either<Failure, PaginatedOrderModel>> getHistoryOrders(
    int offset,
  ) => _guard(() => remoteDataSource.getHistoryOrders(offset));

  @override
  Future<Either<Failure, List<OrderDetailsModel>>> getOrderDetails(
    String orderId,
    String? guestId,
  ) => _guard(() => remoteDataSource.getOrderDetails(orderId, guestId));

  @override
  Future<Either<Failure, OrderModel>> trackOrder(
    String? orderId,
    String? guestId, {
    String? contactNumber,
  }) => _guard(
    () => remoteDataSource.trackOrder(
      orderId,
      guestId,
      contactNumber: contactNumber,
    ),
  );

  @override
  Future<Either<Failure, List<CancellationData>>> getCancelReasons() =>
      _guard(() => remoteDataSource.getCancelReasons());

  @override
  Future<Either<Failure, List<String?>>> getRefundReasons() =>
      _guard(() => remoteDataSource.getRefundReasons());

  @override
  Future<Either<Failure, String>> submitRefundRequest(
    Map<String, String> body,
    XFile? image,
  ) => _guard(() => remoteDataSource.submitRefundRequest(body, image));

  @override
  Future<Either<Failure, String>> cancelOrder(String orderId, String? reason) =>
      _guard(() => remoteDataSource.cancelOrder(orderId, reason));

  @override
  Future<Either<Failure, String>> switchToCOD(String? orderId) =>
      _guard(() => remoteDataSource.switchToCOD(orderId));

  /// Shared try/catch that maps data-layer exceptions to [Failure]s.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
