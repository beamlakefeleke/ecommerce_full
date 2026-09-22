import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/models/place_details_model.dart';

import '../models/brand_model.dart';
import '../models/trip_model.dart';
import '../entities/vehicle.dart';

abstract class TaxiBookingRepositoryInterface {
  Future<Either<Failure, VehicleResponse>> getVehiclesList(UserInformationBody body, int offset);
  Future<Either<Failure, List<BrandModel>>> getBrandList();
  Future<Either<Failure, PlaceDetailsModel>> getPlaceDetails(String? placeID);
  Future<Either<Failure, dynamic>> getRouteBetweenCoordinates(LatLng origin, LatLng destination);
  Future<Either<Failure, VehicleResponse>> getTopRatedVehiclesList(int offset);
  Future<Either<Failure, ResponseModel>> placeTrip(Map<String, String?> data);
  Future<Either<Failure, TripModel>> getRunningTripList(int offset);
}
