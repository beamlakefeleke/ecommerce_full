import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/favourite/data/datasources/favourite_remote_data_source.dart';
import 'package:ecommerce/features/favourite/domain/repositories/favourite_repository_new.dart';

class FavouriteRepositoryImpl implements FavouriteRepositoryNew {
  final FavouriteRemoteDataSource _remote;
  const FavouriteRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFavouriteList() async {
    try {
      final response = await _remote.getFavouriteList();
      if (response.statusCode == 200) {
        return Right(Map<String, dynamic>.from(response.body));
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to load favourites',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addFavourite(int? id, bool isStore) async {
    try {
      final response = await _remote.addFavourite(id, isStore);
      if (response.statusCode == 200) {
        return Right(response.body['message']?.toString() ?? '');
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to add favourite',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> removeFavourite(int? id, bool isStore) async {
    try {
      final response = await _remote.removeFavourite(id, isStore);
      if (response.statusCode == 200) {
        return Right(response.body['message']?.toString() ?? '');
      }
      return Left(
        ServerFailure(
          response.statusText ?? 'Failed to remove favourite',
          statusCode: response.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
