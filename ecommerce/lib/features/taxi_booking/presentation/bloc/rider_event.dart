import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/helper/rider_type.dart';

sealed class RiderEvent extends Equatable {
  const RiderEvent();

  @override
  List<Object?> get props => [];
}

/// Initialise the map flow for a ride type and optional starting address.
class RiderDataInitialized extends RiderEvent {
  final String? riderType;
  final AddressModel? address;

  const RiderDataInitialized({required this.riderType, required this.address});

  @override
  List<Object?> get props => [riderType, address?.address];
}

/// Set the map's initial/camera position (from a resolved geolocation or an
/// address). The widget performs the actual camera animation.
class InitialPositionSet extends RiderEvent {
  final LatLng position;
  const InitialPositionSet(this.position);

  @override
  List<Object?> get props => [position];
}

class RideStatusSet extends RiderEvent {
  final RiderType rideStatus;
  const RideStatusSet(this.rideStatus);

  @override
  List<Object?> get props => [rideStatus];
}

class CarTypeSet extends RiderEvent {
  final int index;
  const CarTypeSet(this.index);

  @override
  List<Object?> get props => [index];
}

class ReturnSameLocationToggled extends RiderEvent {
  final bool value;
  const ReturnSameLocationToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class TripDateSet extends RiderEvent {
  /// Pre-formatted, readable date string (the UI owns the date picker).
  final String date;
  const TripDateSet(this.date);

  @override
  List<Object?> get props => [date];
}

class TripTimeSet extends RiderEvent {
  /// Pre-formatted time string (the UI owns the time picker).
  final String time;
  const TripTimeSet(this.time);

  @override
  List<Object?> get props => [time];
}

/// Clear the from/to address (and its text field, handled by the widget).
class AddressCleared extends RiderEvent {
  final bool isFrom;
  const AddressCleared(this.isFrom);

  @override
  List<Object?> get props => [isFrom];
}

/// Resolve a selected place prediction into an address, validate its zone and
/// set it as pickup (isFrom) or destination; also recomputes route + distance
/// when both ends are known. Messages surface via state.
class LocationFromPlaceSelected extends RiderEvent {
  final String? placeId;
  final String? address;
  final bool isFrom;

  const LocationFromPlaceSelected({
    required this.placeId,
    required this.address,
    required this.isFrom,
  });

  @override
  List<Object?> get props => [placeId, address, isFrom];
}

/// Load a page of the running-trip list. `offset` 1 is the first page/refresh.
class RunningTripListRequested extends RiderEvent {
  final int offset;
  const RunningTripListRequested({this.offset = 1});

  @override
  List<Object?> get props => [offset];
}
