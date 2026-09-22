import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/api/api_checker.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/models/place_details_model.dart';
import 'package:ecommerce/features/taxi_booking/domain/entities/vehicle.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/vehicle_model.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/brand_model.dart';
import 'package:ecommerce/features/taxi_booking/domain/models/trip_model.dart';
import 'package:ecommerce/features/taxi_booking/domain/repositories/taxi_booking_repository_interface.dart';
import 'package:ecommerce/util/app_constants.dart';

class TaxiBookingRepositoryImpl implements TaxiBookingRepositoryInterface {
  final ApiClient apiClient;

  TaxiBookingRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, VehicleResponse>> getVehiclesList(UserInformationBody body, int offset) async {
    try {
      final response = await apiClient.getData('${AppConstants.vehicleListUri}?offset=$offset&limit=10&start_latitude=${body.from!.latitude}'
          '&start_longitude=${body.from!.longitude}&end_latitude=${body.to!.latitude}&end_longitude=${body.to!.longitude}'
          '&fare_category=${body.fareCategory}&distance=${body.distance}&duration=${body.duration}&filter_type=${body.filterType}'
          '&filter_min_price=${body.minPrice.toString() == 'null'?'': body.minPrice}'
          '&filter_max_price=${body.maxPrice.toString() == 'null'?'': body.maxPrice}&'
          'filter_brand=${body.brandModelId.toString() == 'null' ?'': body.brandModelId}&search=');
      if (response.statusCode == 200) {
        return Right(VehicleModel.fromJson(response.body));
      } else {
        ApiChecker.checkApi(response);
        return Left(ServerFailure(response.statusText ?? 'Failed to get vehicles'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BrandModel>>> getBrandList() async {
    try {
      final response = await apiClient.getData(AppConstants.bandListUri);
      if (response.statusCode == 200) {
        List<BrandModel> brands = [];
        response.body.forEach((v) {
          brands.add(BrandModel.fromJson(v));
        });
        return Right(brands);
      } else {
        ApiChecker.checkApi(response);
        return Left(ServerFailure(response.statusText ?? 'Failed to get brands'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlaceDetailsModel>> getPlaceDetails(String? placeID) async {
    try {
      final response = await apiClient.getData('${AppConstants.placeDetailsUri}?placeid=$placeID');
      if (response.statusCode == 200) {
        return Right(PlaceDetailsModel.fromJson(response.body));
      } else {
        ApiChecker.checkApi(response);
        return Left(ServerFailure(response.statusText ?? 'Failed to get place details'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> getRouteBetweenCoordinates(LatLng origin, LatLng destination) async {
    try {
      final response = await apiClient.getData('${AppConstants.directionUri}'
          '?origin_lat=${origin.latitude}&origin_lng=${origin.longitude}'
          '&destination_lat=${destination.latitude}&destination_lng=${destination.longitude}');
      if (response.statusCode == 200) {
        return Right(response.body); // Adjust model if needed
      } else {
        ApiChecker.checkApi(response);
        return Left(ServerFailure(response.statusText ?? 'Failed to get route'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleResponse>> getTopRatedVehiclesList(int offset) async {
    try {
      final response = await apiClient.getData('${AppConstants.topRatedVehiclesListUri}?offset=$offset&limit=10');
      if (response.statusCode == 200) {
        return Right(VehicleModel.fromJson(response.body));
      } else {
        ApiChecker.checkApi(response);
        return Left(ServerFailure(response.statusText ?? 'Failed to get top rated vehicles'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ResponseModel>> placeTrip(Map<String, String?> data) async {
    try {
      final response = await apiClient.postData(AppConstants.tripPlaceUri, data);
      if (response.statusCode == 200) {
        return Right(ResponseModel(true, response.body['message']));
      } else {
        ApiChecker.checkApi(response);
        return Left(ServerFailure(response.statusText ?? 'Failed to place trip'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripModel>> getRunningTripList(int offset) async {
    try {
      final response = await apiClient.getData('${AppConstants.runningTripUri}?offset=$offset&limit=10');
      if (response.statusCode == 200) {
        return Right(TripModel.fromJson(response.body));
      } else {
        ApiChecker.checkApi(response);
        return Left(ServerFailure(response.statusText ?? 'Failed to get running trip list'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
