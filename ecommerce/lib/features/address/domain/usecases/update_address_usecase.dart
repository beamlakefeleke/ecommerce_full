import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:ecommerce/features/address/domain/repositories/address_repository.dart';

class UpdateAddressParams extends Equatable {
  final Address address;
  final int? id;

  const UpdateAddressParams({required this.address, required this.id});

  @override
  List<Object?> get props => [address, id];
}

class UpdateAddressUseCase implements UseCase<String, UpdateAddressParams> {
  final AddressRepository repository;

  UpdateAddressUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateAddressParams params) {
    return repository.updateAddress(params.address, params.id);
  }
}
