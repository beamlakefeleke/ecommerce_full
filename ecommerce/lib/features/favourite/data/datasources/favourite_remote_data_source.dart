import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the favourite feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class FavouriteRemoteDataSource {
  /// Returns the raw decoded body `{ 'item': [...], 'store': [...] }`.
  Future<Map<String, dynamic>> getFavouriteList();
  Future<String> addFavourite(int? id, bool isStore);
  Future<String> removeFavourite(int? id, bool isStore);
}

class FavouriteRemoteDataSourceImpl implements FavouriteRemoteDataSource {
  final ApiClient apiClient;

  FavouriteRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getFavouriteList() async {
    final Response response = await apiClient.getData(
      AppConstants.wishListGetUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> addFavourite(int? id, bool isStore) async {
    final Response response = await apiClient.postData(
      '${AppConstants.addWishListUri}${isStore ? 'store_id=' : 'item_id='}$id',
      null,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message'] ?? '';
    }
    throw _exceptionFor(response);
  }

  @override
  Future<String> removeFavourite(int? id, bool isStore) async {
    final Response response = await apiClient.deleteData(
      '${AppConstants.removeWishListUri}${isStore ? 'store_id=' : 'item_id='}$id',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['message'] ?? '';
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
