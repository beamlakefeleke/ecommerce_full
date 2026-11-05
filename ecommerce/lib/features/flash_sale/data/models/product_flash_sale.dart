import 'package:ecommerce/features/flash_sale/data/models/flash_sale_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';

class ProductFlashSale {
  int? totalSize;
  int? limit;
  int? offset;
  FlashSaleModel? flashSale;
  List<Products>? products;

  ProductFlashSale({
    this.totalSize,
    this.limit,
    this.offset,
    this.flashSale,
    this.products,
  });

  ProductFlashSale.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = int.parse(json['limit'].toString());
    offset = int.parse(json['offset'].toString());
    flashSale = json['flash_sale'] != null
        ? FlashSaleModel.fromJson(json['flash_sale'])
        : null;
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (flashSale != null) {
      data['flash_sale'] = flashSale!.toJson();
    }
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  int? id;
  int? flashSaleId;
  int? itemId;
  int? stock;
  int? sold;
  int? availableStock;
  String? discountType;
  double? discount;
  double? discountAmount;
  double? price;
  int? status;
  String? createdAt;
  String? updatedAt;
  Item? item;

  Products({
    this.id,
    this.flashSaleId,
    this.itemId,
    this.stock,
    this.sold,
    this.availableStock,
    this.discountType,
    this.discount,
    this.discountAmount,
    this.price,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.item,
  });

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    flashSaleId = json['flash_sale_id'];
    itemId = json['item_id'];
    stock = json['stock'];
    sold = json['sold'];
    availableStock = json['available_stock'];
    discountType = json['discount_type'];
    discount = json['discount']?.toDouble();
    discountAmount = json['discount_amount']?.toDouble();
    price = json['price']?.toDouble();
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    item = json['item'] != null ? Item.fromJson(json['item']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['flash_sale_id'] = flashSaleId;
    data['item_id'] = itemId;
    data['stock'] = stock;
    data['sold'] = sold;
    data['available_stock'] = availableStock;
    data['discount_type'] = discountType;
    data['discount'] = discount;
    data['discount_amount'] = discountAmount;
    data['price'] = price;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (item != null) {
      data['item'] = item!.toJson();
    }
    return data;
  }
}
