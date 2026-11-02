import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/category/domain/repositories/category_repository.dart';

class SaveInterestUseCase implements UseCase<bool, List<int?>> {
  final CategoryRepository repository;
  SaveInterestUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(List<int?> params) =>
      repository.saveUserInterests(params);
}
