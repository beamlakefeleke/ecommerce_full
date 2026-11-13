import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ecommerce/features/location/domain/entities/zone_response.dart';
import 'package:ecommerce/features/location/domain/models/prediction_model.dart';

Position _zeroPosition() => Position(
  longitude: 0,
  latitude: 0,
  timestamp: DateTime.now(),
  accuracy: 1,
  altitude: 1,
  heading: 1,
  speed: 1,
  speedAccuracy: 1,
  altitudeAccuracy: 1,
  headingAccuracy: 1,
);

/// Single immutable state for the location feature. Holds the map/zone working
/// state the screens read (position, pick position, geocoded addresses, zone
/// status, button/loading flags). Side-effects (navigation, Firebase, cart
/// reset) live in `LocationHelper`, not here.
class LocationState extends Equatable {
  final Position position;
  final Position pickPosition;

  final String? address;
  final String? pickAddress;

  final bool loading;
  final bool isLoading;

  final bool inZone;
  final int zoneId;
  final bool buttonDisabled;

  final bool showLocationSuggestion;
  final int addressTypeIndex;

  final List<PredictionModel> predictionList;

  /// The most recent zone lookup outcome, for the helper to act on.
  final ZoneResult? lastZoneResult;

  /// Transient one-shot error message for a `BlocListener` to surface.
  final String? errorMessage;

  LocationState({
    Position? position,
    Position? pickPosition,
    this.address = '',
    this.pickAddress = '',
    this.loading = false,
    this.isLoading = false,
    this.inZone = false,
    this.zoneId = 0,
    this.buttonDisabled = true,
    this.showLocationSuggestion = true,
    this.addressTypeIndex = 0,
    this.predictionList = const [],
    this.lastZoneResult,
    this.errorMessage,
  }) : position = position ?? _zeroPosition(),
       pickPosition = pickPosition ?? _zeroPosition();

  static const List<String?> addressTypeList = ['home', 'office', 'others'];

  LocationState copyWith({
    Position? position,
    Position? pickPosition,
    String? address,
    String? pickAddress,
    bool? loading,
    bool? isLoading,
    bool? inZone,
    int? zoneId,
    bool? buttonDisabled,
    bool? showLocationSuggestion,
    int? addressTypeIndex,
    List<PredictionModel>? predictionList,
    ZoneResult? lastZoneResult,
    String? errorMessage,
  }) {
    return LocationState(
      position: position ?? this.position,
      pickPosition: pickPosition ?? this.pickPosition,
      address: address ?? this.address,
      pickAddress: pickAddress ?? this.pickAddress,
      loading: loading ?? this.loading,
      isLoading: isLoading ?? this.isLoading,
      inZone: inZone ?? this.inZone,
      zoneId: zoneId ?? this.zoneId,
      buttonDisabled: buttonDisabled ?? this.buttonDisabled,
      showLocationSuggestion:
          showLocationSuggestion ?? this.showLocationSuggestion,
      addressTypeIndex: addressTypeIndex ?? this.addressTypeIndex,
      predictionList: predictionList ?? this.predictionList,
      lastZoneResult: lastZoneResult ?? this.lastZoneResult,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    position.latitude,
    position.longitude,
    pickPosition.latitude,
    pickPosition.longitude,
    address,
    pickAddress,
    loading,
    isLoading,
    inZone,
    zoneId,
    buttonDisabled,
    showLocationSuggestion,
    addressTypeIndex,
    predictionList,
    lastZoneResult,
    errorMessage,
  ];
}
