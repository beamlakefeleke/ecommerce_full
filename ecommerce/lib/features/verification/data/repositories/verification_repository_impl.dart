import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/verification/data/datasources/verification_remote_data_source.dart';
import 'package:ecommerce/features/verification/domain/repositories/verification_repository.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;

  VerificationRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> forgetPassword(String? phone) =>
      _guard(() => remoteDataSource.forgetPassword(phone));

  @override
  Future<Either<Failure, String>> resetPassword({
    String? resetToken,
    String? number,
    String? password,
    String? confirmPassword,
  }) =>
      _guard(() => remoteDataSource.resetPassword(
            resetToken: resetToken,
            number: number,
            password: password,
            confirmPassword: confirmPassword,
          ));

  @override
  Future<Either<Failure, String>> verifyPhone(String? phone, String otp) =>
      _guard(() => remoteDataSource.verifyPhone(phone, otp));

  @override
  Future<Either<Failure, String>> verifyToken(String? phone, String token) =>
      _guard(() => remoteDataSource.verifyToken(phone, token));
}
