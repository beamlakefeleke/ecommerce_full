import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';

class GetDistanceParams extends Equatable {
  final LatLng origin;
  final LatLng destination;
  final bool isDuration;
  const GetDistanceParams({
    required this.origin,
    required this.destination,
    this.isDuration = false,
  });
  @override
  List<Object?> get props => [origin, destination, isDuration];
}

class GetDistanceUseCase implements UseCase<double, GetDistanceParams> {
  final CheckoutRepository repository;
  GetDistanceUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(GetDistanceParams params) =>
      repository.getDistanceInKm(
        params.origin,
        params.destination,
        isDuration: params.isDuration,
      );
}
