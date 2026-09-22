import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import '../repositories/taxi_booking_repository_interface.dart';
import '../models/trip_model.dart';

class GetRunningTripListUseCase {
  final TaxiBookingRepositoryInterface repository;

  GetRunningTripListUseCase(this.repository);

  Future<Either<Failure, TripModel>> call(int offset) async {
    return await repository.getRunningTripList(offset);
  }
}
