import 'package:get/get_connect/connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/models/refund_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the order feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s. No GetX
/// `Response` type leaks above this layer.
abstract class OrderRemoteDataSource {
  Future<PaginatedOrderModel> getRunningOrders(int offset);
  Future<PaginatedOrderModel> getHistoryOrders(int offset);
  Future<List<OrderDetailsModel>> getOrderDetails(
    String orderId,
    String? guestId,
  );
  Future<OrderModel> trackOrder(
    String? orderId,
    String? guestId, {
    String? contactNumber,
  });
  Future<List<CancellationData>> getCancelReasons();
  Future<List<String?>> getRefundReasons();
  Future<String> submitRefundRequest(Map<String, String> body, XFile? image);
  Future<String> cancelOrder(String orderId, String? reason);
  Future<String> switchToCOD(String? orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedOrderModel> getRunningOrders(int offset) async {
    final Response response = await apiClient.getData(
      '${AppConstants.runningOrderListUri}?offset=$offset&limit=50',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return PaginatedOrderModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<PaginatedOrderModel> getHistoryOrders(int offset) async {
    final Response response = await apiClient.getData(
      '${AppConstants.historyOrderListUri}?offset=$offset&limit=10',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return PaginatedOrderModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<OrderDetailsModel>> getOrderDetails(
    String orderId,
    String? guestId,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.orderDetailsUri}$orderId'
      '${guestId != null ? '&guest_id=$guestId' : ''}',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<OrderDetailsModel> list = [];
      response.body.forEach(
        (orderDetail) => list.add(OrderDetailsModel.fromJson(orderDetail)),
      );
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<OrderModel> trackOrder(
    String? orderId,
    String? guestId, {
    String? contactNumber,
  }) async {
    final Response response = await apiClient.getData(
      '${AppConstants.trackUri}$orderId'
      '${guestId != null ? '&guest_id=$guestId' : ''}'
      '${contactNumber != null ? '&contact_number=$contactNumber' : ''}',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return OrderModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<CancellationData>> getCancelReasons() async {
    final Response response = await apiClient.getData(
      '${AppConstants.orderCancellationUri}?offset=1&limit=30&type=customer',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final body = OrderCancellationBody.fromJson(response.body);
      return body.reasons ?? [];
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<String?>> getRefundReasons() async {
    final Response response = await apiClient.getData(
      AppConstants.refundReasonUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final refundModel = RefundModel.fromJson(response.body);
      final List<String?> reasons = ['select_an_option'];
      for (final element in refundModel.refundReasons ?? []) {
        reasons.add(element.reason);
      }
      return reasons;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> submitRefundRequest(
    Map<String, String> body,
    XFile? image,
  ) async {
    final Response response = await apiClient.postMultipartData(
      AppConstants.refundRequestUri,
      body,
      [MultipartBody('image[]', image)],
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> cancelOrder(String orderId, String? reason) async {
    final Map<String, String> data = {
      '_method': 'put',
      'order_id': orderId,
      'reason': reason ?? '',
    };
    if (AuthHelper.isGuestLoggedIn()) {
      data['guest_id'] = AuthHelper.getGuestId();
    }
    final Response response = await apiClient.postData(
      AppConstants.orderCancelUri,
      data,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> switchToCOD(String? orderId) async {
    final Map<String, String> data = {'_method': 'put', 'order_id': orderId!};
    if (AuthHelper.isGuestLoggedIn()) {
      data['guest_id'] = AuthHelper.getGuestId();
    }
    final Response response = await apiClient.postData(
      AppConstants.codSwitchUri,
      data,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
