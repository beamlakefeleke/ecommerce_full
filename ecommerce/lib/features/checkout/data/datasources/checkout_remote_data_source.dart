import 'package:get/get_connect/connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';
import 'package:ecommerce/util/app_constants.dart';

abstract class CheckoutRemoteDataSource {
  Future<List<OfflineMethodModel>> getOfflineMethodList();
  Future<int> getDmTipMostTapped();
  Future<double> getExtraCharge(double? distance);
  Future<Response> getDistanceInMeter(LatLng origin, LatLng destination);
  Future<Response> placeOrder(PlaceOrderBodyModel body, XFile? attachment);
  Future<Response> placePrescriptionOrder(
    Map<String, String> body,
    List<MultipartBody> attachments,
  );
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final ApiClient apiClient;

  CheckoutRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OfflineMethodModel>> getOfflineMethodList() async {
    final Response response = await apiClient.getData(
      AppConstants.offlineMethodListUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<OfflineMethodModel> list = [];
      response.body.forEach((m) => list.add(OfflineMethodModel.fromJson(m)));
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<int> getDmTipMostTapped() async {
    final Response response = await apiClient.getData(
      AppConstants.mostTipsUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['most_tips_amount'] ?? 0;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<double> getExtraCharge(double? distance) async {
    final Response response = await apiClient.getData(
      '${AppConstants.vehicleChargeUri}?distance=$distance',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return double.parse(response.body.toString());
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Response> getDistanceInMeter(LatLng origin, LatLng destination) async {
    return await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=${origin.latitude}&origin_lng=${origin.longitude}'
      '&destination_lat=${destination.latitude}&destination_lng=${destination.longitude}&mode=walking',
      handleError: false,
    );
  }

  @override
  Future<Response> placeOrder(
    PlaceOrderBodyModel body,
    XFile? attachment,
  ) async {
    return await apiClient.postMultipartData(
      AppConstants.placeOrderUri,
      body.toJson(),
      [MultipartBody('order_attachment', attachment)],
      handleError: false,
    );
  }

  @override
  Future<Response> placePrescriptionOrder(
    Map<String, String> body,
    List<MultipartBody> attachments,
  ) async {
    return await apiClient.postMultipartData(
      AppConstants.placePrescriptionOrderUri,
      body,
      attachments,
      handleError: false,
    );
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
