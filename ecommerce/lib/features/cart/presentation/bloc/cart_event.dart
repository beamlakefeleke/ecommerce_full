import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

/// Fetch the cart from the online API (called on app start / web login).
class CartDataOnlineRequested extends CartEvent {
  const CartDataOnlineRequested();
}

/// Add or replace a local cart item and sync to shared prefs.
class CartItemAdded extends CartEvent {
  final CartModel cartModel;
  final int? index;
  const CartItemAdded({required this.cartModel, this.index});
  @override
  List<Object?> get props => [cartModel, index];
}

/// Increment or decrement a cart item's quantity and sync online.
class CartItemQuantityUpdated extends CartEvent {
  final bool isIncrement;
  final int cartIndex;
  final int? stock;
  final int? quantityLimit;
  const CartItemQuantityUpdated({
    required this.isIncrement,
    required this.cartIndex,
    this.stock,
    this.quantityLimit,
  });
  @override
  List<Object?> get props => [isIncrement, cartIndex, stock, quantityLimit];
}

/// Remove a single item from the local + online cart.
class CartItemRemoved extends CartEvent {
  final int index;
  final Item? item;
  const CartItemRemoved({required this.index, this.item});
  @override
  List<Object?> get props => [index, item];
}

/// Clear the entire cart locally and online.
class CartCleared extends CartEvent {
  const CartCleared();
}

/// Sync the current local cart to the online API (add).
class CartOnlineSynced extends CartEvent {
  final OnlineCart cart;
  const CartOnlineSynced(this.cart);
  @override
  List<Object?> get props => [cart];
}

/// Update the whole online cart with a new OnlineCart payload.
class CartOnlineUpdated extends CartEvent {
  final OnlineCart cart;
  const CartOnlineUpdated(this.cart);
  @override
  List<Object?> get props => [cart];
}

class CartCutleryToggled extends CartEvent {
  const CartCutleryToggled();
}

class CartNotAvailableIndexSet extends CartEvent {
  final int index;
  const CartNotAvailableIndexSet(this.index);
  @override
  List<Object?> get props => [index];
}

class CartCurrentIndexChanged extends CartEvent {
  final int index;
  const CartCurrentIndexChanged(this.index);
  @override
  List<Object?> get props => [index];
}

/// Force-set the module when the user taps the cross-module banner in cart.
class CartModuleForcefullySet extends CartEvent {
  final int moduleId;
  const CartModuleForcefullySet(this.moduleId);
  @override
  List<Object?> get props => [moduleId];
}
