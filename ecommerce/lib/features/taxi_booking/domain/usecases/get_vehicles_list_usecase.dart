import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import '../repositories/taxi_booking_repository_interface.dart';
import '../entities/vehicle.dart';

class GetVehiclesListUseCase {
  final TaxiBookingRepositoryInterface repository;

  GetVehiclesListUseCase(this.repository);

  Future<Either<Failure, VehicleResponse>> call({required UserInformationBody body, required int offset}) async {
    return await repository.getVehiclesList(body, offset);
  }
}
