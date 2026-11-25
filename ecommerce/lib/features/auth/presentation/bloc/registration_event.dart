import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/auth/domain/models/delivery_man_body.dart';
import 'package:ecommerce/features/auth/domain/models/store_body_model.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();
  @override
  List<Object?> get props => [];
}

// ── Shared ───────────────────────────────────────────────────────────────────

class RegistrationInitialized extends RegistrationEvent {
  /// Pass 'store' or 'deliveryman' to distinguish which kind.
  final String kind;
  const RegistrationInitialized(this.kind);
  @override
  List<Object?> get props => [kind];
}

class RegistrationPassToggled extends RegistrationEvent {
  const RegistrationPassToggled();
}

class RegistrationPassValidated extends RegistrationEvent {
  final String password;
  const RegistrationPassValidated(this.password);
  @override
  List<Object?> get props => [password];
}

class RegistrationZoneIndexSet extends RegistrationEvent {
  final int? index;
  const RegistrationZoneIndexSet(this.index);
  @override
  List<Object?> get props => [index];
}

class RegistrationLocationSet extends RegistrationEvent {
  final LatLng location;
  const RegistrationLocationSet(this.location);
  @override
  List<Object?> get props => [location.latitude, location.longitude];
}

class RegistrationModuleIndexSelected extends RegistrationEvent {
  final int? index;
  const RegistrationModuleIndexSelected(this.index);
  @override
  List<Object?> get props => [index];
}

class RegistrationStatusChanged extends RegistrationEvent {
  final double value;
  const RegistrationStatusChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class RegistrationReset extends RegistrationEvent {
  const RegistrationReset();
}

// ── Store-specific ───────────────────────────────────────────────────────────

class RegistrationImagePicked extends RegistrationEvent {
  final bool isLogo;
  final bool isRemove;
  const RegistrationImagePicked({required this.isLogo, required this.isRemove});
  @override
  List<Object?> get props => [isLogo, isRemove];
}

class RegistrationMinTimeChanged extends RegistrationEvent {
  final String time;
  const RegistrationMinTimeChanged(this.time);
  @override
  List<Object?> get props => [time];
}

class RegistrationMaxTimeChanged extends RegistrationEvent {
  final String time;
  const RegistrationMaxTimeChanged(this.time);
  @override
  List<Object?> get props => [time];
}

class RegistrationTimeUnitChanged extends RegistrationEvent {
  final String unit;
  const RegistrationTimeUnitChanged(this.unit);
  @override
  List<Object?> get props => [unit];
}

class StoreRegistrationSubmitted extends RegistrationEvent {
  final StoreBodyModel storeBody;
  const StoreRegistrationSubmitted(this.storeBody);
  @override
  List<Object?> get props => [storeBody];
}

// ── Deliveryman-specific ─────────────────────────────────────────────────────

class DmImagePicked extends RegistrationEvent {
  final bool isPhoto;
  final bool isRemove;
  const DmImagePicked({required this.isPhoto, required this.isRemove});
  @override
  List<Object?> get props => [isPhoto, isRemove];
}

class DmIdentityImageRemoved extends RegistrationEvent {
  final int index;
  const DmIdentityImageRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class DmImageRemoved extends RegistrationEvent {
  const DmImageRemoved();
}

class DmIdentityTypeIndexSet extends RegistrationEvent {
  final String? identityType;
  const DmIdentityTypeIndexSet(this.identityType);
  @override
  List<Object?> get props => [identityType];
}

class DmTypeIndexSet extends RegistrationEvent {
  final int dmType;
  const DmTypeIndexSet(this.dmType);
  @override
  List<Object?> get props => [dmType];
}

class DmVehicleIndexSet extends RegistrationEvent {
  final int? index;
  const DmVehicleIndexSet(this.index);
  @override
  List<Object?> get props => [index];
}

class DmTermsToggled extends RegistrationEvent {
  const DmTermsToggled();
}

class DeliveryManRegistrationSubmitted extends RegistrationEvent {
  final DeliveryManBody deliveryManBody;
  const DeliveryManRegistrationSubmitted(this.deliveryManBody);
  @override
  List<Object?> get props => [deliveryManBody];
}
