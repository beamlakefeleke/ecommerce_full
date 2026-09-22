import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';

/// Domain contract for order operations.
/// All fallible methods return [Either<Failure, T>].
abstract class OrderRepositoryNew {
  Future<Either<Failure, PaginatedOrderModel>> getRunningOrders(int offset);
  Future<Either<Failure, PaginatedOrderModel>> getHistoryOrders(int offset);
  Future<Either<Failure, List<OrderDetailsModel>>> getOrderDetails(
    String orderID,
    String? guestId,
  );
  Future<Either<Failure, OrderModel>> trackOrder(
    String orderID,
    String? guestId, {
    String? contactNumber,
  });
  Future<Either<Failure, bool>> cancelOrder(String orderID, String? reason);
  Future<Either<Failure, bool>> switchToCOD(String orderID);
  Future<Either<Failure, void>> submitRefundRequest(
    Map<String, String> body,
    XFile? image,
  );
  Future<Either<Failure, List<CancellationData>>> getCancelReasons();
  Future<Either<Failure, List<String?>>> getRefundReasons();
}
