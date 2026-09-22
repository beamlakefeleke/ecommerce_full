import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import '../repositories/taxi_booking_repository_interface.dart';
import '../entities/vehicle.dart';

class GetTopRatedVehiclesListUseCase {
  final TaxiBookingRepositoryInterface repository;

  GetTopRatedVehiclesListUseCase(this.repository);

  Future<Either<Failure, VehicleResponse>> call(int offset) async {
    return await repository.getTopRatedVehiclesList(offset);
  }
}
