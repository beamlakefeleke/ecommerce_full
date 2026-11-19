import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ecommerce/features/profile/domain/models/userinfo_model.dart';
import 'package:ecommerce/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserInfoModel>> getUserInfo() =>
      _guard(() => remoteDataSource.getUserInfo());

  @override
  Future<Either<Failure, ResponseModel>> updateProfile(
    UserInfoModel userInfoModel,
    XFile? pickedImage,
  ) => _guard(() => remoteDataSource.updateProfile(userInfoModel, pickedImage));

  @override
  Future<Either<Failure, ResponseModel>> changePassword(
    UserInfoModel userInfoModel,
  ) => _guard(() => remoteDataSource.changePassword(userInfoModel));

  @override
  Future<Either<Failure, ResponseModel>> deleteUser() =>
      _guard(() => remoteDataSource.deleteUser());

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
