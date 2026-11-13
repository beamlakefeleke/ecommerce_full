import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/location/domain/entities/zone_response.dart';
import 'package:ecommerce/features/location/domain/usecases/location_usecases.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_event.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_state.dart';
import 'package:ecommerce/helper/address_helper.dart';

/// App-wide bloc owning the location/map working state. Input only via
/// `add(Event)`. All navigation / Firebase / cart-reset side-effects are in
/// `LocationHelper`; this bloc only touches map state, geocoding, and zones.
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetAddressFromGeocodeUseCase getAddressFromGeocode;
  final GetZoneUseCase getZone;
  final SearchLocationUseCase searchLocation;
  final GetLatLngUseCase getLatLng;

  /// Config default location (lives in the still-GetX splash feature); read
  /// lazily so the domain layer stays decoupled from SplashController.
  final LatLng Function() configDefaultLatLng;

  /// The map controller for the active pick/map screen. Not part of [state]
  /// (it is not a value); screens register it here so the bloc can animate.
  GoogleMapController? mapController;

  /// Guards the add-address edit flow: when false, camera callbacks don't
  /// recompute the position (mirrors the legacy `_updateAddAddressData`).
  bool _updateAddAddressData = true;

  /// When false, a camera-driven geocode is skipped once (mirrors the legacy
  /// `_changeAddress`, set after an explicit prediction pick).
  bool _changeAddress = true;

  LocationBloc({
    required this.getAddressFromGeocode,
    required this.getZone,
    required this.searchLocation,
    required this.getLatLng,
    required this.configDefaultLatLng,
  }) : super(LocationState()) {
    on<CurrentLocationRequested>(_onCurrentLocation);
    on<ZoneRequested>(_onZone);
    on<CameraPositionUpdated>(_onCameraPositionUpdated);
    on<ButtonDisabled>(_onButtonDisabled);
    on<LocationSearched>(_onSearched);
    on<PredictionSelected>(_onPredictionSelected);
    on<UpdateAddressSeeded>(_onUpdateAddressSeeded);
    on<PickDataSeeded>(_onPickDataSeeded);
    on<AddAddressDataSet>(_onAddAddressDataSet);
    on<AddressTypeIndexChanged>(_onAddressTypeIndexChanged);
    on<SuggestedLocationHidden>(_onSuggestedLocationHidden);
    on<PlaceMarkSet>(_onPlaceMarkSet);
    on<StorePositionResolved>(_onStorePositionResolved);
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  /// Build the last-resolved address as an [AddressModel] (helper convenience).
  AddressModel buildAddressModel({required bool fromAddress}) {
    final pos = fromAddress ? state.position : state.pickPosition;
    final addr = fromAddress ? state.address : state.pickAddress;
    final zone = state.lastZoneResult;
    return AddressModel(
      latitude: pos.latitude.toString(),
      longitude: pos.longitude.toString(),
      addressType: 'others',
      zoneId: (zone?.isSuccess ?? false) ? zone!.zoneIds[0] : 0,
      zoneIds: zone?.zoneIds,
      address: addr,
      zoneData: zone?.zoneData,
      areaIds: zone?.areaIds,
    );
  }

  Future<Position> _resolvePosition(LatLng? defaultLatLng) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      final fallback = defaultLatLng ?? configDefaultLatLng();
      return Position(
        latitude: fallback.latitude,
        longitude: fallback.longitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1,
      );
    }
  }

  Position _positionFromLatLng(double lat, double lng) => Position(
    latitude: lat,
    longitude: lng,
    timestamp: DateTime.now(),
    accuracy: 1,
    altitude: 1,
    heading: 1,
    speed: 1,
    speedAccuracy: 1,
    altitudeAccuracy: 1,
    headingAccuracy: 1,
  );

  void _animateTo(Position position) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 17,
        ),
      ),
    );
  }

  Future<void> _onCurrentLocation(
    CurrentLocationRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(loading: true));

    final Position myPosition = await _resolvePosition(event.defaultLatLng);

    emit(
      event.fromAddress
          ? state.copyWith(position: myPosition)
          : state.copyWith(pickPosition: myPosition),
    );
    _animateTo(myPosition);

    // Reverse geocode.
    final geo = await getAddressFromGeocode(
      LatLngParams(LatLng(myPosition.latitude, myPosition.longitude)),
    );
    final String addressText = geo.fold(
      (f) => 'Unknown Location Found',
      (a) => a,
    );
    emit(
      event.fromAddress
          ? state.copyWith(address: addressText)
          : state.copyWith(pickAddress: addressText),
    );

    // Zone lookup.
    final zoneEither = await getZone(
      ZoneParams(
        lat: myPosition.latitude.toString(),
        lng: myPosition.longitude.toString(),
        handleError: true,
      ),
    );
    final ZoneResult zone = zoneEither.fold(
      (f) => const ZoneResult(
        isSuccess: false,
        message: null,
        zoneIds: [],
        zoneData: [],
        areaIds: [],
      ),
      (z) => z,
    );

    emit(
      state.copyWith(
        buttonDisabled: !zone.isSuccess,
        inZone: zone.isSuccess,
        zoneId: zone.isSuccess ? zone.zoneIds[0] : 0,
        lastZoneResult: zone,
        loading: false,
      ),
    );
  }

  Future<void> _onZone(ZoneRequested event, Emitter<LocationState> emit) async {
    emit(
      event.markerLoad
          ? state.copyWith(loading: true)
          : state.copyWith(isLoading: true),
    );

    final either = await getZone(
      ZoneParams(
        lat: event.lat,
        lng: event.lng,
        handleError: event.handleError,
      ),
    );
    final ZoneResult zone = either.fold(
      (f) => const ZoneResult(
        isSuccess: false,
        message: null,
        zoneIds: [],
        zoneData: [],
        areaIds: [],
      ),
      (z) => z,
    );

    // Mirror the legacy `updateInAddress` branch: persist zoneData onto the
    // saved address (local shared-prefs, no navigation side-effect).
    if (event.updateInAddress && zone.isSuccess) {
      final AddressModel? address =
          AddressHelper.getUserAddressFromSharedPref();
      if (address != null) {
        address.zoneData = zone.zoneData;
        await AddressHelper.saveUserAddressInSharedPref(address);
      }
    }

    emit(
      state.copyWith(
        inZone: zone.isSuccess,
        zoneId: zone.isSuccess ? zone.zoneIds[0] : 0,
        lastZoneResult: zone,
        loading: event.markerLoad ? false : null,
        isLoading: event.markerLoad ? null : false,
      ),
    );
  }

  Future<void> _onCameraPositionUpdated(
    CameraPositionUpdated event,
    Emitter<LocationState> emit,
  ) async {
    if (!_updateAddAddressData) {
      _updateAddAddressData = true;
      return;
    }
    final target = event.cameraPosition?.target;
    if (target == null) return;

    emit(state.copyWith(loading: true));

    final Position newPos = _positionFromLatLng(
      target.latitude,
      target.longitude,
    );
    emit(
      event.fromAddress
          ? state.copyWith(position: newPos)
          : state.copyWith(pickPosition: newPos),
    );

    final zoneEither = await getZone(
      ZoneParams(
        lat: target.latitude.toString(),
        lng: target.longitude.toString(),
      ),
    );
    final ZoneResult zone = zoneEither.fold(
      (f) => const ZoneResult(
        isSuccess: false,
        message: null,
        zoneIds: [],
        zoneData: [],
        areaIds: [],
      ),
      (z) => z,
    );

    if (_changeAddress) {
      final geo = await getAddressFromGeocode(LatLngParams(target));
      final String addressText = geo.fold(
        (f) => 'Unknown Location Found',
        (a) => a,
      );
      emit(
        event.fromAddress
            ? state.copyWith(address: addressText)
            : state.copyWith(pickAddress: addressText),
      );
    } else {
      _changeAddress = true;
    }

    emit(
      state.copyWith(
        buttonDisabled: !zone.isSuccess,
        inZone: zone.isSuccess,
        zoneId: zone.isSuccess ? zone.zoneIds[0] : 0,
        lastZoneResult: zone,
        loading: false,
      ),
    );
  }

  void _onButtonDisabled(ButtonDisabled event, Emitter<LocationState> emit) {
    emit(state.copyWith(buttonDisabled: true, inZone: true));
  }

  Future<void> _onSearched(
    LocationSearched event,
    Emitter<LocationState> emit,
  ) async {
    if (event.text.isEmpty) return;
    final either = await searchLocation(SearchLocationParams(event.text));
    either.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (list) => emit(state.copyWith(predictionList: list)),
    );
  }

  Future<void> _onPredictionSelected(
    PredictionSelected event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    final either = await getLatLng(PlaceIdParams(event.placeId));
    final LatLng latLng = either.fold((f) => const LatLng(0, 0), (v) => v);

    final Position pickPos = _positionFromLatLng(
      latLng.latitude,
      latLng.longitude,
    );
    _changeAddress = false;
    emit(
      state.copyWith(
        pickPosition: pickPos,
        pickAddress: event.address,
        loading: false,
      ),
    );
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 17)),
    );
  }

  void _onUpdateAddressSeeded(
    UpdateAddressSeeded event,
    Emitter<LocationState> emit,
  ) {
    final address = event.address;
    emit(
      state.copyWith(
        position: _positionFromLatLng(
          double.parse(address.latitude!),
          double.parse(address.longitude!),
        ),
        address: address.address,
        addressTypeIndex: LocationState.addressTypeList.indexOf(
          address.addressType,
        ),
      ),
    );
  }

  void _onPickDataSeeded(PickDataSeeded event, Emitter<LocationState> emit) {
    emit(
      state.copyWith(pickPosition: state.position, pickAddress: state.address),
    );
  }

  void _onAddAddressDataSet(
    AddAddressDataSet event,
    Emitter<LocationState> emit,
  ) {
    _updateAddAddressData = false;
    emit(
      state.copyWith(position: state.pickPosition, address: state.pickAddress),
    );
  }

  void _onAddressTypeIndexChanged(
    AddressTypeIndexChanged event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(addressTypeIndex: event.index));
  }

  void _onSuggestedLocationHidden(
    SuggestedLocationHidden event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(showLocationSuggestion: !state.showLocationSuggestion));
  }

  void _onPlaceMarkSet(PlaceMarkSet event, Emitter<LocationState> emit) {
    emit(state.copyWith(address: event.address));
  }

  void _onStorePositionResolved(
    StorePositionResolved event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }
}
