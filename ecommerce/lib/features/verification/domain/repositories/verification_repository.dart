import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';

abstract class VerificationRepository {
  Future<Either<Failure, String>> forgetPassword(String? phone);
  Future<Either<Failure, String>> resetPassword({
    String? resetToken,
    String? number,
    String? password,
    String? confirmPassword,
  });
  Future<Either<Failure, String>> verifyPhone(String? phone, String otp);
  Future<Either<Failure, String>> verifyToken(String? phone, String token);
}
