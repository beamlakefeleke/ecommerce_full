import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/item/domain/models/basic_medicine_model.dart';
import 'package:ecommerce/features/item/domain/models/common_condition_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/item/domain/repositories/item_repository.dart';

class TypeParams extends Equatable {
  final String type;
  const TypeParams(this.type);
  @override
  List<Object?> get props => [type];
}

class GetPopularItemsUseCase implements UseCase<List<Item>, TypeParams> {
  final ItemRepository repository;
  GetPopularItemsUseCase(this.repository);
  @override
  Future<Either<Failure, List<Item>>> call(TypeParams params) =>
      repository.getPopularItemList(params.type);
}

class GetReviewedItemsUseCase implements UseCase<ItemModel, TypeParams> {
  final ItemRepository repository;
  GetReviewedItemsUseCase(this.repository);
  @override
  Future<Either<Failure, ItemModel>> call(TypeParams params) =>
      repository.getReviewedItemList(params.type);
}

class GetFeaturedCategoriesItemsUseCase
    implements UseCase<ItemModel, NoParams> {
  final ItemRepository repository;
  GetFeaturedCategoriesItemsUseCase(this.repository);
  @override
  Future<Either<Failure, ItemModel>> call(NoParams params) =>
      repository.getFeaturedCategoriesItemList();
}

class GetRecommendedItemsUseCase implements UseCase<List<Item>, TypeParams> {
  final ItemRepository repository;
  GetRecommendedItemsUseCase(this.repository);
  @override
  Future<Either<Failure, List<Item>>> call(TypeParams params) =>
      repository.getRecommendedItemList(params.type);
}

class GetDiscountedItemsUseCase implements UseCase<List<Item>, TypeParams> {
  final ItemRepository repository;
  GetDiscountedItemsUseCase(this.repository);
  @override
  Future<Either<Failure, List<Item>>> call(TypeParams params) =>
      repository.getDiscountedItemList(params.type);
}

class GetItemDetailsParams extends Equatable {
  final int? itemID;
  const GetItemDetailsParams(this.itemID);
  @override
  List<Object?> get props => [itemID];
}

class GetItemDetailsUseCase implements UseCase<Item, GetItemDetailsParams> {
  final ItemRepository repository;
  GetItemDetailsUseCase(this.repository);
  @override
  Future<Either<Failure, Item>> call(GetItemDetailsParams params) =>
      repository.getItemDetails(params.itemID);
}

class GetBasicMedicineUseCase implements UseCase<BasicMedicineModel, NoParams> {
  final ItemRepository repository;
  GetBasicMedicineUseCase(this.repository);
  @override
  Future<Either<Failure, BasicMedicineModel>> call(NoParams params) =>
      repository.getBasicMedicine();
}

class GetCommonConditionsUseCase
    implements UseCase<List<CommonConditionModel>, NoParams> {
  final ItemRepository repository;
  GetCommonConditionsUseCase(this.repository);
  @override
  Future<Either<Failure, List<CommonConditionModel>>> call(NoParams params) =>
      repository.getCommonConditions();
}

class ConditionIdParams extends Equatable {
  final int id;
  const ConditionIdParams(this.id);
  @override
  List<Object?> get props => [id];
}

class GetConditionsWiseItemsUseCase
    implements UseCase<List<Item>, ConditionIdParams> {
  final ItemRepository repository;
  GetConditionsWiseItemsUseCase(this.repository);
  @override
  Future<Either<Failure, List<Item>>> call(ConditionIdParams params) =>
      repository.getConditionsWiseItems(params.id);
}
