import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/banner/domain/entities/parcel_other_banner.dart';
import 'package:ecommerce/features/banner/domain/repositories/banner_repository.dart';

class GetParcelOtherBannersUseCase
    implements UseCase<ParcelOtherBanner, NoParams> {
  final BannerRepository repository;

  GetParcelOtherBannersUseCase(this.repository);

  @override
  Future<Either<Failure, ParcelOtherBanner>> call(NoParams params) {
    return repository.getParcelOtherBanners();
  }
}
