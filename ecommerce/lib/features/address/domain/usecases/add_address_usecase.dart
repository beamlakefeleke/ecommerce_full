import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:ecommerce/features/address/domain/repositories/address_repository.dart';

class AddAddressUseCase implements UseCase<List<int>, Address> {
  final AddressRepository repository;

  AddAddressUseCase(this.repository);

  @override
  Future<Either<Failure, List<int>>> call(Address params) {
    return repository.addAddress(params);
  }
}
