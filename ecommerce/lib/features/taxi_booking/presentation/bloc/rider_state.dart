import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/taxi_booking/models/trip_model.dart';
import 'package:ecommerce/helper/rider_type.dart';

/// Outcome of a one-shot rider action (place-details zone resolution). The UI
/// reacts via a `BlocListener`; it is reset on the next event.
enum RiderActionStatus { none, inProgress, success, failure }

/// Immutable state for the ride-sharing map flow (replaces the data-bearing
/// part of the legacy `RiderController`).
///
/// The bloc owns only serializable data: the initial camera position, the
/// from/to addresses, the route polyline points, distances and the running
/// trip list. The widget layer keeps the `GoogleMapController` and the two
/// `TextEditingController`s and renders the actual [Marker]/[Polyline] sets
/// from `fromLatLng` / `toLatLng` / `routePoints`.
class RiderState extends Equatable {
  final LatLng initialPosition;
  final RiderType? rideStatus;

  final AddressModel? fromAddress;
  final AddressModel? toAddress;

  /// Decoded route points for the from→to polyline.
  final List<LatLng> routePoints;

  final double? distance;
  final double? duration;
  final double? carDistance;
  final double? carTime;

  final int carType;
  final bool isReturnSameLocation;
  final String? tripDate;
  final String? tripTime;

  final TripModel? runningTrip;

  final RiderActionStatus actionStatus;
  final String? actionMessage;

  const RiderState({
    required this.initialPosition,
    this.rideStatus,
    this.fromAddress,
    this.toAddress,
    this.routePoints = const [],
    this.distance = -1,
    this.duration = -1,
    this.carDistance = -1,
    this.carTime = -1,
    this.carType = 0,
    this.isReturnSameLocation = false,
    this.tripDate,
    this.tripTime,
    this.runningTrip,
    this.actionStatus = RiderActionStatus.none,
    this.actionMessage,
  });

  /// Pickup coordinates derived from [fromAddress], or null.
  LatLng? get fromLatLng => fromAddress?.latitude == null
      ? null
      : LatLng(
          double.parse(fromAddress!.latitude!),
          double.parse(fromAddress!.longitude!),
        );

  /// Destination coordinates derived from [toAddress], or null.
  LatLng? get toLatLng => toAddress?.latitude == null
      ? null
      : LatLng(
          double.parse(toAddress!.latitude!),
          double.parse(toAddress!.longitude!),
        );

  RiderState copyWith({
    LatLng? initialPosition,
    RiderType? rideStatus,
    AddressModel? fromAddress,
    bool clearFromAddress = false,
    AddressModel? toAddress,
    bool clearToAddress = false,
    List<LatLng>? routePoints,
    double? distance,
    double? duration,
    double? carDistance,
    double? carTime,
    int? carType,
    bool? isReturnSameLocation,
    String? tripDate,
    String? tripTime,
    TripModel? runningTrip,
    bool clearRunningTrip = false,
    RiderActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return RiderState(
      initialPosition: initialPosition ?? this.initialPosition,
      rideStatus: rideStatus ?? this.rideStatus,
      fromAddress: clearFromAddress ? null : (fromAddress ?? this.fromAddress),
      toAddress: clearToAddress ? null : (toAddress ?? this.toAddress),
      routePoints: routePoints ?? this.routePoints,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      carDistance: carDistance ?? this.carDistance,
      carTime: carTime ?? this.carTime,
      carType: carType ?? this.carType,
      isReturnSameLocation: isReturnSameLocation ?? this.isReturnSameLocation,
      tripDate: tripDate ?? this.tripDate,
      tripTime: tripTime ?? this.tripTime,
      runningTrip: clearRunningTrip ? null : (runningTrip ?? this.runningTrip),
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    initialPosition,
    rideStatus,
    fromAddress,
    toAddress,
    routePoints,
    distance,
    duration,
    carDistance,
    carTime,
    carType,
    isReturnSameLocation,
    tripDate,
    tripTime,
    runningTrip,
    actionStatus,
    actionMessage,
  ];
}
