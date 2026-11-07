import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/item/domain/models/basic_medicine_model.dart';
import 'package:ecommerce/features/item/domain/models/common_condition_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';

abstract class ItemRepository {
  Future<Either<Failure, List<Item>>> getPopularItemList(String type);
  Future<Either<Failure, ItemModel>> getReviewedItemList(String type);
  Future<Either<Failure, ItemModel>> getFeaturedCategoriesItemList();
  Future<Either<Failure, List<Item>>> getRecommendedItemList(String type);
  Future<Either<Failure, List<Item>>> getDiscountedItemList(String type);
  Future<Either<Failure, Item>> getItemDetails(int? itemID);
  Future<Either<Failure, BasicMedicineModel>> getBasicMedicine();
  Future<Either<Failure, List<CommonConditionModel>>> getCommonConditions();
  Future<Either<Failure, List<Item>>> getConditionsWiseItems(int id);
}
