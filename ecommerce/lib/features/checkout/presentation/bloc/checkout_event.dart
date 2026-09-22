import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

sealed class CheckoutEvent {
  const CheckoutEvent();
}

// ─── Initialisation ──────────────────────────────────────────────────────────

/// Load store details + time slots + most-tipped dm amount.
class CheckoutInitialised extends CheckoutEvent {
  final int? storeId;
  const CheckoutInitialised({required this.storeId});
}

// ─── Time slots ───────────────────────────────────────────────────────────────

class TimeSlotsInitialised extends CheckoutEvent {
  final Store store;
  final int scheduleSlotDuration;
  const TimeSlotsInitialised({
    required this.store,
    required this.scheduleSlotDuration,
  });
}

class DateSlotSelected extends CheckoutEvent {
  final int index;
  final int? interval;
  const DateSlotSelected({required this.index, this.interval});
}

class TimeSlotSelected extends CheckoutEvent {
  final int index;
  const TimeSlotSelected({required this.index});
}

// ─── Distance & extra charge ─────────────────────────────────────────────────

class DistanceCalculated extends CheckoutEvent {
  final LatLng origin;
  final LatLng destination;
  const DistanceCalculated({required this.origin, required this.destination});
}

// ─── Tips ─────────────────────────────────────────────────────────────────────

class MostTippedAmountFetched extends CheckoutEvent {
  const MostTippedAmountFetched();
}

class TipUpdated extends CheckoutEvent {
  final int tipIndex;
  const TipUpdated({required this.tipIndex});
}

class CustomTipSet extends CheckoutEvent {
  final double amount;
  const CustomTipSet({required this.amount});
}

class TipsFieldToggled extends CheckoutEvent {
  const TipsFieldToggled();
}

class DmTipSaveToggled extends CheckoutEvent {
  const DmTipSaveToggled();
}

// ─── Offline payment ─────────────────────────────────────────────────────────

class OfflineMethodListFetched extends CheckoutEvent {
  const OfflineMethodListFetched();
}

class OfflineBankSelected extends CheckoutEvent {
  final int index;
  const OfflineBankSelected({required this.index});
}

// ─── Payment & order type ─────────────────────────────────────────────────────

class PaymentMethodSet extends CheckoutEvent {
  final int index;
  const PaymentMethodSet({required this.index});
}

class DigitalPaymentNameChanged extends CheckoutEvent {
  final String name;
  const DigitalPaymentNameChanged({required this.name});
}

class OrderTypeSet extends CheckoutEvent {
  final String? type;
  const OrderTypeSet({required this.type});
}

class PartialPaymentToggled extends CheckoutEvent {
  const PartialPaymentToggled();
}

// ─── Address ──────────────────────────────────────────────────────────────────

class AddressIndexSet extends CheckoutEvent {
  final int? index;
  const AddressIndexSet({required this.index});
}

class GuestAddressSet extends CheckoutEvent {
  final AddressModel? address;
  const GuestAddressSet({required this.address});
}

// ─── Attachments ──────────────────────────────────────────────────────────────

class PrescriptionImagePicked extends CheckoutEvent {
  /// null = remove all; otherwise the picked file.
  final XFile? image;
  final bool isRemove;
  const PrescriptionImagePicked({this.image, required this.isRemove});
}

class PrescriptionImageRemoved extends CheckoutEvent {
  final int index;
  const PrescriptionImageRemoved({required this.index});
}

class OrderAttachmentPicked extends CheckoutEvent {
  const OrderAttachmentPicked();
}

// ─── Order placement ─────────────────────────────────────────────────────────

class OrderPlaced extends CheckoutEvent {
  final PlaceOrderBodyModel placeOrderBody;
  final int? zoneId;
  final double amount;
  final double? maximumCodOrderAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;
  final bool isOfflinePay;

  const OrderPlaced({
    required this.placeOrderBody,
    required this.zoneId,
    required this.amount,
    required this.maximumCodOrderAmount,
    required this.fromCart,
    required this.isCashOnDeliveryActive,
    this.isOfflinePay = false,
  });
}

class PrescriptionOrderPlaced extends CheckoutEvent {
  final int? storeId;
  final int? zoneId;
  final double? distance;
  final String address;
  final String longitude;
  final String latitude;
  final String note;
  final List<XFile> attachments;
  final String dmTips;
  final String deliveryInstruction;
  final double orderAmount;
  final double maxCodAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;

  const PrescriptionOrderPlaced({
    required this.storeId,
    required this.zoneId,
    required this.distance,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.note,
    required this.attachments,
    required this.dmTips,
    required this.deliveryInstruction,
    required this.orderAmount,
    required this.maxCodAmount,
    required this.fromCart,
    required this.isCashOnDeliveryActive,
  });
}

// ─── UI helpers ───────────────────────────────────────────────────────────────

class AcceptTermsToggled extends CheckoutEvent {
  const AcceptTermsToggled();
}

class InstructionSelected extends CheckoutEvent {
  final int index;
  const InstructionSelected({required this.index});
}

class ExpandToggled extends CheckoutEvent {
  const ExpandToggled();
}

class PreferableTimeSet extends CheckoutEvent {
  final String time;
  const PreferableTimeSet({required this.time});
}

class TotalAmountSet extends CheckoutEvent {
  final double amount;
  const TotalAmountSet({required this.amount});
}

class CheckoutCleared extends CheckoutEvent {
  const CheckoutCleared();
}
