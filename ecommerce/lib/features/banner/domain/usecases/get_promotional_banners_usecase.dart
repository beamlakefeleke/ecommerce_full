import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/banner/domain/entities/promotional_banner.dart';
import 'package:ecommerce/features/banner/domain/repositories/banner_repository.dart';

class GetPromotionalBannersUseCase
    implements UseCase<PromotionalBannerEntity, NoParams> {
  final BannerRepository repository;

  GetPromotionalBannersUseCase(this.repository);

  @override
  Future<Either<Failure, PromotionalBannerEntity>> call(NoParams params) {
    return repository.getPromotionalBanners();
  }
}
