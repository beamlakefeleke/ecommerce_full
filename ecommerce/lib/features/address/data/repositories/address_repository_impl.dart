import 'package:fpdart/fpdart.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/address/data/datasources/address_remote_data_source.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:ecommerce/features/address/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Address>>> getAddresses() async {
    try {
      final models = await remoteDataSource.getAddresses();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> addAddress(Address address) async {
    try {
      final zoneIds = await remoteDataSource.addAddress(
        AddressModel.fromEntity(address),
      );
      return Right(zoneIds);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      final message = e.message == 'Out of coverage!'
          ? 'service_not_available_in_this_area'.tr
          : e.message;
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateAddress(
    Address address,
    int? id,
  ) async {
    try {
      final message = await remoteDataSource.updateAddress(
        AddressModel.fromEntity(address).toJson(),
        id,
      );
      return Right(message);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteAddress(int? id) async {
    try {
      final message = await remoteDataSource.deleteAddress(id);
      return Right(message);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
