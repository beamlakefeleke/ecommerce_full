import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/parcel/domain/entities/why_choose.dart';
import 'package:ecommerce/features/parcel/domain/repositories/parcel_repository_interface.dart';
import 'package:fpdart/fpdart.dart';

class GetWhyChooseUseCase {
  final ParcelRepositoryInterface repository;

  GetWhyChooseUseCase(this.repository);

  Future<Either<Failure, WhyChoose>> call() async {
    return await repository.getWhyChooseDetails();
  }
}
