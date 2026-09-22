import 'package:ecommerce/features/item/domain/models/item_model.dart';

import 'package:ecommerce/features/cart/domain/entities/cart.dart';

class CartModel extends Cart {
  CartModel({
    super.id,
    super.price,
    super.discountedPrice,
    super.variation,
    super.foodVariations,
    super.discountAmount,
    super.quantity,
    super.addOnIds,
    super.addOns,
    super.isCampaign,
    super.stock,
    super.item,
    super.quantityLimit,
    super.isLoading = false,
  });

  CartModel.fromJson(Map<String, dynamic> json) {
    id = json['cart_id'];
    price = json['price'].toDouble();
    discountedPrice = json['discounted_price']?.toDouble();
    if (json['variation'] != null) {
      variation = [];
      json['variation'].forEach((v) {
        variation!.add(Variation.fromJson(v));
      });
    }
    if (json['food_variations'] != null) {
      foodVariations = [];
      for (int index = 0; index < json['food_variations'].length; index++) {
        foodVariations!.add([]);
        for (int i = 0; i < json['food_variations'][index].length; i++) {
          foodVariations![index].add(json['food_variations'][index][i]);
        }
      }
    }
    discountAmount = json['discount_amount']?.toDouble();
    quantity = json['quantity'];
    stock = json['stock'];
    if (json['add_on_ids'] != null) {
      addOnIds = [];
      json['add_on_ids'].forEach((v) {
        addOnIds!.add(AddOn.fromJson(v));
      });
    }
    if (json['add_ons'] != null) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOns.fromJson(v));
      });
    }
    isCampaign = json['is_campaign'];
    if (json['item'] != null) {
      item = Item.fromJson(json['item']);
    }
    if (json['quantity_limit'] != null) {
      quantityLimit = int.parse(json['quantity_limit'].toString());
    }
    isLoading = json['is_loading'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = id;
    data['price'] = price;
    data['discounted_price'] = discountedPrice;
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    data['food_variations'] = foodVariations;
    data['discount_amount'] = discountAmount;
    data['quantity'] = quantity;
    if (addOnIds != null) {
      // data['add_on_ids'] = addOnIds;
      data['add_on_ids'] = addOnIds!.map((v) => (v as AddOn).toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['is_campaign'] = isCampaign;
    data['stock'] = stock;
    data['item'] = item!.toJson();
    data['quantity_limit'] = quantityLimit?.toString();
    // data['is_loading'] = isLoading?? false;
    return data;
  }
}

class AddOn extends CartAddOn {
  AddOn({super.id, super.quantity});

  AddOn.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['quantity'] = quantity;
    return data;
  }
}
