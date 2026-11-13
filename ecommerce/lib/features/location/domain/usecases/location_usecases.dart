import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/location/domain/entities/zone_response.dart';
import 'package:ecommerce/features/location/domain/models/prediction_model.dart';
import 'package:ecommerce/features/location/domain/repositories/location_repository.dart';

// ── Params ───────────────────────────────────────────────────────────────────

class LatLngParams extends Equatable {
  final LatLng latLng;
  const LatLngParams(this.latLng);

  @override
  List<Object?> get props => [latLng.latitude, latLng.longitude];
}

class ZoneParams extends Equatable {
  final String? lat;
  final String? lng;
  final bool handleError;
  const ZoneParams({required this.lat, required this.lng, this.handleError = false});

  @override
  List<Object?> get props => [lat, lng, handleError];
}

class SearchLocationParams extends Equatable {
  final String text;
  const SearchLocationParams(this.text);

  @override
  List<Object?> get props => [text];
}

class PlaceIdParams extends Equatable {
  final String? placeId;
  const PlaceIdParams(this.placeId);

  @override
  List<Object?> get props => [placeId];
}

// ── UseCases ───────────────────────────────────────────────────────────────── 

class GetAddressFromGeocodeUseCase implements UseCase<String, LatLngParams> {
  final LocationRepository repository;
  GetAddressFromGeocodeUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(LatLngParams params) =>
      repository.getAddressFromGeocode(params.latLng);
}

class GetZoneUseCase implements UseCase<ZoneResult, ZoneParams> {
  final LocationRepository repository;
  GetZoneUseCase(this.repository);

  @override
  Future<Either<Failure, ZoneResult>> call(ZoneParams params) => repository
      .getZone(params.lat, params.lng, handleError: params.handleError);
}

class SearchLocationUseCase
    implements UseCase<List<PredictionModel>, SearchLocationParams> {
  final LocationRepository repository;
  SearchLocationUseCase(this.repository);

  @override
  Future<Either<Failure, List<PredictionModel>>> call(
    SearchLocationParams params,
  ) => repository.searchLocation(params.text);
}

class GetLatLngUseCase implements UseCase<LatLng, PlaceIdParams> {
  final LocationRepository repository;
  GetLatLngUseCase(this.repository);

  @override
  Future<Either<Failure, LatLng>> call(PlaceIdParams params) =>
      repository.getLatLng(params.placeId);
}
