import 'package:get/get_connect/connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Handles all order-related API calls.
/// Returns raw [Response] objects — the repository converts these to typed results.
class OrderRemoteDataSource {
  final ApiClient _apiClient;

  const OrderRemoteDataSource(this._apiClient);

  Future<Response> getRunningOrders(int offset) {
    return _apiClient.getData(
      '${AppConstants.runningOrderListUri}?offset=$offset&limit=50',
    );
  }

  Future<Response> getHistoryOrders(int offset) {
    return _apiClient.getData(
      '${AppConstants.historyOrderListUri}?offset=$offset&limit=10',
    );
  }

  Future<Response> getOrderDetails(String orderID, String? guestId) {
    return _apiClient.getData(
      '${AppConstants.orderDetailsUri}$orderID'
      '${guestId != null ? '&guest_id=$guestId' : ''}',
    );
  }

  Future<Response> trackOrder(
    String? orderID,
    String? guestId, {
    String? contactNumber,
  }) {
    return _apiClient.getData(
      '${AppConstants.trackUri}$orderID'
      '${guestId != null ? '&guest_id=$guestId' : ''}'
      '${contactNumber != null ? '&contact_number=$contactNumber' : ''}',
    );
  }

  Future<Response> cancelOrder(String orderID, String? reason) {
    final Map<String, String> data = {
      '_method': 'put',
      'order_id': orderID,
      'reason': reason ?? '',
    };
    if (AuthHelper.isGuestLoggedIn()) {
      data['guest_id'] = AuthHelper.getGuestId();
    }
    return _apiClient.postData(AppConstants.orderCancelUri, data);
  }

  Future<Response> switchToCOD(String orderID) {
    final Map<String, String> data = {'_method': 'put', 'order_id': orderID};
    if (AuthHelper.isGuestLoggedIn()) {
      data['guest_id'] = AuthHelper.getGuestId();
    }
    return _apiClient.postData(AppConstants.codSwitchUri, data);
  }

  Future<Response> submitRefundRequest(Map<String, String> body, XFile? image) {
    return _apiClient.postMultipartData(AppConstants.refundRequestUri, body, [
      MultipartBody('image[]', image),
    ]);
  }

  Future<Response> getCancelReasons() {
    return _apiClient.getData(
      '${AppConstants.orderCancellationUri}?offset=1&limit=30&type=customer',
    );
  }

  Future<Response> getRefundReasons() {
    return _apiClient.getData(AppConstants.refundReasonUri);
  }
}
