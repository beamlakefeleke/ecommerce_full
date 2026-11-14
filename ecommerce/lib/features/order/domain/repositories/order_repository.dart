import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';

/// Abstract contract for the order feature. Implemented in the data layer.
/// Every method returns `Either<Failure, T>` — no throwing across the boundary,
/// and no GetX `Response` type leaks above the data source.
///
/// Note (rule 7): `OrderModel`/`PaginatedOrderModel`/`OrderDetailsModel` are the
/// single shared models kept in `domain/models/` because they are consumed
/// app-wide by still-GetX features (checkout, payment, taxi, review, dashboard,
/// route_helper). They are NOT split into separate entities during this
/// migration — same precedent as the `item` feature.
abstract class OrderRepository {
  Future<Either<Failure, PaginatedOrderModel>> getRunningOrders(int offset);

  Future<Either<Failure, PaginatedOrderModel>> getHistoryOrders(int offset);

  Future<Either<Failure, List<OrderDetailsModel>>> getOrderDetails(
    String orderId,
    String? guestId,
  );

  Future<Either<Failure, OrderModel>> trackOrder(
    String? orderId,
    String? guestId, {
    String? contactNumber,
  });

  Future<Either<Failure, List<CancellationData>>> getCancelReasons();

  Future<Either<Failure, List<String?>>> getRefundReasons();

  /// Returns the success message on 200.
  Future<Either<Failure, String>> submitRefundRequest(
    Map<String, String> body,
    XFile? image,
  );

  /// Returns the success message on 200.
  Future<Either<Failure, String>> cancelOrder(String orderId, String? reason);

  /// Returns the success message on 200.
  Future<Either<Failure, String>> switchToCOD(String? orderId);
}
