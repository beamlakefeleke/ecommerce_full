import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Completes social registration when the social login indicates the
/// user needs to provide additional details (e.g. phone number).
class SocialRegisterUseCase {
  final AuthRepository _repository;

  const SocialRegisterUseCase(this._repository);

  Future<Either<Failure, AuthResponse>> call(SocialLoginBody body) {
    return _repository.registerWithSocialMedia(body);
  }
}
