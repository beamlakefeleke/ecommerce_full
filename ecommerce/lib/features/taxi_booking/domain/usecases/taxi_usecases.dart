import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/domain/repositories/taxi_repository.dart';
import 'package:ecommerce/features/taxi_booking/models/brand_model.dart';
import 'package:ecommerce/features/taxi_booking/models/trip_model.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';

/// Paginated top-rated vehicles list (shown on the ride-sharing home screen).
class GetTopRatedVehiclesUseCase implements UseCase<VehicleModel, int> {
  final TaxiRepository repository;
  GetTopRatedVehiclesUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleModel>> call(int offset) =>
      repository.getTopRatedVehicles(offset);
}

/// Parameters for [GetVehiclesUseCase]: the trip filter body + page offset.
class VehiclesParams extends Equatable {
  final UserInformationBody body;
  final int offset;

  const VehiclesParams({required this.body, required this.offset});

  // UserInformationBody is not Equatable; key on offset + identity.
  @override
  List<Object?> get props => [offset, identityHashCode(body)];
}

/// Paginated, filterable vehicles list for the select-car screen.
class GetVehiclesUseCase implements UseCase<VehicleModel, VehiclesParams> {
  final TaxiRepository repository;
  GetVehiclesUseCase(this.repository);

  @override
  Future<Either<Failure, VehicleModel>> call(VehiclesParams params) =>
      repository.getVehiclesList(params.body, params.offset);
}

/// Vehicle brand list (filter panel on the select-car screen).
class GetBrandListUseCase implements UseCase<List<BrandModel>, NoParams> {
  final TaxiRepository repository;
  GetBrandListUseCase(this.repository);

  @override
  Future<Either<Failure, List<BrandModel>>> call(NoParams params) =>
      repository.getBrandList();
}

/// Place a trip (booking checkout). The caller supplies the prepared request
/// body; the bloc composes it from the filter body, vehicle and payment index.
class PlaceTripUseCase
    implements UseCase<PlaceTripResult, Map<String, String?>> {
  final TaxiRepository repository;
  PlaceTripUseCase(this.repository);

  @override
  Future<Either<Failure, PlaceTripResult>> call(Map<String, String?> body) =>
      repository.placeTrip(body);
}

/// Google Places details for a selected prediction (pickup/destination pick).
class GetTaxiPlaceDetailsUseCase
    implements UseCase<PlaceDetailsModel, String?> {
  final TaxiRepository repository;
  GetTaxiPlaceDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, PlaceDetailsModel>> call(String? placeId) =>
      repository.getPlaceDetails(placeId);
}

/// Parameters for [GetRouteUseCase]: origin + destination.
class RouteParams extends Equatable {
  final LatLng origin;
  final LatLng destination;

  const RouteParams({required this.origin, required this.destination});

  @override
  List<Object?> get props => [origin, destination];
}

/// Decoded route points between two coordinates (map polyline).
class GetRouteUseCase implements UseCase<List<LatLng>, RouteParams> {
  final TaxiRepository repository;
  GetRouteUseCase(this.repository);

  @override
  Future<Either<Failure, List<LatLng>>> call(RouteParams params) =>
      repository.getRouteBetweenCoordinates(params.origin, params.destination);
}

/// Paginated running-trip list (trip-history ongoing tab).
class GetRunningTripListUseCase implements UseCase<TripModel, int> {
  final TaxiRepository repository;
  GetRunningTripListUseCase(this.repository);

  @override
  Future<Either<Failure, TripModel>> call(int offset) =>
      repository.getRunningTripList(offset);
}
