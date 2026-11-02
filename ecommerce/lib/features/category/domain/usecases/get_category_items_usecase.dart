import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';

class GetCategoryItemsParams extends Equatable {
  final String? categoryId;
  final int offset;
  final String type;
  const GetCategoryItemsParams({
    required this.categoryId,
    required this.offset,
    required this.type,
  });
  @override
  List<Object?> get props => [categoryId, offset, type];
}

class GetCategoryItemsUseCase
    implements UseCase<ItemModel, GetCategoryItemsParams> {
  final CategoryRepository repository;
  GetCategoryItemsUseCase(this.repository);

  @override
  Future<Either<Failure, ItemModel>> call(GetCategoryItemsParams params) =>
      repository.getCategoryItems(
        params.categoryId,
        params.offset,
        params.type,
      );
}
