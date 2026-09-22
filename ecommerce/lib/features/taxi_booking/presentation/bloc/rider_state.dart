import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/helper/rider_type.dart';
import '../../domain/models/rider_model.dart';
import '../../domain/models/trip_model.dart';
import '../../domain/models/vehicle_model.dart';

sealed class RiderState extends Equatable {
  final LatLng initialPosition;
  final Map<MarkerId, Marker> markers;
  final Map<PolylineId, Polyline> polyLines;
  final RiderType? rideStatus;
  final AddressModel? fromAddress;
  final AddressModel? toAddress;
  final bool isLoading;
  final double carDistance;
  final RiderModel? assignedRider;
  final double carTime;
  final int riderRating;
  final bool isReturnSameLocation;
  final String? tripDate;
  final String? tripTime;
  final int carType;
  final double distance;
  final double duration;
  final int activeBanner;
  final VehicleModel? topRatedVehicleModel;
  final TripModel? runningTrip;

  const RiderState({
    required this.initialPosition,
    required this.markers,
    required this.polyLines,
    this.rideStatus,
    this.fromAddress,
    this.toAddress,
    required this.isLoading,
    required this.carDistance,
    this.assignedRider,
    required this.carTime,
    required this.riderRating,
    required this.isReturnSameLocation,
    this.tripDate,
    this.tripTime,
    required this.carType,
    required this.distance,
    required this.duration,
    required this.activeBanner,
    this.topRatedVehicleModel,
    this.runningTrip,
  });

  @override
  List<Object?> get props => [
    initialPosition,
    markers,
    polyLines,
    rideStatus,
    fromAddress,
    toAddress,
    isLoading,
    carDistance,
    assignedRider,
    carTime,
    riderRating,
    isReturnSameLocation,
    tripDate,
    tripTime,
    carType,
    distance,
    duration,
    activeBanner,
    topRatedVehicleModel,
    runningTrip,
  ];
}

class RiderInitial extends RiderState {
  const RiderInitial({
    required LatLng initialPosition,
    Map<MarkerId, Marker> markers = const {},
    Map<PolylineId, Polyline> polyLines = const {},
    RiderType? rideStatus,
    AddressModel? fromAddress,
    AddressModel? toAddress,
    bool isLoading = false,
    double carDistance = -1,
    RiderModel? assignedRider,
    double carTime = -1,
    int riderRating = 0,
    bool isReturnSameLocation = false,
    String? tripDate,
    String? tripTime,
    int carType = 0,
    double distance = -1,
    double duration = -1,
    int activeBanner = 0,
    VehicleModel? topRatedVehicleModel,
    TripModel? runningTrip,
  }) : super(
    initialPosition: initialPosition,
    markers: markers,
    polyLines: polyLines,
    rideStatus: rideStatus,
    fromAddress: fromAddress,
    toAddress: toAddress,
    isLoading: isLoading,
    carDistance: carDistance,
    assignedRider: assignedRider,
    carTime: carTime,
    riderRating: riderRating,
    isReturnSameLocation: isReturnSameLocation,
    tripDate: tripDate,
    tripTime: tripTime,
    carType: carType,
    distance: distance,
    duration: duration,
    activeBanner: activeBanner,
    topRatedVehicleModel: topRatedVehicleModel,
    runningTrip: runningTrip,
  );
}

class RiderUpdated extends RiderState {
  const RiderUpdated({
    required LatLng initialPosition,
    required Map<MarkerId, Marker> markers,
    required Map<PolylineId, Polyline> polyLines,
    RiderType? rideStatus,
    AddressModel? fromAddress,
    AddressModel? toAddress,
    required bool isLoading,
    required double carDistance,
    RiderModel? assignedRider,
    required double carTime,
    required int riderRating,
    required bool isReturnSameLocation,
    String? tripDate,
    String? tripTime,
    required int carType,
    required double distance,
    required double duration,
    required int activeBanner,
    VehicleModel? topRatedVehicleModel,
    TripModel? runningTrip,
  }) : super(
    initialPosition: initialPosition,
    markers: markers,
    polyLines: polyLines,
    rideStatus: rideStatus,
    fromAddress: fromAddress,
    toAddress: toAddress,
    isLoading: isLoading,
    carDistance: carDistance,
    assignedRider: assignedRider,
    carTime: carTime,
    riderRating: riderRating,
    isReturnSameLocation: isReturnSameLocation,
    tripDate: tripDate,
    tripTime: tripTime,
    carType: carType,
    distance: distance,
    duration: duration,
    activeBanner: activeBanner,
    topRatedVehicleModel: topRatedVehicleModel,
    runningTrip: runningTrip,
  );
}

class RiderError extends RiderState {
  final String message;

  const RiderError({
    required this.message,
    required LatLng initialPosition,
    required Map<MarkerId, Marker> markers,
    required Map<PolylineId, Polyline> polyLines,
    RiderType? rideStatus,
    AddressModel? fromAddress,
    AddressModel? toAddress,
    required bool isLoading,
    required double carDistance,
    RiderModel? assignedRider,
    required double carTime,
    required int riderRating,
    required bool isReturnSameLocation,
    String? tripDate,
    String? tripTime,
    required int carType,
    required double distance,
    required double duration,
    required int activeBanner,
    VehicleModel? topRatedVehicleModel,
    TripModel? runningTrip,
  }) : super(
    initialPosition: initialPosition,
    markers: markers,
    polyLines: polyLines,
    rideStatus: rideStatus,
    fromAddress: fromAddress,
    toAddress: toAddress,
    isLoading: isLoading,
    carDistance: carDistance,
    assignedRider: assignedRider,
    carTime: carTime,
    riderRating: riderRating,
    isReturnSameLocation: isReturnSameLocation,
    tripDate: tripDate,
    tripTime: tripTime,
    carType: carType,
    distance: distance,
    duration: duration,
    activeBanner: activeBanner,
    topRatedVehicleModel: topRatedVehicleModel,
    runningTrip: runningTrip,
  );

  @override
  List<Object?> get props => [...super.props, message];
}
