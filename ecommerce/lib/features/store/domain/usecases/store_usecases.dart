import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/data/models/cart_suggested_item_model.dart';
import 'package:ecommerce/features/store/data/models/recommended_product_model.dart';
import 'package:ecommerce/features/store/data/models/store_banner_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/features/store/domain/repositories/store_repository.dart';

// ── Params ───────────────────────────────────────────────────────────────────

class StoreListParams extends Equatable {
  final int offset;
  final String filterBy;
  const StoreListParams({required this.offset, required this.filterBy});
  @override
  List<Object?> get props => [offset, filterBy];
}

class TypeParams extends Equatable {
  final String type;
  const TypeParams(this.type);
  @override
  List<Object?> get props => [type];
}

class StoreDetailsParams extends Equatable {
  final String storeID;
  final bool fromCart;
  final String slug;
  final String languageCode;
  final ModuleModel? module;
  final int? cacheModuleId;
  final int? moduleId;

  const StoreDetailsParams({
    required this.storeID,
    this.fromCart = false,
    this.slug = '',
    required this.languageCode,
    this.module,
    this.cacheModuleId,
    this.moduleId,
  });

  @override
  List<Object?> get props => [
    storeID,
    fromCart,
    slug,
    languageCode,
    module,
    cacheModuleId,
    moduleId,
  ];
}

class StoreItemListParams extends Equatable {
  final int? storeID;
  final int offset;
  final int? categoryID;
  final String type;

  const StoreItemListParams({
    required this.storeID,
    required this.offset,
    this.categoryID,
    required this.type,
  });

  @override
  List<Object?> get props => [storeID, offset, categoryID, type];
}

class StoreSearchItemListParams extends Equatable {
  final String searchText;
  final String? storeID;
  final int offset;
  final String type;
  final int? categoryID;

  const StoreSearchItemListParams({
    required this.searchText,
    this.storeID,
    required this.offset,
    required this.type,
    this.categoryID,
  });

  @override
  List<Object?> get props => [searchText, storeID, offset, type, categoryID];
}

class StoreIdParams extends Equatable {
  final int? storeId;
  const StoreIdParams(this.storeId);
  @override
  List<Object?> get props => [storeId];
}

class CartSuggestedParams extends Equatable {
  final int? storeId;
  final String languageCode;
  final ModuleModel? module;
  final int? cacheModuleId;
  final int? moduleId;

  const CartSuggestedParams({
    this.storeId,
    required this.languageCode,
    this.module,
    this.cacheModuleId,
    this.moduleId,
  });

  @override
  List<Object?> get props => [
    storeId,
    languageCode,
    module,
    cacheModuleId,
    moduleId,
  ];
}

// ── Use cases ────────────────────────────────────────────────────────────────

class GetStoreListUseCase implements UseCase<StoreModel, StoreListParams> {
  final StoreRepository repository;
  GetStoreListUseCase(this.repository);

  @override
  Future<Either<Failure, StoreModel>> call(StoreListParams params) =>
      repository.getStoreList(params.offset, params.filterBy);
}

class GetPopularStoreListUseCase implements UseCase<List<Store>, TypeParams> {
  final StoreRepository repository;
  GetPopularStoreListUseCase(this.repository);

  @override
  Future<Either<Failure, List<Store>>> call(TypeParams params) =>
      repository.getPopularStoreList(params.type);
}

class GetLatestStoreListUseCase implements UseCase<List<Store>, TypeParams> {
  final StoreRepository repository;
  GetLatestStoreListUseCase(this.repository);

  @override
  Future<Either<Failure, List<Store>>> call(TypeParams params) =>
      repository.getLatestStoreList(params.type);
}

class GetFeaturedStoreListUseCase implements UseCase<List<Store>, NoParams> {
  final StoreRepository repository;
  GetFeaturedStoreListUseCase(this.repository);

  @override
  Future<Either<Failure, List<Store>>> call(NoParams params) =>
      repository.getFeaturedStoreList();
}

class GetVisitAgainStoreListUseCase implements UseCase<List<Store>, NoParams> {
  final StoreRepository repository;
  GetVisitAgainStoreListUseCase(this.repository);

  @override
  Future<Either<Failure, List<Store>>> call(NoParams params) =>
      repository.getVisitAgainStoreList();
}

class GetRecommendedStoreListUseCase implements UseCase<List<Store>, NoParams> {
  final StoreRepository repository;
  GetRecommendedStoreListUseCase(this.repository);

  @override
  Future<Either<Failure, List<Store>>> call(NoParams params) =>
      repository.getRecommendedStoreList();
}

class GetStoreDetailsUseCase implements UseCase<Store, StoreDetailsParams> {
  final StoreRepository repository;
  GetStoreDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, Store>> call(StoreDetailsParams params) =>
      repository.getStoreDetails(
        params.storeID,
        params.fromCart,
        params.slug,
        params.languageCode,
        params.module,
        params.cacheModuleId,
        params.moduleId,
      );
}

class GetStoreItemListUseCase
    implements UseCase<ItemModel, StoreItemListParams> {
  final StoreRepository repository;
  GetStoreItemListUseCase(this.repository);

  @override
  Future<Either<Failure, ItemModel>> call(StoreItemListParams params) =>
      repository.getStoreItemList(
        params.storeID,
        params.offset,
        params.categoryID,
        params.type,
      );
}

class GetStoreSearchItemListUseCase
    implements UseCase<ItemModel, StoreSearchItemListParams> {
  final StoreRepository repository;
  GetStoreSearchItemListUseCase(this.repository);

  @override
  Future<Either<Failure, ItemModel>> call(StoreSearchItemListParams params) =>
      repository.getStoreSearchItemList(
        params.searchText,
        params.storeID,
        params.offset,
        params.type,
        params.categoryID,
      );
}

class GetStoreRecommendedItemListUseCase
    implements UseCase<RecommendedItemModel, StoreIdParams> {
  final StoreRepository repository;
  GetStoreRecommendedItemListUseCase(this.repository);

  @override
  Future<Either<Failure, RecommendedItemModel>> call(StoreIdParams params) =>
      repository.getStoreRecommendedItemList(params.storeId);
}

class GetCartStoreSuggestedItemListUseCase
    implements UseCase<CartSuggestItemModel, CartSuggestedParams> {
  final StoreRepository repository;
  GetCartStoreSuggestedItemListUseCase(this.repository);

  @override
  Future<Either<Failure, CartSuggestItemModel>> call(
    CartSuggestedParams params,
  ) => repository.getCartStoreSuggestedItemList(
    params.storeId,
    params.languageCode,
    params.module,
    params.cacheModuleId,
    params.moduleId,
  );
}

class GetStoreBannerListUseCase
    implements UseCase<List<StoreBannerModel>, StoreIdParams> {
  final StoreRepository repository;
  GetStoreBannerListUseCase(this.repository);

  @override
  Future<Either<Failure, List<StoreBannerModel>>> call(StoreIdParams params) =>
      repository.getStoreBannerList(params.storeId);
}
