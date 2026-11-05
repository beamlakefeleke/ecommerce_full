part of 'coupon_bloc.dart';

class CouponState extends Equatable {
  /// null = not yet loaded (UI shows a spinner); empty = loaded, no coupons.
  final List<CouponModel>? couponList;
  final List<CouponModel>? taxiCouponList;

  /// The currently applied coupon (null when none / removed).
  final CouponModel? coupon;
  final double? discount;
  final bool isLoading;
  final bool freeDelivery;
  final int currentIndex;

  /// Transient message to surface in a snackbar; cleared on the next action.
  final String? message;
  final bool messageIsError;

  const CouponState({
    this.couponList,
    this.taxiCouponList,
    this.coupon,
    this.discount = 0.0,
    this.isLoading = false,
    this.freeDelivery = false,
    this.currentIndex = 0,
    this.message,
    this.messageIsError = true,
  });

  CouponState copyWith({
    List<CouponModel>? couponList,
    List<CouponModel>? taxiCouponList,
    CouponModel? coupon,
    double? discount,
    bool? isLoading,
    bool? freeDelivery,
    int? currentIndex,
    String? message,
    bool? messageIsError,
    bool clearCoupon = false,
    bool clearMessage = false,
  }) {
    return CouponState(
      couponList: couponList ?? this.couponList,
      taxiCouponList: taxiCouponList ?? this.taxiCouponList,
      coupon: clearCoupon ? null : (coupon ?? this.coupon),
      discount: discount ?? this.discount,
      isLoading: isLoading ?? this.isLoading,
      freeDelivery: freeDelivery ?? this.freeDelivery,
      currentIndex: currentIndex ?? this.currentIndex,
      message: clearMessage ? null : (message ?? this.message),
      messageIsError: messageIsError ?? this.messageIsError,
    );
  }

  @override
  List<Object?> get props => [
    couponList,
    taxiCouponList,
    coupon,
    discount,
    isLoading,
    freeDelivery,
    currentIndex,
    message,
    messageIsError,
  ];
}
