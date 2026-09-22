import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/helper/rider_type.dart';

sealed class RiderEvent extends Equatable {
  const RiderEvent();

  @override
  List<Object?> get props => [];
}

class ClearAddressEvent extends RiderEvent {
  final bool isFrom;

  const ClearAddressEvent({required this.isFrom});

  @override
  List<Object?> get props => [isFrom];
}

class InitSetupEvent extends RiderEvent {}

class SetCarTypeEvent extends RiderEvent {
  final int index;

  const SetCarTypeEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class SetDateEvent extends RiderEvent {}

class SetTimeEvent extends RiderEvent {
  final BuildContext context;

  const SetTimeEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class ChangeBannerEvent extends RiderEvent {
  final int index;

  const ChangeBannerEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

class InitializeDataEvent extends RiderEvent {
  final String? riderType;
  final AddressModel? address;

  const InitializeDataEvent({this.riderType, this.address});

  @override
  List<Object?> get props => [riderType, address];
}

class SetMapControllerEvent extends RiderEvent {
  final GoogleMapController mapController;

  const SetMapControllerEvent({required this.mapController});

  @override
  List<Object?> get props => [mapController];
}

class GetRunningTripListEvent extends RiderEvent {
  final int offset;
  final bool isUpdate;

  const GetRunningTripListEvent({required this.offset, this.isUpdate = false});

  @override
  List<Object?> get props => [offset, isUpdate];
}

class GetTopRatedVehiclesListEvent extends RiderEvent {
  final int offset;
  final bool isUpdate;

  const GetTopRatedVehiclesListEvent({required this.offset, this.isUpdate = false});

  @override
  List<Object?> get props => [offset, isUpdate];
}

class GetInitialLocationEvent extends RiderEvent {
  final AddressModel? address;

  const GetInitialLocationEvent({this.address});

  @override
  List<Object?> get props => [address];
}

class ClearRideDataEvent extends RiderEvent {}

class SetRideStatusEvent extends RiderEvent {
  final RiderType rideStatus;
  final bool shouldUpdate;

  const SetRideStatusEvent({required this.rideStatus, this.shouldUpdate = true});

  @override
  List<Object?> get props => [rideStatus, shouldUpdate];
}

class ToggleIsReturnSameLocationEvent extends RiderEvent {
  final bool value;

  const ToggleIsReturnSameLocationEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class SetLocationFromPlaceEvent extends RiderEvent {
  final String? placeID;
  final String? address;
  final bool isFrom;

  const SetLocationFromPlaceEvent({this.placeID, this.address, required this.isFrom});

  @override
  List<Object?> get props => [placeID, address, isFrom];
}

class SetFromAddressEvent extends RiderEvent {
  final AddressModel addressModel;

  const SetFromAddressEvent({required this.addressModel});

  @override
  List<Object?> get props => [addressModel];
}

class SetToAddressEvent extends RiderEvent {
  final AddressModel addressModel;

  const SetToAddressEvent({required this.addressModel});

  @override
  List<Object?> get props => [addressModel];
}
