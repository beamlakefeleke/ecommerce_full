part of 'favourite_bloc.dart';

sealed class FavouriteEvent extends Equatable {
  const FavouriteEvent();

  @override
  List<Object?> get props => [];
}

class FavouriteListRequested extends FavouriteEvent {
  const FavouriteListRequested();
}

class FavouriteAdded extends FavouriteEvent {
  final Item? product;
  final Store? store;
  final bool isStore;

  const FavouriteAdded({this.product, this.store, required this.isStore});

  @override
  List<Object?> get props => [product, store, isStore];
}

class FavouriteRemoved extends FavouriteEvent {
  final int? id;
  final bool isStore;

  const FavouriteRemoved({required this.id, required this.isStore});

  @override
  List<Object?> get props => [id, isStore];
}

/// Clears the local wish-id lists (used on logout).
class FavouriteCleared extends FavouriteEvent {
  const FavouriteCleared();
}
