import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/favourite/domain/repositories/favourite_repository.dart';
import 'package:ecommerce/features/favourite/domain/usecases/add_favourite_usecase.dart';

class RemoveFavouriteUseCase implements UseCase<String, FavouriteParams> {
  final FavouriteRepository repository;

  RemoveFavouriteUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(FavouriteParams params) {
    return repository.removeFavourite(params.id, params.isStore);
  }
}
