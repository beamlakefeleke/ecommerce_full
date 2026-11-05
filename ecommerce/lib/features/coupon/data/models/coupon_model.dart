import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ecommerce/features/coupon/domain/entities/coupon.dart';

/// Serializable coupon model. Owns JSON + entity mapping. Kept mutable and
/// carries the UI-only [toolTip] because presentation widgets (coupon card)
/// attach/show a tooltip controller on each coupon instance.
class CouponModel {
  int? id;
  String? title;
  String? code;
  String? startDate;
  String? expireDate;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  String? couponType;
  int? limit;
  String? data;
  int? storeId;
  String? createdAt;
  String? updatedAt;
  Store? store;
  JustTheController? toolTip;

  CouponModel({
    this.id,
    this.title,
    this.code,
    this.startDate,
    this.expireDate,
    this.minPurchase,
    this.maxDiscount,
    this.discount,
    this.discountType,
    this.couponType,
    this.limit,
    this.data,
    this.storeId,
    this.createdAt,
    this.updatedAt,
    this.store,
    this.toolTip,
  });

  CouponModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    startDate = json['start_date'];
    expireDate = json['expire_date'];
    minPurchase = json['min_purchase'].toDouble();
    maxDiscount = json['max_discount'].toDouble();
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    couponType = json['coupon_type'];
    limit = json['limit'];
    data = json['data'];
    storeId = json['store_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['store'] != null) {
      store = Store.fromJson(json['store']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['code'] = code;
    data['start_date'] = startDate;
    data['expire_date'] = expireDate;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['coupon_type'] = couponType;
    data['limit'] = limit;
    data['data'] = this.data;
    data['store_id'] = storeId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  Coupon toEntity() => Coupon(
    id: id,
    title: title,
    code: code,
    startDate: startDate,
    expireDate: expireDate,
    minPurchase: minPurchase,
    maxDiscount: maxDiscount,
    discount: discount,
    discountType: discountType,
    couponType: couponType,
    limit: limit,
    data: data,
    storeId: storeId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    store: store == null ? null : CouponStore(id: store!.id, name: store!.name),
  );

  factory CouponModel.fromEntity(Coupon coupon) => CouponModel(
    id: coupon.id,
    title: coupon.title,
    code: coupon.code,
    startDate: coupon.startDate,
    expireDate: coupon.expireDate,
    minPurchase: coupon.minPurchase,
    maxDiscount: coupon.maxDiscount,
    discount: coupon.discount,
    discountType: coupon.discountType,
    couponType: coupon.couponType,
    limit: coupon.limit,
    data: coupon.data,
    storeId: coupon.storeId,
    createdAt: coupon.createdAt,
    updatedAt: coupon.updatedAt,
    store: coupon.store == null
        ? null
        : Store(id: coupon.store!.id, name: coupon.store!.name),
  );
}

class Store {
  int? id;
  String? name;

  Store({this.id, this.name});

  Store.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
