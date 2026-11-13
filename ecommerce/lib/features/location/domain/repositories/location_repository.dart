import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/location/domain/entities/zone_response.dart';
import 'package:ecommerce/features/location/domain/models/prediction_model.dart';

/// Clean-architecture contract for the location feature. All methods return
/// `Either<Failure, T>`; the data layer throws `Server/NetworkException` which
/// the impl maps to [Failure].
abstract class LocationRepository {
  /// Reverse-geocode a lat/lng into a human readable address.
  Future<Either<Failure, String>> getAddressFromGeocode(LatLng latLng);

  /// Resolve which delivery zone(s) a coordinate falls into.
  Future<Either<Failure, ZoneResult>> getZone(
    String? lat,
    String? lng, {
    bool handleError = false,
  });

  /// Place autocomplete predictions for a free-text query.
  Future<Either<Failure, List<PredictionModel>>> searchLocation(String text);

  /// Resolve a place id into coordinates.
  Future<Either<Failure, LatLng>> getLatLng(String? placeId);
}
