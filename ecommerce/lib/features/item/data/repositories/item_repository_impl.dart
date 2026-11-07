import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/item/data/datasources/item_remote_data_source.dart';
import 'package:ecommerce/features/item/domain/models/basic_medicine_model.dart';
import 'package:ecommerce/features/item/domain/models/common_condition_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/item/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remoteDataSource;

  ItemRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getPopularItemList(String type) =>
      _guard(() => remoteDataSource.getPopularItemList(type));

  @override
  Future<Either<Failure, ItemModel>> getReviewedItemList(String type) =>
      _guard(() => remoteDataSource.getReviewedItemList(type));

  @override
  Future<Either<Failure, ItemModel>> getFeaturedCategoriesItemList() =>
      _guard(() => remoteDataSource.getFeaturedCategoriesItemList());

  @override
  Future<Either<Failure, List<Item>>> getRecommendedItemList(String type) =>
      _guard(() => remoteDataSource.getRecommendedItemList(type));

  @override
  Future<Either<Failure, List<Item>>> getDiscountedItemList(String type) =>
      _guard(() => remoteDataSource.getDiscountedItemList(type));

  @override
  Future<Either<Failure, Item>> getItemDetails(int? itemID) =>
      _guard(() => remoteDataSource.getItemDetails(itemID));

  @override
  Future<Either<Failure, BasicMedicineModel>> getBasicMedicine() =>
      _guard(() => remoteDataSource.getBasicMedicine());

  @override
  Future<Either<Failure, List<CommonConditionModel>>> getCommonConditions() =>
      _guard(() => remoteDataSource.getCommonConditions());

  @override
  Future<Either<Failure, List<Item>>> getConditionsWiseItems(int id) =>
      _guard(() => remoteDataSource.getConditionsWiseItems(id));
}
