import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

sealed class FavouriteEvent {
  const FavouriteEvent();
}

class FavouriteListFetched extends FavouriteEvent {
  const FavouriteListFetched();
}

class FavouriteAdded extends FavouriteEvent {
  final Item? item;
  final Store? store;
  final bool isStore;
  const FavouriteAdded({this.item, this.store, required this.isStore});
}

class FavouriteRemoved extends FavouriteEvent {
  final int? id;
  final bool isStore;
  const FavouriteRemoved({required this.id, required this.isStore});
}

class FavouriteLocalCleared extends FavouriteEvent {
  const FavouriteLocalCleared();
}
