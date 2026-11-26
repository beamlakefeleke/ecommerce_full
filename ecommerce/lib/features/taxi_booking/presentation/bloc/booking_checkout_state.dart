import 'package:equatable/equatable.dart';

/// Checkout flow page, mirrors the legacy `PageState`.
enum PageState { orderDetails, payment, complete }

/// Outcome of the place-trip action. The UI reacts via a `BlocListener`
/// (dialog + navigation) and it is reset on the next event.
enum TripActionStatus { none, inProgress, success, failure }

/// Immutable state for the booking-checkout flow (replaces the legacy
/// `BookingCheckoutController`).
class BookingCheckoutState extends Equatable {
  final PageState currentPage;
  final bool isLoading;
  final int paymentMethodIndex;
  final double couponDiscount;
  final bool showCouponSection;
  final bool cancelPayment;
  final int? tripId;

  final TripActionStatus actionStatus;
  final String? actionMessage;

  const BookingCheckoutState({
    this.currentPage = PageState.orderDetails,
    this.isLoading = false,
    this.paymentMethodIndex = 0,
    this.couponDiscount = 0,
    this.showCouponSection = false,
    this.cancelPayment = false,
    this.tripId,
    this.actionStatus = TripActionStatus.none,
    this.actionMessage,
  });

  BookingCheckoutState copyWith({
    PageState? currentPage,
    bool? isLoading,
    int? paymentMethodIndex,
    double? couponDiscount,
    bool? showCouponSection,
    bool? cancelPayment,
    int? tripId,
    bool clearTripId = false,
    TripActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return BookingCheckoutState(
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      paymentMethodIndex: paymentMethodIndex ?? this.paymentMethodIndex,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      showCouponSection: showCouponSection ?? this.showCouponSection,
      cancelPayment: cancelPayment ?? this.cancelPayment,
      tripId: clearTripId ? null : (tripId ?? this.tripId),
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentPage,
    isLoading,
    paymentMethodIndex,
    couponDiscount,
    showCouponSection,
    cancelPayment,
    tripId,
    actionStatus,
    actionMessage,
  ];
}
