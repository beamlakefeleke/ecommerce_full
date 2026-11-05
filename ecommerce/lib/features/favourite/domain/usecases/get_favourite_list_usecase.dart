import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/favourite/domain/repositories/favourite_repository.dart';

class GetFavouriteListUseCase
    implements UseCase<Map<String, dynamic>, NoParams> {
  final FavouriteRepository repository;

  GetFavouriteListUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) {
    return repository.getFavouriteList();
  }
}
