import 'dart:convert';
import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/payment/data/models/offline_method_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the payment (offline-payment) feature. Throws
/// [ServerException] / [NetworkException]; the repository converts these to
/// [Failure]s.
abstract class PaymentRemoteDataSource {
  Future<List<OfflineMethodModel>> getOfflineMethodList();

  /// [data] is a JSON-encoded body (built by the UI from the dynamic method
  /// fields). Returns true on a 200.
  Future<bool> saveOfflineInfo(String data);

  Future<bool> updateOfflineInfo(String data);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient apiClient;

  PaymentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<OfflineMethodModel>> getOfflineMethodList() async {
    final Response response = await apiClient.getData(
      AppConstants.offlineMethodListUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<OfflineMethodModel> list = [];
      response.body.forEach(
        (method) => list.add(OfflineMethodModel.fromJson(method)),
      );
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<bool> saveOfflineInfo(String data) async {
    final Response response = await apiClient.postData(
      AppConstants.offlinePaymentSaveInfoUri,
      jsonDecode(data),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return true;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<bool> updateOfflineInfo(String data) async {
    final Response response = await apiClient.postData(
      AppConstants.offlinePaymentUpdateInfoUri,
      jsonDecode(data),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return true;
    }
    throw _exceptionFor(response);
  }

  Exception _exceptionFor(Response response) {
    // statusCode 0/1 are the ApiClient's "no internet" sentinels.
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
