part of 'coupon_bloc.dart';

sealed class CouponEvent extends Equatable {
  const CouponEvent();

  @override
  List<Object?> get props => [];
}

class CouponListRequested extends CouponEvent {
  const CouponListRequested();
}

class TaxiCouponListRequested extends CouponEvent {
  const TaxiCouponListRequested();
}

class CouponCurrentIndexChanged extends CouponEvent {
  final int index;

  const CouponCurrentIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class CouponApplied extends CouponEvent {
  final String couponCode;
  final double order;
  final double? deliveryCharge;
  final int? storeId;

  const CouponApplied({
    required this.couponCode,
    required this.order,
    this.deliveryCharge,
    this.storeId,
  });

  @override
  List<Object?> get props => [couponCode, order, deliveryCharge, storeId];
}

class TaxiCouponApplied extends CouponEvent {
  final String couponCode;
  final double orderAmount;
  final int? providerId;

  const TaxiCouponApplied({
    required this.couponCode,
    required this.orderAmount,
    this.providerId,
  });

  @override
  List<Object?> get props => [couponCode, orderAmount, providerId];
}

class CouponDataRemoved extends CouponEvent {
  const CouponDataRemoved();
}
