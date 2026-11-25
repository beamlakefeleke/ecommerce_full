import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/data/models/cart_suggested_item_model.dart';
import 'package:ecommerce/features/store/data/models/recommended_product_model.dart';
import 'package:ecommerce/features/store/data/models/store_banner_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

abstract class StoreRepository {
  Future<Either<Failure, StoreModel>> getStoreList(int offset, String filterBy);
  Future<Either<Failure, List<Store>>> getPopularStoreList(String type);
  Future<Either<Failure, List<Store>>> getLatestStoreList(String type);
  Future<Either<Failure, List<Store>>> getFeaturedStoreList();
  Future<Either<Failure, List<Store>>> getVisitAgainStoreList();
  Future<Either<Failure, List<Store>>> getRecommendedStoreList();
  Future<Either<Failure, Store>> getStoreDetails(
    String storeID,
    bool fromCart,
    String slug,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  );
  Future<Either<Failure, ItemModel>> getStoreItemList(
    int? storeID,
    int offset,
    int? categoryID,
    String type,
  );
  Future<Either<Failure, ItemModel>> getStoreSearchItemList(
    String searchText,
    String? storeID,
    int offset,
    String type,
    int? categoryID,
  );
  Future<Either<Failure, RecommendedItemModel>> getStoreRecommendedItemList(
    int? storeId,
  );
  Future<Either<Failure, CartSuggestItemModel>> getCartStoreSuggestedItemList(
    int? storeId,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  );
  Future<Either<Failure, List<StoreBannerModel>>> getStoreBannerList(
    int? storeId,
  );
}
