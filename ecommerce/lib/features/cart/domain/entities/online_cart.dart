import 'package:ecommerce/features/item/domain/models/item_model.dart' as product_variation;

class OnlineCart {
  int? id;
  int? userId;
  int? moduleId;
  int? itemId;
  bool? isGuest;
  List<int>? addOnIds;
  List<int>? addOnQtys;
  String? itemType;
  double? price;
  int? quantity;
  List<OnlineCartVariation>? foodVariation;
  List<product_variation.Variation>? productVariation;
  String? createdAt;
  String? updatedAt;
  product_variation.Item? item;

  OnlineCart({
    this.id,
    this.userId,
    this.moduleId,
    this.itemId,
    this.isGuest,
    this.addOnIds,
    this.addOnQtys,
    this.itemType,
    this.price,
    this.quantity,
    this.foodVariation,
    this.productVariation,
    this.createdAt,
    this.updatedAt,
    this.item,
  });
}

class OnlineCartVariation {
  String? name;
  OnlineCartVariationValue? values;

  OnlineCartVariation({this.name, this.values});
}

class OnlineCartVariationValue {
  List<String>? label;

  OnlineCartVariationValue({this.label});
}
