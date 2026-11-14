import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/onboard/domain/entities/on_boarding.dart';

/// Abstract contract for the onboard feature. Implemented in the data layer.
/// Returns `Either<Failure, T>` — no throwing across the boundary.
abstract class OnboardRepository {
  Future<Either<Failure, List<OnBoarding>>> getOnBoardingList();
}
