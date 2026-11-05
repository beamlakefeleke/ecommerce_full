import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class CheckoutInitialized extends CheckoutEvent {
  final Store store;
  const CheckoutInitialized(this.store);
  @override
  List<Object?> get props => [store];
}

class CheckoutTimeSlotInitialized extends CheckoutEvent {
  final Store store;
  const CheckoutTimeSlotInitialized(this.store);
  @override
  List<Object?> get props => [store];
}

class CheckoutPrevDataCleared extends CheckoutEvent {
  const CheckoutPrevDataCleared();
}

class CheckoutOrderTypeChanged extends CheckoutEvent {
  final String? orderType;
  const CheckoutOrderTypeChanged(this.orderType);
  @override
  List<Object?> get props => [orderType];
}

class CheckoutPaymentMethodSet extends CheckoutEvent {
  final int index;
  const CheckoutPaymentMethodSet(this.index);
  @override
  List<Object?> get props => [index];
}

class CheckoutDigitalPaymentNameChanged extends CheckoutEvent {
  final String name;
  const CheckoutDigitalPaymentNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class CheckoutPartialPaymentToggled extends CheckoutEvent {
  const CheckoutPartialPaymentToggled();
}

class CheckoutAddressIndexSet extends CheckoutEvent {
  final int? index;
  const CheckoutAddressIndexSet(this.index);
  @override
  List<Object?> get props => [index];
}

class CheckoutGuestAddressSet extends CheckoutEvent {
  final AddressModel? address;
  const CheckoutGuestAddressSet(this.address);
  @override
  List<Object?> get props => [address];
}

class CheckoutDmTipMostTappedRequested extends CheckoutEvent {
  const CheckoutDmTipMostTappedRequested();
}

class CheckoutPreferableTimeSet extends CheckoutEvent {
  final String time;
  const CheckoutPreferableTimeSet(this.time);
  @override
  List<Object?> get props => [time];
}

class CheckoutOfflineMethodsRequested extends CheckoutEvent {
  const CheckoutOfflineMethodsRequested();
}

class CheckoutTipsIndexUpdated extends CheckoutEvent {
  final int index;
  const CheckoutTipsIndexUpdated(this.index);
  @override
  List<Object?> get props => [index];
}

class CheckoutTipsAmountChanged extends CheckoutEvent {
  final double tips;
  const CheckoutTipsAmountChanged(this.tips);
  @override
  List<Object?> get props => [tips];
}

class CheckoutTipsFieldToggled extends CheckoutEvent {
  const CheckoutTipsFieldToggled();
}

class CheckoutDmTipSaveToggled extends CheckoutEvent {
  const CheckoutDmTipSaveToggled();
}

class CheckoutDistanceRequested extends CheckoutEvent {
  final LatLng origin;
  final LatLng destination;
  final bool isDuration;
  final bool fromDashboard;
  const CheckoutDistanceRequested({
    required this.origin,
    required this.destination,
    this.isDuration = false,
    this.fromDashboard = false,
  });
  @override
  List<Object?> get props => [origin, destination, isDuration, fromDashboard];
}

class CheckoutOfflineBankSelected extends CheckoutEvent {
  final int index;
  const CheckoutOfflineBankSelected(this.index);
  @override
  List<Object?> get props => [index];
}

class CheckoutInstructionSet extends CheckoutEvent {
  final int index;
  const CheckoutInstructionSet(this.index);
  @override
  List<Object?> get props => [index];
}

class CheckoutAttachmentPicked extends CheckoutEvent {
  const CheckoutAttachmentPicked();
}

class CheckoutPrescriptionImagePicked extends CheckoutEvent {
  final bool isRemove;
  final bool isCamera;
  const CheckoutPrescriptionImagePicked({
    required this.isRemove,
    required this.isCamera,
  });
  @override
  List<Object?> get props => [isRemove, isCamera];
}

class CheckoutPrescriptionImageRemoved extends CheckoutEvent {
  final int index;
  const CheckoutPrescriptionImageRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class CheckoutExpandToggled extends CheckoutEvent {
  const CheckoutExpandToggled();
}

class CheckoutExpandedUpdated extends CheckoutEvent {
  final bool status;
  const CheckoutExpandedUpdated(this.status);
  @override
  List<Object?> get props => [status];
}

class CheckoutDateSlotUpdated extends CheckoutEvent {
  final int index;
  final int? interval;
  const CheckoutDateSlotUpdated(this.index, this.interval);
  @override
  List<Object?> get props => [index, interval];
}

class CheckoutTimeSlotUpdated extends CheckoutEvent {
  final int index;
  const CheckoutTimeSlotUpdated(this.index);
  @override
  List<Object?> get props => [index];
}

class CheckoutTotalAmountSet extends CheckoutEvent {
  final double amount;
  const CheckoutTotalAmountSet(this.amount);
  @override
  List<Object?> get props => [amount];
}

class CheckoutCountryDialCodeChanged extends CheckoutEvent {
  final String? dialCode;
  const CheckoutCountryDialCodeChanged(this.dialCode);
  @override
  List<Object?> get props => [dialCode];
}

/// Place a normal order. Side-effects (navigation, clearing cart) are handled
/// in the UI via a BlocListener reacting to [CheckoutState.placeOrderResult].
class CheckoutOrderPlaced extends CheckoutEvent {
  final PlaceOrderBodyModel body;
  final bool isOfflinePay;
  const CheckoutOrderPlaced({required this.body, this.isOfflinePay = false});
  @override
  List<Object?> get props => [body, isOfflinePay];
}

class CheckoutPrescriptionOrderPlaced extends CheckoutEvent {
  final int? storeId;
  final double? distance;
  final String address;
  final String longitude;
  final String latitude;
  final String note;
  final List<XFile> orderAttachment;
  final String dmTips;
  final String deliveryInstruction;
  const CheckoutPrescriptionOrderPlaced({
    required this.storeId,
    required this.distance,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.note,
    required this.orderAttachment,
    required this.dmTips,
    required this.deliveryInstruction,
  });
  @override
  List<Object?> get props => [storeId, address, latitude, longitude];
}
