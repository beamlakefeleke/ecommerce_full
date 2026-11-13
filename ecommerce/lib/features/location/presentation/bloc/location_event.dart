import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';

sealed class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

/// Resolve the device's current location (or config default), reverse-geocode
/// it and run a zone lookup. [fromAddress] chooses which position slot to fill.
class CurrentLocationRequested extends LocationEvent {
  final bool fromAddress;
  final LatLng? defaultLatLng;

  const CurrentLocationRequested({required this.fromAddress, this.defaultLatLng});

  @override
  List<Object?> get props => [fromAddress, defaultLatLng];
}

/// Run a zone lookup for an explicit coordinate (used after picking an address).
class ZoneRequested extends LocationEvent {
  final String? lat;
  final String? lng;
  final bool markerLoad;
  final bool updateInAddress;
  final bool handleError;

  const ZoneRequested({
    required this.lat,
    required this.lng,
    required this.markerLoad,
    this.updateInAddress = false,
    this.handleError = false,
  });

  @override
  List<Object?> get props => [lat, lng, markerLoad, updateInAddress, handleError];
}

/// Map camera settled on a new position; reverse-geocode + zone lookup it.
class CameraPositionUpdated extends LocationEvent {
  final CameraPosition? cameraPosition;
  final bool fromAddress;

  const CameraPositionUpdated(this.cameraPosition, this.fromAddress);

  @override
  List<Object?> get props => [
    cameraPosition?.target.latitude,
    cameraPosition?.target.longitude,
    fromAddress,
  ];
}

/// Camera started moving — disable the confirm button until it settles.
class ButtonDisabled extends LocationEvent {
  const ButtonDisabled();
}

/// Autocomplete search for the type-ahead field.
class LocationSearched extends LocationEvent {
  final String text;
  const LocationSearched(this.text);

  @override
  List<Object?> get props => [text];
}

/// Resolve a picked prediction (placeId) into a pick position + address.
class PredictionSelected extends LocationEvent {
  final String? placeId;
  final String? address;

  const PredictionSelected({required this.placeId, required this.address});

  @override
  List<Object?> get props => [placeId, address];
}

/// Seed the editable position/address from an existing saved address (edit flow).
class UpdateAddressSeeded extends LocationEvent {
  final AddressModel address;
  const UpdateAddressSeeded(this.address);

  @override
  List<Object?> get props => [address];
}

/// Copy the current address slot into the pick slot (add-address flow).
class PickDataSeeded extends LocationEvent {
  const PickDataSeeded();
}

/// Commit the pick slot back into the main address slot.
class AddAddressDataSet extends LocationEvent {
  const AddAddressDataSet();
}

/// Select the address-type tab (home/office/others).
class AddressTypeIndexChanged extends LocationEvent {
  final int index;
  const AddressTypeIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}

/// Toggle the home-screen "suggest location" banner visibility.
class SuggestedLocationHidden extends LocationEvent {
  const SuggestedLocationHidden();
}

/// Overwrite only the displayed address text.
class PlaceMarkSet extends LocationEvent {
  final String address;
  const PlaceMarkSet(this.address);

  @override
  List<Object?> get props => [address];
}

/// Set the user's working position directly from a store coordinate.
class StorePositionResolved extends LocationEvent {
  final Position position;
  const StorePositionResolved(this.position);

  @override
  List<Object?> get props => [position.latitude, position.longitude];
}
