import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/category/data/datasources/category_remote_data_source.dart';
import 'package:ecommerce/features/category/domain/entities/category.dart';
import 'package:ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    bool allCategory = false,
  }) => _guard(
    () async => (await remoteDataSource.getCategoryList(
      allCategory: allCategory,
    )).map((m) => m.toEntity()).toList(),
  );

  @override
  Future<Either<Failure, List<Category>>> getSubCategories(String? parentId) =>
      _guard(
        () async => (await remoteDataSource.getSubCategoryList(
          parentId,
        )).map((m) => m.toEntity()).toList(),
      );

  @override
  Future<Either<Failure, ItemModel>> getCategoryItems(
    String? categoryId,
    int offset,
    String type,
  ) => _guard(
    () => remoteDataSource.getCategoryItemList(categoryId, offset, type),
  );

  @override
  Future<Either<Failure, StoreModel>> getCategoryStores(
    String? categoryId,
    int offset,
    String type,
  ) => _guard(
    () => remoteDataSource.getCategoryStoreList(categoryId, offset, type),
  );

  @override
  Future<Either<Failure, dynamic>> searchData(
    String? query,
    String? categoryId,
    bool isStore,
    String type,
  ) async {
    try {
      final response = await remoteDataSource.getSearchData(
        query,
        categoryId,
        isStore,
        type,
      );
      if (response.statusCode == 200) {
        return Right(
          isStore
              ? StoreModel.fromJson(response.body)
              : ItemModel.fromJson(response.body),
        );
      }
      return Left(ServerFailure(response.statusText ?? 'Server error'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveUserInterests(List<int?> interests) =>
      _guard(() => remoteDataSource.saveUserInterests(interests));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
