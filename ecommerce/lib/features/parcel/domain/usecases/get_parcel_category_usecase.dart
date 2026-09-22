import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_category.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class GetParcelCategoryUseCase {
  final ParcelRepositoryInterface repository;

  GetParcelCategoryUseCase(this.repository);

  Future<Either<Failure, List<ParcelCategory>>> call() async {
    return await repository.getParcelCategoryList();
  }
}
