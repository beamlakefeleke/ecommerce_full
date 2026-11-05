import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';

abstract class FavouriteRepository {
  /// Returns the raw decoded body `{ 'item': [...], 'store': [...] }`.
  Future<Either<Failure, Map<String, dynamic>>> getFavouriteList();
  Future<Either<Failure, String>> addFavourite(int? id, bool isStore);
  Future<Either<Failure, String>> removeFavourite(int? id, bool isStore);
}
