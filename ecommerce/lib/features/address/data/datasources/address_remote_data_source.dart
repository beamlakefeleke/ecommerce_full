import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the address feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();

  /// Returns the zone ids the created address belongs to.
  Future<List<int>> addAddress(AddressModel address);

  Future<String> updateAddress(Map<String, dynamic> body, int? id);

  Future<String> deleteAddress(int? id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient apiClient;

  AddressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AddressModel>> getAddresses() async {
    final Response response = await apiClient.getData(
      AppConstants.addressListUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<AddressModel> list = [];
      response.body['addresses'].forEach((address) {
        list.add(AddressModel.fromJson(address));
      });
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<int>> addAddress(AddressModel address) async {
    final Response response = await apiClient.postData(
      AppConstants.addAddressUri,
      address.toJson(),
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<int> zoneIds = [];
      (response.body['zone_ids'] as List?)?.forEach((z) => zoneIds.add(z));
      return zoneIds;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> updateAddress(Map<String, dynamic> body, int? id) async {
    final Response response = await apiClient.putData(
      '${AppConstants.updateAddressUri}$id',
      body,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> deleteAddress(int? id) async {
    final Response response = await apiClient.postData(
      '${AppConstants.removeAddressUri}$id',
      {"_method": "delete"},
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message']?.toString() ?? '';
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
