import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Clears all session data and disconnects social providers.
///
/// This usecase handles the side effects of logging out:
/// token removal, guest ID removal, cart clearing, FCM unsubscription.
/// Social provider disconnect (Google/Facebook) is handled at the
/// presentation layer since it requires platform SDK calls.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  /// Returns `true` if shared data was cleared successfully.
  bool call() {
    return _repository.clearSharedData();
  }
}
