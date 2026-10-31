import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';

/// A single cart addon selection: which addon and how many.
class AddOn extends Equatable {
  final int? id;
  final int? quantity;

  const AddOn({this.id, this.quantity});

  AddOn.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      quantity = json['quantity'];

  Map<String, dynamic> toJson() => {'id': id, 'quantity': quantity};

  @override
  List<Object?> get props => [id, quantity];
}

/// Pure domain entity representing one cart entry.
///
/// Mutable fields (`quantity`, `isLoading`) exist because the cart is
/// incrementally updated by still-unmigrated checkout/item code. Once those
/// features migrate those fields will be removed from here and this becomes
/// fully immutable.
class CartItem extends Equatable {
  final int? id;
  final double? price;
  final double? discountedPrice;
  final double? discountAmount;
  final int? quantity;
  final bool? isCampaign;
  final int? stock;
  final int? quantityLimit;
  final Item? item; // Item migrates later; kept as-is
  final List<Variation>? variation;
  final List<List<bool?>>? foodVariations;
  final List<AddOn>? addOnIds;
  final List<AddOns>? addOns;

  const CartItem({
    this.id,
    this.price,
    this.discountedPrice,
    this.discountAmount,
    this.quantity,
    this.isCampaign,
    this.stock,
    this.quantityLimit,
    this.item,
    this.variation,
    this.foodVariations,
    this.addOnIds,
    this.addOns,
  });

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    price: price,
    discountedPrice: discountedPrice,
    discountAmount: discountAmount,
    quantity: quantity ?? this.quantity,
    isCampaign: isCampaign,
    stock: stock,
    quantityLimit: quantityLimit,
    item: item,
    variation: variation,
    foodVariations: foodVariations,
    addOnIds: addOnIds,
    addOns: addOns,
  );

  @override
  List<Object?> get props => [
    id,
    price,
    discountedPrice,
    discountAmount,
    quantity,
    isCampaign,
    stock,
    quantityLimit,
    item,
    variation,
    addOnIds,
  ];
}

/// Totals computed from the cart list.
class CartTotals extends Equatable {
  final double subTotal;
  final double itemPrice;
  final double itemDiscountPrice;
  final double addOns;
  final double variationPrice;
  final List<List<AddOns>> addOnsList;
  final List<bool> availableList;

  const CartTotals({
    this.subTotal = 0,
    this.itemPrice = 0,
    this.itemDiscountPrice = 0,
    this.addOns = 0,
    this.variationPrice = 0,
    this.addOnsList = const [],
    this.availableList = const [],
  });

  @override
  List<Object?> get props => [
    subTotal,
    itemPrice,
    itemDiscountPrice,
    addOns,
    variationPrice,
  ];
}
