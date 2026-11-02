import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/category/domain/entities/category.dart';
import 'package:ecommerce/features/category/domain/repositories/category_repository.dart';

class GetCategoriesParams extends Equatable {
  final bool allCategory;
  const GetCategoriesParams({this.allCategory = false});
  @override
  List<Object?> get props => [allCategory];
}

class GetCategoriesUseCase
    implements UseCase<List<Category>, GetCategoriesParams> {
  final CategoryRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(GetCategoriesParams params) =>
      repository.getCategories(allCategory: params.allCategory);
}
