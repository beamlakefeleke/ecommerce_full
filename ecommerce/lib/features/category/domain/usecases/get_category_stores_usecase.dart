import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

class GetCategoryStoresParams extends Equatable {
  final String? categoryId;
  final int offset;
  final String type;
  const GetCategoryStoresParams({
    required this.categoryId,
    required this.offset,
    required this.type,
  });
  @override
  List<Object?> get props => [categoryId, offset, type];
}

class GetCategoryStoresUseCase
    implements UseCase<StoreModel, GetCategoryStoresParams> {
  final CategoryRepository repository;
  GetCategoryStoresUseCase(this.repository);

  @override
  Future<Either<Failure, StoreModel>> call(GetCategoryStoresParams params) =>
      repository.getCategoryStores(
        params.categoryId,
        params.offset,
        params.type,
      );
}
