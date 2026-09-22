import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Authenticates a user via a social provider (Google, Facebook, Apple).
///
/// Returns an [AuthResponse] — the BLoC decides how to navigate based
/// on token presence and phone-verification status. No navigation logic
/// lives in this usecase (unlike the legacy AuthService).
class SocialLoginUseCase {
  final AuthRepository _repository;

  const SocialLoginUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call(
    SocialLoginBody body, {
    int timeout = 60,
  }) {
    return _repository.loginWithSocialMedia(body, timeout: timeout);
  }
}
