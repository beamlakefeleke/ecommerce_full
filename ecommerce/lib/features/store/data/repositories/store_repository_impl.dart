import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/data/datasources/store_remote_data_source.dart';
import 'package:ecommerce/features/store/data/models/cart_suggested_item_model.dart';
import 'package:ecommerce/features/store/data/models/recommended_product_model.dart';
import 'package:ecommerce/features/store/data/models/store_banner_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/features/store/domain/repositories/store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  StoreRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StoreModel>> getStoreList(
    int offset,
    String filterBy,
  ) => _guard(() => remoteDataSource.getStoreList(offset, filterBy));

  @override
  Future<Either<Failure, List<Store>>> getPopularStoreList(String type) =>
      _guard(() => remoteDataSource.getPopularStoreList(type));

  @override
  Future<Either<Failure, List<Store>>> getLatestStoreList(String type) =>
      _guard(() => remoteDataSource.getLatestStoreList(type));

  @override
  Future<Either<Failure, List<Store>>> getFeaturedStoreList() =>
      _guard(() => remoteDataSource.getFeaturedStoreList());

  @override
  Future<Either<Failure, List<Store>>> getVisitAgainStoreList() =>
      _guard(() => remoteDataSource.getVisitAgainStoreList());

  @override
  Future<Either<Failure, List<Store>>> getRecommendedStoreList() =>
      _guard(() => remoteDataSource.getRecommendedStoreList());

  @override
  Future<Either<Failure, Store>> getStoreDetails(
    String storeID,
    bool fromCart,
    String slug,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  ) => _guard(
    () => remoteDataSource.getStoreDetails(
      storeID,
      fromCart,
      slug,
      languageCode,
      module,
      cacheModuleId,
      moduleId,
    ),
  );

  @override
  Future<Either<Failure, ItemModel>> getStoreItemList(
    int? storeID,
    int offset,
    int? categoryID,
    String type,
  ) => _guard(
    () => remoteDataSource.getStoreItemList(storeID, offset, categoryID, type),
  );

  @override
  Future<Either<Failure, ItemModel>> getStoreSearchItemList(
    String searchText,
    String? storeID,
    int offset,
    String type,
    int? categoryID,
  ) => _guard(
    () => remoteDataSource.getStoreSearchItemList(
      searchText,
      storeID,
      offset,
      type,
      categoryID,
    ),
  );

  @override
  Future<Either<Failure, RecommendedItemModel>> getStoreRecommendedItemList(
    int? storeId,
  ) => _guard(() => remoteDataSource.getStoreRecommendedItemList(storeId));

  @override
  Future<Either<Failure, CartSuggestItemModel>> getCartStoreSuggestedItemList(
    int? storeId,
    String languageCode,
    ModuleModel? module,
    int? cacheModuleId,
    int? moduleId,
  ) => _guard(
    () => remoteDataSource.getCartStoreSuggestedItemList(
      storeId,
      languageCode,
      module,
      cacheModuleId,
      moduleId,
    ),
  );

  @override
  Future<Either<Failure, List<StoreBannerModel>>> getStoreBannerList(
    int? storeId,
  ) => _guard(() => remoteDataSource.getStoreBannerList(storeId));
}
