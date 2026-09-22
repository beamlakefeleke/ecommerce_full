import 'package:get/get_connect/connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Handles all checkout-related API calls.
/// Returns raw [Response] — the repository converts to typed results / Failures.
class CheckoutRemoteDataSource {
  final ApiClient _apiClient;

  const CheckoutRemoteDataSource(this._apiClient);

  Future<Response> placeOrder(
    PlaceOrderBodyModel orderBody,
    XFile? orderAttachment,
  ) {
    return _apiClient.postMultipartData(
      AppConstants.placeOrderUri,
      orderBody.toJson(),
      [MultipartBody('order_attachment', orderAttachment)],
      handleError: false,
    );
  }

  Future<Response> placePrescriptionOrder(
    int? storeId,
    double? distance,
    String address,
    String longitude,
    String latitude,
    String note,
    List<MultipartBody> orderAttachment,
    String dmTips,
    String deliveryInstruction,
  ) {
    final body = <String, String>{
      'store_id': storeId.toString(),
      'distance': distance.toString(),
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'order_note': note,
      'dm_tips': dmTips,
      'delivery_instruction': deliveryInstruction,
    };
    return _apiClient.postMultipartData(
      AppConstants.placePrescriptionOrderUri,
      body,
      orderAttachment,
      handleError: false,
    );
  }

  Future<Response> getDistanceInMeter(LatLng origin, LatLng destination) {
    return _apiClient.getData(
      '${AppConstants.distanceMatrixUri}'
      '?origin_lat=${origin.latitude}&origin_lng=${origin.longitude}'
      '&destination_lat=${destination.latitude}&destination_lng=${destination.longitude}'
      '&mode=walking',
      handleError: false,
    );
  }

  Future<Response> getExtraCharge(double? distance) {
    return _apiClient.getData(
      '${AppConstants.vehicleChargeUri}?distance=$distance',
      handleError: false,
    );
  }

  Future<Response> getMostTippedAmount() {
    return _apiClient.getData(AppConstants.mostTipsUri);
  }

  Future<Response> getOfflineMethodList() {
    return _apiClient.getData(AppConstants.offlineMethodListUri);
  }
}
