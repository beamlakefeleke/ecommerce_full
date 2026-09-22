import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/favourite/domain/repositories/favourite_repository_new.dart';

class RemoveFavouriteUseCase {
  final FavouriteRepositoryNew _repository;
  const RemoveFavouriteUseCase(this._repository);

  Future<Either<Failure, String>> call(int? id, bool isStore) =>
      _repository.removeFavourite(id, isStore);
}
