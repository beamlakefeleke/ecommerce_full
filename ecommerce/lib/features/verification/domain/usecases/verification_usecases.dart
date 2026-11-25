import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/verification/domain/repositories/verification_repository.dart';

class ForgetPasswordParams extends Equatable {
  final String? phone;
  const ForgetPasswordParams(this.phone);
  @override
  List<Object?> get props => [phone];
}

class ResetPasswordParams extends Equatable {
  final String? resetToken;
  final String number;
  final String password;
  final String confirmPassword;

  const ResetPasswordParams({
    this.resetToken,
    required this.number,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props =>
      [resetToken, number, password, confirmPassword];
}

class VerifyPhoneParams extends Equatable {
  final String? phone;
  final String? token;

  const VerifyPhoneParams({this.phone, this.token});
  @override
  List<Object?> get props => [phone, token];
}

class VerifyTokenParams extends Equatable {
  final String? phone;
  final String token;

  const VerifyTokenParams({this.phone, required this.token});
  @override
  List<Object?> get props => [phone, token];
}

class ForgetPasswordUseCase
    implements UseCase<String, ForgetPasswordParams> {
  final VerificationRepository repository;
  ForgetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ForgetPasswordParams params) =>
      repository.forgetPassword(params.phone);
}

class ResetPasswordUseCase
    implements UseCase<String, ResetPasswordParams> {
  final VerificationRepository repository;
  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ResetPasswordParams params) =>
      repository.resetPassword(
        resetToken: params.resetToken,
        number: params.number,
        password: params.password,
        confirmPassword: params.confirmPassword,
      );
}

class VerifyPhoneUseCase
    implements UseCase<String, VerifyPhoneParams> {
  final VerificationRepository repository;
  VerifyPhoneUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(VerifyPhoneParams params) =>
      repository.verifyPhone(params.phone, params.token ?? '');
}

class VerifyTokenUseCase
    implements UseCase<String, VerifyTokenParams> {
  final VerificationRepository repository;
  VerifyTokenUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(VerifyTokenParams params) =>
      repository.verifyToken(params.phone, params.token);
}
