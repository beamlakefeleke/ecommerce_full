import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/common/models/response_model.dart';
import '../repositories/taxi_booking_repository_interface.dart';

class PlaceTripUseCase {
  final TaxiBookingRepositoryInterface repository;

  PlaceTripUseCase(this.repository);

  Future<Either<Failure, ResponseModel>> call(Map<String, String?> data) async {
    return await repository.placeTrip(data);
  }
}
