import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_new.dart';

class GetDistanceUseCase {
  final CheckoutRepositoryNew _repository;
  const GetDistanceUseCase(this._repository);

  Future<Either<Failure, double>> call(LatLng origin, LatLng destination) =>
      _repository.getDistanceInMeter(origin, destination);
}
