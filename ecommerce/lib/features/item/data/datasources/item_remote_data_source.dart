import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/item/domain/models/basic_medicine_model.dart';
import 'package:ecommerce/features/item/domain/models/common_condition_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the item feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s.
abstract class ItemRemoteDataSource {
  Future<List<Item>> getPopularItemList(String type);
  Future<ItemModel> getReviewedItemList(String type);
  Future<ItemModel> getFeaturedCategoriesItemList();
  Future<List<Item>> getRecommendedItemList(String type);
  Future<List<Item>> getDiscountedItemList(String type);
  Future<Item> getItemDetails(int? itemID);
  Future<BasicMedicineModel> getBasicMedicine();
  Future<List<CommonConditionModel>> getCommonConditions();
  Future<List<Item>> getConditionsWiseItems(int id);
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final ApiClient apiClient;

  ItemRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Item>> getPopularItemList(String type) async {
    final Response response = await apiClient.getData(
      '${AppConstants.popularItemUri}?type=$type',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body).items ?? [];
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ItemModel> getReviewedItemList(String type) async {
    final Response response = await apiClient.getData(
      '${AppConstants.reviewedItemUri}?type=$type',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ItemModel> getFeaturedCategoriesItemList() async {
    final Response response = await apiClient.getData(
      '${AppConstants.featuredCategoriesItemsUri}?limit=30&offset=1',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Item>> getRecommendedItemList(String type) async {
    final Response response = await apiClient.getData(
      '${AppConstants.recommendedItemsUri}$type&limit=30',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body).items ?? [];
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Item>> getDiscountedItemList(String type) async {
    final Response response = await apiClient.getData(
      '${AppConstants.discountedItemsUri}?type=$type&offset=1&limit=50',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body).items ?? [];
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Item> getItemDetails(int? itemID) async {
    final Response response = await apiClient.getData(
      '${AppConstants.itemDetailsUri}$itemID',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return Item.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<BasicMedicineModel> getBasicMedicine() async {
    final Response response = await apiClient.getData(
      '${AppConstants.basicMedicineUri}?offset=1&limit=50',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return BasicMedicineModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<CommonConditionModel>> getCommonConditions() async {
    final Response response = await apiClient.getData(
      AppConstants.commonConditionUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<CommonConditionModel> conditions = [];
      response.body.forEach(
        (c) => conditions.add(CommonConditionModel.fromJson(c)),
      );
      return conditions;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Item>> getConditionsWiseItems(int id) async {
    final Response response = await apiClient.getData(
      '${AppConstants.conditionWiseItemUri}$id?limit=15&offset=1',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body).items ?? [];
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
