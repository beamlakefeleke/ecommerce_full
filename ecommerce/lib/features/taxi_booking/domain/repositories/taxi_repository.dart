import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/models/brand_model.dart';
import 'package:ecommerce/features/taxi_booking/models/trip_model.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';

/// Result of placing a trip.
class PlaceTripResult {
  final bool isSuccess;
  final String? message;
  final int? tripId;

  const PlaceTripResult({required this.isSuccess, this.message, this.tripId});
}

/// Abstract contract for the taxi-booking feature.
abstract class TaxiRepository {
  Future<Either<Failure, VehicleModel>> getTopRatedVehicles(int offset);
  Future<Either<Failure, VehicleModel>> getVehiclesList(
    UserInformationBody body,
    int offset,
  );
  Future<Either<Failure, List<BrandModel>>> getBrandList();
  Future<Either<Failure, PlaceTripResult>> placeTrip(Map<String, String?> body);
  Future<Either<Failure, PlaceDetailsModel>> getPlaceDetails(String? placeId);

  /// Decoded route points between two coordinates (empty when none found).
  Future<Either<Failure, List<LatLng>>> getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  );
  Future<Either<Failure, TripModel>> getRunningTripList(int offset);
}
