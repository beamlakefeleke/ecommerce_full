import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/models/place_details_model.dart';
import '../repositories/taxi_booking_repository_interface.dart';

class GetPlaceDetailsUseCase {
  final TaxiBookingRepositoryInterface repository;

  GetPlaceDetailsUseCase(this.repository);

  Future<Either<Failure, PlaceDetailsModel>> call(String? placeID) async {
    return await repository.getPlaceDetails(placeID);
  }
}
