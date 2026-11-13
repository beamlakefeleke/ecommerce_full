import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/location/data/datasources/location_remote_data_source.dart';
import 'package:ecommerce/features/location/domain/entities/zone_response.dart';
import 'package:ecommerce/features/location/domain/models/prediction_model.dart';
import 'package:ecommerce/features/location/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> getAddressFromGeocode(LatLng latLng) {
    return _guard(() => remoteDataSource.getAddressFromGeocode(latLng));
  }

  @override
  Future<Either<Failure, ZoneResult>> getZone(
    String? lat,
    String? lng, {
    bool handleError = false,
  }) {
    return _guard(
      () => remoteDataSource.getZone(lat, lng, handleError: handleError),
    );
  }

  @override
  Future<Either<Failure, List<PredictionModel>>> searchLocation(String text) {
    return _guard(() => remoteDataSource.searchLocation(text));
  }

  @override
  Future<Either<Failure, LatLng>> getLatLng(String? placeId) {
    return _guard(() => remoteDataSource.getLatLng(placeId));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
