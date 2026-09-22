import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/favourite/domain/repositories/favourite_repository_new.dart';

class GetFavouriteListUseCase {
  final FavouriteRepositoryNew _repository;
  const GetFavouriteListUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call() =>
      _repository.getFavouriteList();
}
