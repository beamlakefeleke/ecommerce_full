import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/category/domain/entities/category.dart';
import 'package:ecommerce/features/category/domain/repositories/category_repository.dart';

class GetSubCategoriesUseCase implements UseCase<List<Category>, String?> {
  final CategoryRepository repository;
  GetSubCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(String? params) =>
      repository.getSubCategories(params);
}
