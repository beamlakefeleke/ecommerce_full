import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserInfo>> getUserInfo() async {
    try {
      final userInfo = await remoteDataSource.getUserInfo();
      if (userInfo != null) {
        return Right(userInfo);
      } else {
        return Left(ServerFailure('Failed to parse user info'));
      }
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserInfo>> updateProfile(UserInfo userInfo, XFile? avatar, String token) async {
    try {
      await remoteDataSource.updateProfile(userInfo, avatar, token);
      final updatedInfo = await remoteDataSource.getUserInfo();
      if (updatedInfo != null) {
        return Right(updatedInfo);
      } else {
        return Left(ServerFailure('Failed to fetch updated profile'));
      }
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(UserInfo userInfo) async {
    try {
      await remoteDataSource.changePassword(userInfo);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser() async {
    try {
      await remoteDataSource.deleteUser();
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
