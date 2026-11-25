import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';
import 'package:get/get_connect/connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/data/models/cart_suggested_item_model.dart';
import 'package:ecommerce/features/store/data/models/recommended_product_model.dart';
import 'package:ecommerce/features/store/data/models/store_banner_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/util/app_constants.dart';

abstract class StoreRemoteDataSource {
  Future<StoreModel> getStoreList(int offset, String filterBy);
  Future<List<Store>> getPopularStoreList(String type);
  Future<List<Store>> getLatestStoreList(String type);
  Future<List<Store>> getFeaturedStoreList();
  Future<List<Store>> getVisitAgainStoreList();
  Future<List<Store>> getRecommendedStoreList();
  Future<Store> getStoreDetails(
    String storeID,
    bool fromCart,
    String slug,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  );
  Future<ItemModel> getStoreItemList(
    int? storeID,
    int offset,
    int? categoryID,
    String type,
  );
  Future<ItemModel> getStoreSearchItemList(
    String searchText,
    String? storeID,
    int offset,
    String type,
    int? categoryID,
  );
  Future<RecommendedItemModel> getStoreRecommendedItemList(int? storeId);
  Future<CartSuggestItemModel> getCartStoreSuggestedItemList(
    int? storeId,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  );
  Future<List<StoreBannerModel>> getStoreBannerList(int? storeId);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  StoreRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  // ─── helpers ────────────────────────────────────────────────────────────────

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }

  /// Builds the module list from the user's saved zone data (same logic as the
  /// legacy StoreService.moduleList()).
  List<Modules> _moduleList() {
    final List<Modules> result = [];
    for (final zoneData
        in AddressHelper.getUserAddressFromSharedPref()?.zoneData ?? []) {
      for (final m in zoneData.modules ?? []) {
        result.add(m);
      }
    }
    return result;
  }

  // ─── implementations ────────────────────────────────────────────────────────

  @override
  Future<StoreModel> getStoreList(int offset, String filterBy) async {
    final Response response = await apiClient.getData(
      '${AppConstants.storeUri}/$filterBy?offset=$offset&limit=12',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return StoreModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Store>> getPopularStoreList(String type) async {
    final Response response = await apiClient.getData(
      '${AppConstants.popularStoreUri}?type=$type',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<Store> list = [];
      response.body['stores'].forEach((s) => list.add(Store.fromJson(s)));
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Store>> getLatestStoreList(String type) async {
    final Response response = await apiClient.getData(
      '${AppConstants.latestStoreUri}?type=$type',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<Store> list = [];
      response.body['stores'].forEach((s) => list.add(Store.fromJson(s)));
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Store>> getFeaturedStoreList() async {
    final Response response = await apiClient.getData(
      '${AppConstants.storeUri}/all?featured=1&offset=1&limit=50',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<Store> result = [];
      final List<Modules> moduleList = _moduleList();
      response.body['stores'].forEach((s) {
        final Store store = Store.fromJson(s);
        for (final Modules m in moduleList) {
          if (m.id == store.moduleId && m.pivot?.zoneId == store.zoneId) {
            result.add(store);
            break;
          }
        }
      });
      return result;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Store>> getVisitAgainStoreList() async {
    final Response response = await apiClient.getData(
      AppConstants.visitAgainStoreUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<Store> result = [];
      final List<Modules> moduleList = _moduleList();
      response.body.forEach((s) {
        final Store store = Store.fromJson(s);
        for (final Modules m in moduleList) {
          if (m.id == store.moduleId && m.pivot?.zoneId == store.zoneId) {
            result.add(store);
            break;
          }
        }
      });
      return result;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<Store>> getRecommendedStoreList() async {
    final Response response = await apiClient.getData(
      AppConstants.recommendedStoreUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<Store> list = [];
      response.body['stores'].forEach((s) => list.add(Store.fromJson(s)));
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Store> getStoreDetails(
    String storeID,
    bool fromCart,
    String slug,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  ) async {
    Map<String, String>? header;

    if (fromCart) {
      final addressModel = AddressHelper.getUserAddressFromSharedPref();
      header = apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token),
        addressModel?.zoneIds,
        addressModel?.areaIds,
        languageCode,
        module == null ? cacheModuleId : moduleId,
        addressModel?.latitude,
        addressModel?.longitude,
        setHeader: false,
      );
    }

    if (slug.isNotEmpty) {
      header = apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token),
        [],
        [],
        languageCode,
        0,
        '',
        '',
        setHeader: false,
      );
    }

    final Response response = await apiClient.getData(
      '${AppConstants.storeDetailsUri}${slug.isNotEmpty ? slug : storeID}',
      headers: header,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return Store.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ItemModel> getStoreItemList(
    int? storeID,
    int offset,
    int? categoryID,
    String type,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.storeItemUri}?store_id=$storeID&category_id=$categoryID&offset=$offset&limit=13&type=$type',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<ItemModel> getStoreSearchItemList(
    String searchText,
    String? storeID,
    int offset,
    String type,
    int? categoryID,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.searchUri}items/search?store_id=$storeID&name=$searchText&offset=$offset&limit=10&type=$type&category_id=${categoryID ?? ''}',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ItemModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<RecommendedItemModel> getStoreRecommendedItemList(int? storeId) async {
    final Response response = await apiClient.getData(
      '${AppConstants.storeRecommendedItemUri}?store_id=$storeId&offset=1&limit=50',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return RecommendedItemModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<CartSuggestItemModel> getCartStoreSuggestedItemList(
    int? storeId,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  ) async {
    final addressModel = AddressHelper.getUserAddressFromSharedPref();
    final Map<String, String> header = apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token),
      addressModel?.zoneIds,
      addressModel?.areaIds,
      languageCode,
      module == null ? cacheModuleId : moduleId,
      addressModel?.latitude,
      addressModel?.longitude,
      setHeader: false,
    );
    final Response response = await apiClient.getData(
      '${AppConstants.cartStoreSuggestedItemsUri}?recommended=1&store_id=$storeId&offset=1&limit=50',
      headers: header,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return CartSuggestItemModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<StoreBannerModel>> getStoreBannerList(int? storeId) async {
    final Response response = await apiClient.getData(
      '${AppConstants.storeBannersUri}$storeId',
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<StoreBannerModel> list = [];
      response.body.forEach((b) => list.add(StoreBannerModel.fromJson(b)));
      return list;
    }
    throw _exceptionFor(response);
  }
}
