import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_state.dart';

sealed class BookingCheckoutEvent extends Equatable {
  const BookingCheckoutEvent();

  @override
  List<Object?> get props => [];
}

/// Move the checkout flow to a given page.
class CheckoutPageChanged extends BookingCheckoutEvent {
  final PageState page;
  const CheckoutPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class PaymentMethodSelected extends BookingCheckoutEvent {
  final int index;
  const PaymentMethodSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class CouponSectionToggled extends BookingCheckoutEvent {
  const CouponSectionToggled();
}

class CouponDiscountSet extends BookingCheckoutEvent {
  final double discount;
  const CouponDiscountSet(this.discount);

  @override
  List<Object?> get props => [discount];
}

class PaymentCancelled extends BookingCheckoutEvent {
  const PaymentCancelled();
}

/// Place the trip. On success/failure the bloc sets [actionStatus]; the dialog
/// + navigation run in a `BlocListener`.
class TripPlaced extends BookingCheckoutEvent {
  final UserInformationBody filterBody;
  final Vehicles vehicle;

  const TripPlaced({required this.filterBody, required this.vehicle});

  @override
  List<Object?> get props => [identityHashCode(filterBody), vehicle.id];
}
