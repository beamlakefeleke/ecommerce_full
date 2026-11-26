import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/data/datasources/taxi_remote_data_source.dart';
import 'package:ecommerce/features/taxi_booking/domain/repositories/taxi_repository.dart';
import 'package:ecommerce/features/taxi_booking/models/brand_model.dart';
import 'package:ecommerce/features/taxi_booking/models/trip_model.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';

class TaxiRepositoryImpl implements TaxiRepository {
  final TaxiRemoteDataSource remoteDataSource;

  TaxiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VehicleModel>> getTopRatedVehicles(int offset) =>
      _guard(() => remoteDataSource.getTopRatedVehicles(offset));

  @override
  Future<Either<Failure, VehicleModel>> getVehiclesList(
    UserInformationBody body,
    int offset,
  ) => _guard(() => remoteDataSource.getVehiclesList(body, offset));

  @override
  Future<Either<Failure, List<BrandModel>>> getBrandList() =>
      _guard(() => remoteDataSource.getBrandList());

  @override
  Future<Either<Failure, PlaceTripResult>> placeTrip(
    Map<String, String?> body,
  ) => _guard(() async {
    final result = await remoteDataSource.placeTrip(body);
    return PlaceTripResult(
      isSuccess: true,
      message: result['message'] as String?,
      tripId: result['trip_id'] as int?,
    );
  });

  @override
  Future<Either<Failure, PlaceDetailsModel>> getPlaceDetails(String? placeId) =>
      _guard(() => remoteDataSource.getPlaceDetails(placeId));

  @override
  Future<Either<Failure, List<LatLng>>> getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  ) => _guard(() async {
    final body = await remoteDataSource.getRouteBetweenCoordinates(
      origin,
      destination,
    );
    final List<LatLng> coordinates = [];
    if (body['status']?.toString().toLowerCase() == 'ok' &&
        body['routes'] != null &&
        (body['routes'] as List).isNotEmpty) {
      coordinates.addAll(
        _decodeEncodedPolyline(
          body['routes'][0]['overview_polyline']['points'],
        ),
      );
    }
    return coordinates;
  });

  @override
  Future<Either<Failure, TripModel>> getRunningTripList(int offset) =>
      _guard(() => remoteDataSource.getRunningTripList(offset));

  /// Decodes a Google "encoded polyline" string into points.
  List<LatLng> _decodeEncodedPolyline(String encoded) {
    final List<LatLng> poly = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }

  /// Shared try/catch that maps data-layer exceptions to [Failure]s.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
