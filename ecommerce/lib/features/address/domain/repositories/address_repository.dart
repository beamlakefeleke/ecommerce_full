import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';

/// Abstract contract for the address feature. Implemented in the data layer.
/// Every method returns `Either<Failure, T>` — no throwing across the boundary.
abstract class AddressRepository {
  Future<Either<Failure, List<Address>>> getAddresses();

  /// Returns the list of zone ids the created address falls into (used by
  /// checkout to validate the address is within the store's zone).
  Future<Either<Failure, List<int>>> addAddress(Address address);

  Future<Either<Failure, String>> updateAddress(Address address, int? id);

  Future<Either<Failure, String>> deleteAddress(int? id);
}
