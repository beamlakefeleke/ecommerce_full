import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Remote API data source for search. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class SearchRemoteDataSource {
  /// Returns the raw response body map for the search query. Parsing into
  /// [ItemModel] / [StoreModel] happens in the repository/bloc because the
  /// response shape differs between items and stores.
  Future<Map<String, dynamic>> searchItems(String query);
  Future<Map<String, dynamic>> searchStores(String query);
  Future<List<Item>> getSuggestedItems();
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient apiClient;
  SearchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> searchItems(String query) async {
    final Response response = await apiClient.getData(
      '${AppConstants.searchUri}items/search?name=$query&offset=1&limit=50',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body as Map<String, dynamic>;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Map<String, dynamic>> searchStores(String query) async {
    final Response response = await apiClient.getData(
      '${AppConstants.searchUri}stores/search?name=$query&offset=1&limit=50',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body as Map<String, dynamic>;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Item>> getSuggestedItems() async {
    final Response response = await apiClient.getData(
      AppConstants.suggestedItemUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<Item> list = [];
      (response.body as List).forEach(
        (item) => list.add(Item.fromJson(item)),
      );
      return list;
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
