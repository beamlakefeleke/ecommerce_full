import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  
  @override
  List<Object?> get props => [];
}

class GetCartDataEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final Cart cartModel;
  final int? index;
  const AddToCartEvent(this.cartModel, this.index);
}

class SetQuantityEvent extends CartEvent {
  final bool isIncrement;
  final Cart cart;
  final int cartIndex;
  final bool showMessage;
  const SetQuantityEvent(this.isIncrement, this.cart, this.cartIndex, this.showMessage);
}

class RemoveFromCartEvent extends CartEvent {
  final int cartIndex;
  final Item? item;
  const RemoveFromCartEvent(this.cartIndex, this.item);
}

class ClearCartEvent extends CartEvent {}

class SetAvailableIndexEvent extends CartEvent {
  final int index;
  final bool isUpdate;
  const SetAvailableIndexEvent(this.index, this.isUpdate);
}

class UpdateCutleryEvent extends CartEvent {
  final bool isUpdate;
  const UpdateCutleryEvent(this.isUpdate);
}

class CalculationCartEvent extends CartEvent {}

class ForcefullySetModuleEvent extends CartEvent {
  final int moduleId;
  const ForcefullySetModuleEvent(this.moduleId);
}
