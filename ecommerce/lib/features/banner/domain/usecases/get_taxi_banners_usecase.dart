import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/banner/domain/entities/banner.dart';
import 'package:ecommerce/features/banner/domain/repositories/banner_repository.dart';

class GetTaxiBannersUseCase implements UseCase<BannerCollection, NoParams> {
  final BannerRepository repository;

  GetTaxiBannersUseCase(this.repository);

  @override
  Future<Either<Failure, BannerCollection>> call(NoParams params) {
    return repository.getTaxiBanners();
  }
}
