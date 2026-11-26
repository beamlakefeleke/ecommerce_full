import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce/features/location/domain/repositories/location_repository.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/taxi_usecases.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_state.dart';
import 'package:ecommerce/helper/rider_type.dart';

/// Event-driven replacement for the data-bearing part of the legacy
/// `RiderController`.
///
/// Fetches place details / routes / running trips through [TaxiRepository]
/// usecases; delegates zone resolution to the migrated [LocationRepository]
/// and distance/duration to the migrated [CheckoutRepository] (same split the
/// legacy controller used). No navigation, snackbars, map controllers or text
/// controllers live here: those stay in the widget layer, and one-shot
/// outcomes surface via [RiderState.actionStatus] / [actionMessage].
class RiderBloc extends Bloc<RiderEvent, RiderState> {
  final GetTaxiPlaceDetailsUseCase getPlaceDetails;
  final GetRouteUseCase getRoute;
  final GetRunningTripListUseCase getRunningTripList;
  final CheckoutRepository checkoutRepository;
  final LocationRepository locationRepository;

  /// The user's saved address, read lazily (the legacy flow used
  /// `AddressHelper.getUserAddressFromSharedPref()`). Injected so the bloc
  /// stays decoupled from the shared-prefs helper.
  final AddressModel? Function() currentUserAddress;

  RiderBloc({
    required this.getPlaceDetails,
    required this.getRoute,
    required this.getRunningTripList,
    required this.checkoutRepository,
    required this.locationRepository,
    required this.currentUserAddress,
    required LatLng defaultPosition,
  }) : super(RiderState(initialPosition: defaultPosition)) {
    on<RiderDataInitialized>(_onDataInitialized);
    on<InitialPositionSet>(_onInitialPositionSet);
    on<RideStatusSet>(_onRideStatusSet);
    on<CarTypeSet>(_onCarTypeSet);
    on<ReturnSameLocationToggled>(_onReturnSameLocationToggled);
    on<TripDateSet>(_onTripDateSet);
    on<TripTimeSet>(_onTripTimeSet);
    on<AddressCleared>(_onAddressCleared);
    on<LocationFromPlaceSelected>(_onLocationFromPlaceSelected);
    on<RunningTripListRequested>(_onRunningTripListRequested);
  }

  void _onDataInitialized(
    RiderDataInitialized event,
    Emitter<RiderState> emit,
  ) {
    final AddressModel? from = event.address ?? currentUserAddress();
    final RiderType status = RiderType.values.firstWhere(
      (element) => element.name == event.riderType,
      orElse: () => RiderType.initial,
    );
    emit(
      state.copyWith(
        fromAddress: from,
        clearToAddress: true,
        routePoints: const [],
        rideStatus: status,
        carDistance: -1,
        carTime: -1,
      ),
    );
  }

  void _onInitialPositionSet(
    InitialPositionSet event,
    Emitter<RiderState> emit,
  ) => emit(state.copyWith(initialPosition: event.position));

  void _onRideStatusSet(RideStatusSet event, Emitter<RiderState> emit) =>
      emit(state.copyWith(rideStatus: event.rideStatus));

  void _onCarTypeSet(CarTypeSet event, Emitter<RiderState> emit) =>
      emit(state.copyWith(carType: event.index));

  void _onReturnSameLocationToggled(
    ReturnSameLocationToggled event,
    Emitter<RiderState> emit,
  ) => emit(state.copyWith(isReturnSameLocation: event.value));

  void _onTripDateSet(TripDateSet event, Emitter<RiderState> emit) =>
      emit(state.copyWith(tripDate: event.date));

  void _onTripTimeSet(TripTimeSet event, Emitter<RiderState> emit) =>
      emit(state.copyWith(tripTime: event.time));

  void _onAddressCleared(AddressCleared event, Emitter<RiderState> emit) {
    emit(
      event.isFrom
          ? state.copyWith(clearFromAddress: true)
          : state.copyWith(clearToAddress: true),
    );
  }

  Future<void> _onLocationFromPlaceSelected(
    LocationFromPlaceSelected event,
    Emitter<RiderState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: RiderActionStatus.inProgress,
        actionMessage: null,
      ),
    );
    final detailsResult = await getPlaceDetails(event.placeId);
    await detailsResult.fold(
      (failure) async => emit(
        state.copyWith(
          actionStatus: RiderActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (placeDetails) async {
        if (placeDetails.status != 'OK' ||
            placeDetails.result?.geometry == null) {
          emit(state.copyWith(actionStatus: RiderActionStatus.none));
          return;
        }
        final AddressModel saved = currentUserAddress() ?? AddressModel();
        final AddressModel address = AddressModel(
          address: event.address,
          addressType: 'others',
          latitude: placeDetails.result!.geometry!.location!.lat.toString(),
          longitude: placeDetails.result!.geometry!.location!.lng.toString(),
          contactPersonName: saved.contactPersonName,
          contactPersonNumber: saved.contactPersonNumber,
        );

        final zoneResult = await locationRepository.getZone(
          address.latitude,
          address.longitude,
        );

        await zoneResult.fold(
          (failure) async => emit(
            state.copyWith(
              actionStatus: RiderActionStatus.failure,
              actionMessage: failure.message,
            ),
          ),
          (zone) async {
            if (!zone.isSuccess) {
              emit(
                state.copyWith(
                  actionStatus: RiderActionStatus.failure,
                  actionMessage: zone.message,
                ),
              );
              return;
            }
            final List<int> savedZoneIds = saved.zoneIds ?? const [];
            if (zone.zoneIds.isEmpty ||
                !savedZoneIds.contains(zone.zoneIds[0])) {
              emit(
                state.copyWith(
                  actionStatus: RiderActionStatus.failure,
                  actionMessage:
                      'your_selected_location_is_from_different_zone_store',
                ),
              );
              return;
            }
            address.zoneId = zone.zoneIds[0];
            address.zoneIds = [...zone.zoneIds];
            address.zoneData = [...zone.zoneData];

            if (event.isFrom) {
              emit(state.copyWith(fromAddress: address));
            } else {
              emit(state.copyWith(toAddress: address));
            }
            await _recomputeRoute(emit);
            emit(state.copyWith(actionStatus: RiderActionStatus.success));
          },
        );
      },
    );
  }

  /// When both ends are known, fetch the route polyline and distance/duration.
  Future<void> _recomputeRoute(Emitter<RiderState> emit) async {
    final LatLng? from = state.fromLatLng;
    final LatLng? to = state.toLatLng;
    if (from == null || to == null) return;

    final routeResult = await getRoute(
      RouteParams(origin: from, destination: to),
    );
    final List<LatLng> points = routeResult.getOrElse((_) => const []);

    final distanceResult = await checkoutRepository.getDistanceInKm(from, to);
    final double distance = distanceResult.getOrElse((_) => -1);
    final durationResult = await checkoutRepository.getDistanceInKm(
      from,
      to,
      isDuration: true,
    );
    final double duration = durationResult.getOrElse((_) => -1);

    emit(
      state.copyWith(
        routePoints: points,
        distance: distance,
        duration: duration,
      ),
    );
  }

  Future<void> _onRunningTripListRequested(
    RunningTripListRequested event,
    Emitter<RiderState> emit,
  ) async {
    if (event.offset == 1) {
      emit(state.copyWith(clearRunningTrip: true));
    }
    final result = await getRunningTripList(event.offset);
    result.fold(
      (_) {},
      (trip) => emit(state.copyWith(runningTrip: trip)),
    );
  }
}
