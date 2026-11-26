import 'package:get/get_connect/connect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/models/brand_model.dart';
import 'package:ecommerce/features/taxi_booking/models/trip_model.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for the taxi-booking feature. Throws [ServerException] /
/// [NetworkException]; the repository converts these to [Failure]s. No GetX
/// `Response` type leaks above this layer.
abstract class TaxiRemoteDataSource {
  Future<VehicleModel> getTopRatedVehicles(int offset);
  Future<VehicleModel> getVehiclesList(UserInformationBody body, int offset);
  Future<List<BrandModel>> getBrandList();

  /// Places a trip. Returns the raw decoded body (`trip_id`, `message`) on
  /// success.
  Future<Map<String, dynamic>> placeTrip(Map<String, String?> body);

  /// Google Places details for a selected prediction.
  Future<PlaceDetailsModel> getPlaceDetails(String? placeId);

  /// Raw directions API body between two coordinates (for polyline decode).
  Future<Map<String, dynamic>> getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  );

  /// Paginated running-trip list.
  Future<TripModel> getRunningTripList(int offset);
}

class TaxiRemoteDataSourceImpl implements TaxiRemoteDataSource {
  final ApiClient apiClient;

  TaxiRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<VehicleModel> getTopRatedVehicles(int offset) async {
    final Response response = await apiClient.getData(
      '${AppConstants.topRatedVehiclesListUri}?offset=$offset&limit=10',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return VehicleModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<VehicleModel> getVehiclesList(
    UserInformationBody body,
    int offset,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.vehicleListUri}?offset=$offset&limit=10'
      '&start_latitude=${body.from!.latitude}'
      '&start_longitude=${body.from!.longitude}'
      '&end_latitude=${body.to!.latitude}'
      '&end_longitude=${body.to!.longitude}'
      '&fare_category=${body.fareCategory}&distance=${body.distance}'
      '&duration=${body.duration}&filter_type=${body.filterType}'
      '&filter_min_price=${body.minPrice.toString() == 'null' ? '' : body.minPrice}'
      '&filter_max_price=${body.maxPrice.toString() == 'null' ? '' : body.maxPrice}'
      '&filter_brand=${body.brandModelId.toString() == 'null' ? '' : body.brandModelId}&search=',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return VehicleModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<List<BrandModel>> getBrandList() async {
    final Response response = await apiClient.getData(
      AppConstants.bandListUri,
      handleError: false,
    );
    if (response.statusCode == 200) {
      final List<BrandModel> list = [];
      if (response.body != null) {
        for (final body in response.body) {
          list.add(BrandModel.fromJson(body));
        }
      }
      return list;
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Map<String, dynamic>> placeTrip(Map<String, String?> body) async {
    final Response response = await apiClient.postData(
      AppConstants.tripPlaceUri,
      body,
      handleError: false,
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<PlaceDetailsModel> getPlaceDetails(String? placeId) async {
    final Response response = await apiClient.getData(
      '${AppConstants.placeDetailsUri}?placeid=$placeId',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return PlaceDetailsModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Map<String, dynamic>> getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    final Response response = await apiClient.getData(
      '${AppConstants.directionUri}'
      '?origin_lat=${origin.latitude}&origin_lng=${origin.longitude}'
      '&destination_lat=${destination.latitude}&destination_lng=${destination.longitude}',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(response.body);
    }
    throw _exceptionFor(response);
  }

  @override
  Future<TripModel> getRunningTripList(int offset) async {
    final Response response = await apiClient.getData(
      '${AppConstants.runningTripUri}?offset=$offset&limit=10',
      handleError: false,
    );
    if (response.statusCode == 200) {
      return TripModel.fromJson(response.body);
    }
    throw _exceptionFor(response);
  }

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
