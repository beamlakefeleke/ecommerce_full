import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/domain/entities/vehicle.dart';
import 'booking_checkout_state.dart';

sealed class BookingCheckoutEvent extends Equatable {
  const BookingCheckoutEvent();

  @override
  List<Object?> get props => [];
}

class SetPaymentMethodEvent extends BookingCheckoutEvent {
  final int index;
  final bool isUpdate;

  const SetPaymentMethodEvent({required this.index, this.isUpdate = true});

  @override
  List<Object?> get props => [index, isUpdate];
}

class ShowHideCouponEvent extends BookingCheckoutEvent {}

class SetCouponDiscountEvent extends BookingCheckoutEvent {
  final double? discount;

  const SetCouponDiscountEvent({this.discount});

  @override
  List<Object?> get props => [discount];
}

class CancelPaymentOptionEvent extends BookingCheckoutEvent {}

class UpdateStateEvent extends BookingCheckoutEvent {
  final PageState currentPage;
  final bool shouldUpdate;

  const UpdateStateEvent({required this.currentPage, this.shouldUpdate = true});

  @override
  List<Object?> get props => [currentPage, shouldUpdate];
}

class UpdateDigitalPaymentOptionEvent extends BookingCheckoutEvent {
  final PaymentMethodName paymentMethodName;
  final bool shouldUpdate;

  const UpdateDigitalPaymentOptionEvent({required this.paymentMethodName, this.shouldUpdate = true});

  @override
  List<Object?> get props => [paymentMethodName, shouldUpdate];
}

class PlaceTripEvent extends BookingCheckoutEvent {
  final UserInformationBody filterBody;
  final VehicleEntity vehicle;

  const PlaceTripEvent({required this.filterBody, required this.vehicle});

  @override
  List<Object?> get props => [filterBody, vehicle];
}
