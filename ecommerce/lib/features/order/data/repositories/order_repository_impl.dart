import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/data/datasources/order_remote_data_source.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/models/refund_model.dart';
import 'package:ecommerce/features/order/domain/repositories/order_repository_new.dart';

/// Concrete implementation of [OrderRepositoryNew].
/// Catches data-source exceptions and converts them to typed [Failure]s.
class OrderRepositoryImpl implements OrderRepositoryNew {
  final OrderRemoteDataSource _remote;

  const OrderRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, PaginatedOrderModel>> getRunningOrders(
    int offset,
  ) async {
    try {
      final response = await _remote.getRunningOrders(offset);
      if (response.statusCode == 200) {
        return Right(PaginatedOrderModel.fromJson(response.body));
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to load running orders',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedOrderModel>> getHistoryOrders(
    int offset,
  ) async {
    try {
      final response = await _remote.getHistoryOrders(offset);
      if (response.statusCode == 200) {
        return Right(PaginatedOrderModel.fromJson(response.body));
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to load order history',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderDetailsModel>>> getOrderDetails(
    String orderID,
    String? guestId,
  ) async {
    try {
      final response = await _remote.getOrderDetails(orderID, guestId);
      if (response.statusCode == 200) {
        final List<OrderDetailsModel> details = [];
        for (final item in response.body as List) {
          details.add(OrderDetailsModel.fromJson(item));
        }
        return Right(details);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to load order details',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderModel>> trackOrder(
    String orderID,
    String? guestId, {
    String? contactNumber,
  }) async {
    try {
      final response = await _remote.trackOrder(
        orderID,
        guestId,
        contactNumber: contactNumber,
      );
      if (response.statusCode == 200) {
        return Right(OrderModel.fromJson(response.body));
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to track order',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelOrder(
    String orderID,
    String? reason,
  ) async {
    try {
      final response = await _remote.cancelOrder(orderID, reason);
      if (response.statusCode == 200) {
        return const Right(true);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to cancel order',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> switchToCOD(String orderID) async {
    try {
      final response = await _remote.switchToCOD(orderID);
      if (response.statusCode == 200) {
        return const Right(true);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to switch to COD',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitRefundRequest(
    Map<String, String> body,
    XFile? image,
  ) async {
    try {
      final response = await _remote.submitRefundRequest(body, image);
      if (response.statusCode == 200) {
        return const Right(null);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Refund request failed',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CancellationData>>> getCancelReasons() async {
    try {
      final response = await _remote.getCancelReasons();
      if (response.statusCode == 200) {
        final body = OrderCancellationBody.fromJson(response.body);
        return Right(body.reasons ?? []);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to load cancel reasons',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String?>>> getRefundReasons() async {
    try {
      final response = await _remote.getRefundReasons();
      if (response.statusCode == 200) {
        final model = RefundModel.fromJson(response.body);
        final reasons = <String?>['select_an_option'];
        for (final r in model.refundReasons ?? []) {
          reasons.add(r.reason);
        }
        return Right(reasons);
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to load refund reasons',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
