import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/category/data/models/category_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:get/get.dart' as getx;

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategoryList({bool allCategory = false});
  Future<List<CategoryModel>> getSubCategoryList(String? parentId);
  Future<ItemModel> getCategoryItemList(
    String? categoryId,
    int offset,
    String type,
  );
  Future<StoreModel> getCategoryStoreList(
    String? categoryId,
    int offset,
    String type,
  );
  Future<Response> getSearchData(
    String? query,
    String? categoryId,
    bool isStore,
    String type,
  );
  Future<bool> saveUserInterests(List<int?> interests);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CategoryModel>> getCategoryList({
    bool allCategory = false,
  }) async {
    final Map<String, String>? headers = allCategory
        ? {
            'Content-Type': 'application/json; charset=UTF-8',
            AppConstants.localizationKey:
                getx.Get.find<LocalizationController>().locale.languageCode,
          }
        : null;
    final Response response = await apiClient.getData(
      AppConstants.categoryUri,
      headers: headers,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return (response.body as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<CategoryModel>> getSubCategoryList(String? parentId) async {
    final Response response = await apiClient.getData(
      '${AppConstants.subCategoryUri}$parentId',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return (response.body as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ItemModel> getCategoryItemList(
    String? categoryId,
    int offset,
    String type,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.categoryItemUri}$categoryId?limit=10&offset=$offset&type=$type',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<StoreModel> getCategoryStoreList(
    String? categoryId,
    int offset,
    String type,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.categoryStoreUri}$categoryId?limit=10&offset=$offset&type=$type',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return StoreModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Response> getSearchData(
    String? query,
    String? categoryId,
    bool isStore,
    String type,
  ) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}${isStore ? 'stores' : 'items'}/search?name=$query&category_id=$categoryId&type=$type&offset=1&limit=50',
      handleError: false,
    );
  }

  @override
  Future<bool> saveUserInterests(List<int?> interests) async {
    final Response response = await apiClient.postData(
      AppConstants.interestUri,
      {'interest': interests},
      handleError: false,
    );
    return response.statusCode == 200;
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
