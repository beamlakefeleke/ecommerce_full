import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';

sealed class ParcelEvent {}

class GetParcelCategoryListEvent extends ParcelEvent {}

class GetWhyChooseDetailsEvent extends ParcelEvent {}

class GetVideoContentDetailsEvent extends ParcelEvent {}

class GetParcelInstructionEvent extends ParcelEvent {}

class GetOfflineMethodListEvent extends ParcelEvent {}

class GetDmTipMostTappedEvent extends ParcelEvent {}

class SetPickupAddressEvent extends ParcelEvent {
  final AddressModel? address;
  SetPickupAddressEvent(this.address);
}

class SetDestinationAddressEvent extends ParcelEvent {
  final AddressModel? address;
  SetDestinationAddressEvent(this.address);
}

class SetIsPickedUpEvent extends ParcelEvent {
  final bool isPickedUp;
  SetIsPickedUpEvent(this.isPickedUp);
}

class SetIsSenderEvent extends ParcelEvent {
  final bool isSender;
  SetIsSenderEvent(this.isSender);
}

class SetLocationFromPlaceEvent extends ParcelEvent {
  final String? placeId;
  final String? address;
  final bool isPickedUp;
  SetLocationFromPlaceEvent({this.placeId, this.address, required this.isPickedUp});
}

class GetDistanceEvent extends ParcelEvent {
  final AddressModel pickupAddress;
  final AddressModel destinationAddress;
  GetDistanceEvent({required this.pickupAddress, required this.destinationAddress});
}

class SetPayerIndexEvent extends ParcelEvent {
  final int index;
  SetPayerIndexEvent(this.index);
}

class SetPaymentIndexEvent extends ParcelEvent {
  final int index;
  SetPaymentIndexEvent(this.index);
}

class ToggleTermsEvent extends ParcelEvent {}

class SelectOfflineBankEvent extends ParcelEvent {
  final int index;
  SelectOfflineBankEvent(this.index);
}

class ChangeDigitalPaymentNameEvent extends ParcelEvent {
  final String name;
  ChangeDigitalPaymentNameEvent(this.name);
}

class SetInstructionSelectedIndexEvent extends ParcelEvent {
  final int index;
  SetInstructionSelectedIndexEvent(this.index);
}

class SetCustomNoteEvent extends ParcelEvent {
  final String note;
  SetCustomNoteEvent(this.note);
}

class SetSelectedIndexNoteEvent extends ParcelEvent {
  final int? index;
  SetSelectedIndexNoteEvent(this.index);
}

class SetSenderAddressIndexEvent extends ParcelEvent {
  final int? index;
  SetSenderAddressIndexEvent(this.index);
}

class SetReceiverAddressIndexEvent extends ParcelEvent {
  final int? index;
  SetReceiverAddressIndexEvent(this.index);
}

class SetCountryCodeEvent extends ParcelEvent {
  final String code;
  final bool isSender;
  SetCountryCodeEvent({required this.code, required this.isSender});
}

class ShowTipsFieldEvent extends ParcelEvent {}

class UpdateTipsEvent extends ParcelEvent {
  final int index;
  UpdateTipsEvent(this.index);
}

class ToggleDmTipSaveEvent extends ParcelEvent {}

class AddTipsEvent extends ParcelEvent {
  final double tips;
  AddTipsEvent(this.tips);
}

class PlaceOrderEvent extends ParcelEvent {
  final PlaceOrderBodyModel placeOrderBody;
  final int? zoneID;
  final double amount;
  final double? maximumCodOrderAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;
  final bool forParcel;
  final bool isOfflinePay;

  PlaceOrderEvent({
    required this.placeOrderBody,
    this.zoneID,
    required this.amount,
    this.maximumCodOrderAmount,
    required this.fromCart,
    required this.isCashOnDeliveryActive,
    this.forParcel = false,
    this.isOfflinePay = false,
  });
}

class SetLoadingEvent extends ParcelEvent {
  final bool isLoading;
  SetLoadingEvent(this.isLoading);
}
