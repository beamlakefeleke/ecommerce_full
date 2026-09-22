import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repositories/taxi_booking_repository_interface.dart';

class GetRouteBetweenCoordinatesUseCase {
  final TaxiBookingRepositoryInterface repository;

  GetRouteBetweenCoordinatesUseCase(this.repository);

  Future<Either<Failure, dynamic>> call({required LatLng origin, required LatLng destination}) async {
    return await repository.getRouteBetweenCoordinates(origin, destination);
  }
}
