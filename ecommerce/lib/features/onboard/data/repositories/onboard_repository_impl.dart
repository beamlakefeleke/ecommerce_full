import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/onboard/data/datasources/onboard_local_data_source.dart';
import 'package:ecommerce/features/onboard/domain/entities/on_boarding.dart';
import 'package:ecommerce/features/onboard/domain/repositories/onboard_repository.dart';

class OnboardRepositoryImpl implements OnboardRepository {
  final OnboardLocalDataSource localDataSource;

  OnboardRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<OnBoarding>>> getOnBoardingList() async {
    try {
      final models = localDataSource.getOnBoardingList();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
