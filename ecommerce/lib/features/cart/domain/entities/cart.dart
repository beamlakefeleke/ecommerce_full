import 'package:ecommerce/features/item/domain/models/item_model.dart';

class Cart {
  int? id;
  double? price;
  double? discountedPrice;
  List<Variation>? variation;
  List<List<bool?>>? foodVariations;
  double? discountAmount;
  int? quantity;
  List<CartAddOn>? addOnIds;
  List<AddOns>? addOns;
  bool? isCampaign;
  int? stock;
  Item? item;
  int? quantityLimit;
  bool? isLoading;

  Cart({
    this.id,
    this.price,
    this.discountedPrice,
    this.variation,
    this.foodVariations,
    this.discountAmount,
    this.quantity,
    this.addOnIds,
    this.addOns,
    this.isCampaign,
    this.stock,
    this.item,
    this.quantityLimit,
    this.isLoading = false,
  });
}

class CartAddOn {
  int? id;
  int? quantity;

  CartAddOn({this.id, this.quantity});
}
