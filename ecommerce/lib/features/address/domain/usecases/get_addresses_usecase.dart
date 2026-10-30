import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:ecommerce/features/address/domain/repositories/address_repository.dart';

class GetAddressesUseCase implements UseCase<List<Address>, NoParams> {
  final AddressRepository repository;

  GetAddressesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Address>>> call(NoParams params) {
    return repository.getAddresses();
  }
}
