import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import '../repositories/taxi_booking_repository_interface.dart';
import '../models/brand_model.dart';

class GetBrandListUseCase {
  final TaxiBookingRepositoryInterface repository;

  GetBrandListUseCase(this.repository);

  Future<Either<Failure, List<BrandModel>>> call() async {
    return await repository.getBrandList();
  }
}
