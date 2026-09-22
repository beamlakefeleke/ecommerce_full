import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/entities/place_details.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class GetPlaceDetailsUseCase {
  final ParcelRepositoryInterface repository;

  GetPlaceDetailsUseCase(this.repository);

  Future<Either<Failure, PlaceDetails>> call(String placeId) async {
    return await repository.getPlaceDetails(placeId);
  }
}
