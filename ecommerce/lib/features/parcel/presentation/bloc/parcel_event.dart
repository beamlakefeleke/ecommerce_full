import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';

sealed class ParcelEvent extends Equatable {
  const ParcelEvent();

  @override
  List<Object?> get props => [];
}

// ── data loads ──────────────────────────────────────────────────────────────

class ParcelCategoryListRequested extends ParcelEvent {
  const ParcelCategoryListRequested();
}

class WhyChooseDetailsRequested extends ParcelEvent {
  const WhyChooseDetailsRequested();
}

class VideoContentDetailsRequested extends ParcelEvent {
  const VideoContentDetailsRequested();
}

class ParcelInstructionRequested extends ParcelEvent {
  const ParcelInstructionRequested();
}

class OfflineMethodListRequested extends ParcelEvent {
  const OfflineMethodListRequested();
}

class DmTipMostTappedRequested extends ParcelEvent {
  const DmTipMostTappedRequested();
}

/// Resolve the distance (and extra charge) between pickup and destination.
class DistanceRequested extends ParcelEvent {
  final AddressModel pickupAddress;
  final AddressModel destinationAddress;

  const DistanceRequested({
    required this.pickupAddress,
    required this.destinationAddress,
  });

  @override
  List<Object?> get props => [pickupAddress, destinationAddress];
}

/// Resolve a selected place prediction into an address, validate its zone and
/// set it as pickup or destination. Side-effect messages surface via state.
class LocationFromPlaceRequested extends ParcelEvent {
  final String? placeId;
  final String? address;
  final bool isPickedUp;

  const LocationFromPlaceRequested({
    required this.placeId,
    required this.address,
    required this.isPickedUp,
  });

  @override
  List<Object?> get props => [placeId, address, isPickedUp];
}

// ── address set / selection ───────────────────────────────────────────────

class PickupAddressSet extends ParcelEvent {
  final AddressModel? address;
  const PickupAddressSet(this.address);

  @override
  List<Object?> get props => [address];
}

class DestinationAddressSet extends ParcelEvent {
  final AddressModel? address;
  const DestinationAddressSet(this.address);

  @override
  List<Object?> get props => [address];
}

class SenderAddressIndexSet extends ParcelEvent {
  final int? index;
  const SenderAddressIndexSet(this.index);

  @override
  List<Object?> get props => [index];
}

class ReceiverAddressIndexSet extends ParcelEvent {
  final int? index;
  const ReceiverAddressIndexSet(this.index);

  @override
  List<Object?> get props => [index];
}

class CountryCodeSet extends ParcelEvent {
  final String code;
  final bool isSender;
  const CountryCodeSet(this.code, this.isSender);

  @override
  List<Object?> get props => [code, isSender];
}

// ── toggles ───────────────────────────────────────────────────────────────

class IsPickedUpToggled extends ParcelEvent {
  final bool? isPickedUp;
  const IsPickedUpToggled(this.isPickedUp);

  @override
  List<Object?> get props => [isPickedUp];
}

class IsSenderToggled extends ParcelEvent {
  final bool isSender;
  const IsSenderToggled(this.isSender);

  @override
  List<Object?> get props => [isSender];
}

class TermsToggled extends ParcelEvent {
  const TermsToggled();
}

// ── payer / payment ─────────────────────────────────────────────────────────

class PayerIndexSet extends ParcelEvent {
  final int index;
  const PayerIndexSet(this.index);

  @override
  List<Object?> get props => [index];
}

class PaymentIndexSet extends ParcelEvent {
  final int index;
  const PaymentIndexSet(this.index);

  @override
  List<Object?> get props => [index];
}

class DigitalPaymentNameChanged extends ParcelEvent {
  final String name;
  const DigitalPaymentNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class OfflineBankSelected extends ParcelEvent {
  final int index;
  const OfflineBankSelected(this.index);

  @override
  List<Object?> get props => [index];
}

// ── delivery instruction / note ───────────────────────────────────────────

class InstructionSelectedIndexSet extends ParcelEvent {
  final int index;
  const InstructionSelectedIndexSet(this.index);

  @override
  List<Object?> get props => [index];
}

/// Mirrors the legacy `setselectedIndex(int?)`: null means "commit the
/// currently selected instruction index".
class SelectedNoteIndexSet extends ParcelEvent {
  final int? index;
  const SelectedNoteIndexSet(this.index);

  @override
  List<Object?> get props => [index];
}

/// Mirrors the legacy `setCustomNote(String?)`: a non-null/non-empty value
/// overrides the note; null/empty falls back to the text field's current text.
class CustomNoteSet extends ParcelEvent {
  final String? note;

  /// The request screen owns the note's `TextEditingController`; it passes the
  /// current text so the bloc can replicate the controller's fallback logic
  /// without owning a `TextEditingController` (rule 4).
  final String controllerText;

  const CustomNoteSet(this.note, {this.controllerText = ''});

  @override
  List<Object?> get props => [note, controllerText];
}

// ── dm tips ───────────────────────────────────────────────────────────────

class TipsFieldToggled extends ParcelEvent {
  const TipsFieldToggled();
}

class TipsAmountSet extends ParcelEvent {
  final double tips;
  const TipsAmountSet(this.tips);

  @override
  List<Object?> get props => [tips];
}

class DmTipSaveToggled extends ParcelEvent {
  const DmTipSaveToggled();
}

class TipsIndexUpdated extends ParcelEvent {
  final int index;
  const TipsIndexUpdated(this.index);

  @override
  List<Object?> get props => [index];
}

// ── loading / place order ───────────────────────────────────────────────────

class LoaderToggled extends ParcelEvent {
  final bool isEnable;
  const LoaderToggled(this.isEnable);

  @override
  List<Object?> get props => [isEnable];
}

/// Place the parcel order. On success/failure the bloc sets [actionStatus];
/// navigation + snackbars run in a `BlocListener` via `ParcelHelper`.
class ParcelOrderPlaced extends ParcelEvent {
  final PlaceOrderBodyModel placeOrderBody;
  final bool isOfflinePay;

  const ParcelOrderPlaced({
    required this.placeOrderBody,
    this.isOfflinePay = false,
  });

  @override
  List<Object?> get props => [placeOrderBody, isOfflinePay];
}
