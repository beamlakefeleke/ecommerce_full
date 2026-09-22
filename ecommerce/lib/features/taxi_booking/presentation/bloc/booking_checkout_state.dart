import 'package:equatable/equatable.dart';

enum PageState { orderDetails, payment, complete }
enum PaymentMethodName { digitalPayment, cod }

sealed class BookingCheckoutState extends Equatable {
  final PageState currentPage;
  final bool isLoading;
  final PaymentMethodName selectedPaymentMethod;
  final bool showCouponSection;
  final bool cancelPayment;
  final double? couponDiscount;
  final int paymentMethodIndex;
  final int? tripId;

  const BookingCheckoutState({
    required this.currentPage,
    required this.isLoading,
    required this.selectedPaymentMethod,
    required this.showCouponSection,
    required this.cancelPayment,
    this.couponDiscount,
    required this.paymentMethodIndex,
    this.tripId,
  });

  @override
  List<Object?> get props => [
    currentPage,
    isLoading,
    selectedPaymentMethod,
    showCouponSection,
    cancelPayment,
    couponDiscount,
    paymentMethodIndex,
    tripId,
  ];
}

class BookingCheckoutInitial extends BookingCheckoutState {
  const BookingCheckoutInitial({
    PageState currentPage = PageState.orderDetails,
    bool isLoading = false,
    PaymentMethodName selectedPaymentMethod = PaymentMethodName.cod,
    bool showCouponSection = false,
    bool cancelPayment = false,
    double? couponDiscount = 0,
    int paymentMethodIndex = 0,
    int? tripId,
  }) : super(
    currentPage: currentPage,
    isLoading: isLoading,
    selectedPaymentMethod: selectedPaymentMethod,
    showCouponSection: showCouponSection,
    cancelPayment: cancelPayment,
    couponDiscount: couponDiscount,
    paymentMethodIndex: paymentMethodIndex,
    tripId: tripId,
  );
}

class BookingCheckoutUpdated extends BookingCheckoutState {
  const BookingCheckoutUpdated({
    required PageState currentPage,
    required bool isLoading,
    required PaymentMethodName selectedPaymentMethod,
    required bool showCouponSection,
    required bool cancelPayment,
    double? couponDiscount,
    required int paymentMethodIndex,
    int? tripId,
  }) : super(
    currentPage: currentPage,
    isLoading: isLoading,
    selectedPaymentMethod: selectedPaymentMethod,
    showCouponSection: showCouponSection,
    cancelPayment: cancelPayment,
    couponDiscount: couponDiscount,
    paymentMethodIndex: paymentMethodIndex,
    tripId: tripId,
  );
}

class BookingCheckoutError extends BookingCheckoutState {
  final String message;

  const BookingCheckoutError({
    required this.message,
    required PageState currentPage,
    required bool isLoading,
    required PaymentMethodName selectedPaymentMethod,
    required bool showCouponSection,
    required bool cancelPayment,
    double? couponDiscount,
    required int paymentMethodIndex,
    int? tripId,
  }) : super(
    currentPage: currentPage,
    isLoading: isLoading,
    selectedPaymentMethod: selectedPaymentMethod,
    showCouponSection: showCouponSection,
    cancelPayment: cancelPayment,
    couponDiscount: couponDiscount,
    paymentMethodIndex: paymentMethodIndex,
    tripId: tripId,
  );

  @override
  List<Object?> get props => [...super.props, message];
}
