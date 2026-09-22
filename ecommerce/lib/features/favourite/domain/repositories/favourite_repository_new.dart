import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

abstract class FavouriteRepositoryNew {
  Future<Either<Failure, Map<String, dynamic>>> getFavouriteList();
  Future<Either<Failure, String>> addFavourite(int? id, bool isStore);
  Future<Either<Failure, String>> removeFavourite(int? id, bool isStore);
}
