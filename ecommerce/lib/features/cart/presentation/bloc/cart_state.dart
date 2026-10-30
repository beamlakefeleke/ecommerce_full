import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartModel> cartList;

  // computed totals
  final double subTotal;
  final double itemPrice;
  final double itemDiscountPrice;
  final double addOns;
  final double variationPrice;
  final List<List<AddOns>> addOnsList;
  final List<bool> availableList;

  // ui flags
  final bool addCutlery;
  final int notAvailableIndex;
  final int currentIndex;
  final bool isLoading;

  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cartList = const [],
    this.subTotal = 0,
    this.itemPrice = 0,
    this.itemDiscountPrice = 0,
    this.addOns = 0,
    this.variationPrice = 0,
    this.addOnsList = const [],
    this.availableList = const [],
    this.addCutlery = false,
    this.notAvailableIndex = -1,
    this.currentIndex = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  CartState copyWith({
    CartStatus? status,
    List<CartModel>? cartList,
    double? subTotal,
    double? itemPrice,
    double? itemDiscountPrice,
    double? addOns,
    double? variationPrice,
    List<List<AddOns>>? addOnsList,
    List<bool>? availableList,
    bool? addCutlery,
    int? notAvailableIndex,
    int? currentIndex,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      cartList: cartList ?? this.cartList,
      subTotal: subTotal ?? this.subTotal,
      itemPrice: itemPrice ?? this.itemPrice,
      itemDiscountPrice: itemDiscountPrice ?? this.itemDiscountPrice,
      addOns: addOns ?? this.addOns,
      variationPrice: variationPrice ?? this.variationPrice,
      addOnsList: addOnsList ?? this.addOnsList,
      availableList: availableList ?? this.availableList,
      addCutlery: addCutlery ?? this.addCutlery,
      notAvailableIndex: notAvailableIndex ?? this.notAvailableIndex,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    cartList,
    subTotal,
    itemPrice,
    itemDiscountPrice,
    addOns,
    variationPrice,
    addOnsList,
    availableList,
    addCutlery,
    notAvailableIndex,
    currentIndex,
    isLoading,
    errorMessage,
  ];
}
