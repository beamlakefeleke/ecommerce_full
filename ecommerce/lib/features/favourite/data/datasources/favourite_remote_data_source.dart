import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/util/app_constants.dart';

class FavouriteRemoteDataSource {
  final ApiClient _apiClient;
  const FavouriteRemoteDataSource(this._apiClient);

  Future<Response> getFavouriteList() =>
      _apiClient.getData(AppConstants.wishListGetUri);

  Future<Response> addFavourite(int? id, bool isStore) => _apiClient.postData(
    '${AppConstants.addWishListUri}${isStore ? 'store_id=' : 'item_id='}$id',
    null,
    handleError: false,
  );

  Future<Response> removeFavourite(
    int? id,
    bool isStore,
  ) => _apiClient.deleteData(
    '${AppConstants.removeWishListUri}${isStore ? 'store_id=' : 'item_id='}$id',
    handleError: false,
  );
}
