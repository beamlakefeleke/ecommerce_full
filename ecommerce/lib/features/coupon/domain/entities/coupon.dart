import 'package:equatable/equatable.dart';

/// Pure immutable coupon entity. No JSON, no transport/UI-only fields.
class CouponStore extends Equatable {
  final int? id;
  final String? name;

  const CouponStore({this.id, this.name});

  @override
  List<Object?> get props => [id, name];
}

class Coupon extends Equatable {
  final int? id;
  final String? title;
  final String? code;
  final String? startDate;
  final String? expireDate;
  final double? minPurchase;
  final double? maxDiscount;
  final double? discount;
  final String? discountType;
  final String? couponType;
  final int? limit;
  final String? data;
  final int? storeId;
  final String? createdAt;
  final String? updatedAt;
  final CouponStore? store;

  const Coupon({
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
  });

  @override
  List<Object?> get props => [
    id,
    title,
    code,
    startDate,
    expireDate,
    minPurchase,
    maxDiscount,
    discount,
    discountType,
    couponType,
    limit,
    data,
    storeId,
    createdAt,
    updatedAt,
    store,
  ];
}
