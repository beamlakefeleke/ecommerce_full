import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/favourite/domain/repositories/favourite_repository.dart';

class FavouriteParams extends Equatable {
  final int? id;
  final bool isStore;

  const FavouriteParams({required this.id, required this.isStore});

  @override
  List<Object?> get props => [id, isStore];
}

class AddFavouriteUseCase implements UseCase<String, FavouriteParams> {
  final FavouriteRepository repository;

  AddFavouriteUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(FavouriteParams params) {
    return repository.addFavourite(params.id, params.isStore);
  }
}
