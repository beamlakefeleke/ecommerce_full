import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/address/domain/repositories/address_repository.dart';

class DeleteAddressUseCase implements UseCase<String, int?> {
  final AddressRepository repository;

  DeleteAddressUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(int? params) {
    return repository.deleteAddress(params);
  }
}
