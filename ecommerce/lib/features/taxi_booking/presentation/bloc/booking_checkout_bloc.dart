import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/taxi_usecases.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_state.dart';

/// Event-driven replacement for the legacy `BookingCheckoutController`.
///
/// No navigation or snackbars here: the place-trip outcome surfaces via
/// [BookingCheckoutState.actionStatus] / [actionMessage] and the UI reacts
/// with a `BlocListener` (payment-complete dialog + status navigation).
class BookingCheckoutBloc
    extends Bloc<BookingCheckoutEvent, BookingCheckoutState> {
  final PlaceTripUseCase placeTrip;

  BookingCheckoutBloc({required this.placeTrip})
    : super(const BookingCheckoutState()) {
    on<CheckoutPageChanged>(_onPageChanged);
    on<PaymentMethodSelected>(_onPaymentMethodSelected);
    on<CouponSectionToggled>(_onCouponSectionToggled);
    on<CouponDiscountSet>(_onCouponDiscountSet);
    on<PaymentCancelled>(_onPaymentCancelled);
    on<TripPlaced>(_onTripPlaced);
  }

  void _onPageChanged(
    CheckoutPageChanged event,
    Emitter<BookingCheckoutState> emit,
  ) => emit(state.copyWith(currentPage: event.page));

  void _onPaymentMethodSelected(
    PaymentMethodSelected event,
    Emitter<BookingCheckoutState> emit,
  ) => emit(state.copyWith(paymentMethodIndex: event.index));

  void _onCouponSectionToggled(
    CouponSectionToggled event,
    Emitter<BookingCheckoutState> emit,
  ) => emit(state.copyWith(showCouponSection: !state.showCouponSection));

  void _onCouponDiscountSet(
    CouponDiscountSet event,
    Emitter<BookingCheckoutState> emit,
  ) => emit(state.copyWith(couponDiscount: event.discount));

  void _onPaymentCancelled(
    PaymentCancelled event,
    Emitter<BookingCheckoutState> emit,
  ) => emit(state.copyWith(cancelPayment: true));

  Future<void> _onTripPlaced(
    TripPlaced event,
    Emitter<BookingCheckoutState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearTripId: true,
        actionStatus: TripActionStatus.inProgress,
        actionMessage: null,
      ),
    );

    final String paymentMethod = state.paymentMethodIndex == 0
        ? 'cash_on_delivery'
        : state.paymentMethodIndex == 1
        ? 'digital_payment'
        : 'wallet';

    final Map<String, String?> body = {
      'start_latitude': event.filterBody.from!.latitude,
      'start_longitude': event.filterBody.from!.longitude,
      'end_latitude': event.filterBody.to!.latitude,
      'end_longitude': event.filterBody.to!.longitude,
      'fare_category': event.filterBody.fareCategory,
      'schedule_at': event.filterBody.rentTime,
      'distance': event.filterBody.distance.toString(),
      'filter_type': event.filterBody.filterType,
      'payment_method': paymentMethod,
      'vehicle_id': event.vehicle.id.toString(),
      'provider_id': event.vehicle.providerId.toString(),
    };

    final result = await placeTrip(body);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: TripActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (tripResult) => emit(
        state.copyWith(
          isLoading: false,
          tripId: tripResult.tripId,
          actionStatus: TripActionStatus.success,
          actionMessage: tripResult.message,
        ),
      ),
    );
  }
}
