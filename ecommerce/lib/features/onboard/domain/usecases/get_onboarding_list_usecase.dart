import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/onboard/domain/entities/on_boarding.dart';
import 'package:ecommerce/features/onboard/domain/repositories/onboard_repository.dart';

class GetOnBoardingListUseCase implements UseCase<List<OnBoarding>, NoParams> {
  final OnboardRepository repository;

  GetOnBoardingListUseCase(this.repository);

  @override
  Future<Either<Failure, List<OnBoarding>>> call(NoParams params) {
    return repository.getOnBoardingList();
  }
}
