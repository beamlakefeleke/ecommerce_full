import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Queries the current authentication status from local storage.
///
/// Synchronous checks — no network calls. Used by many features
/// to gate authenticated-only actions.
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  const CheckAuthStatusUseCase(this._repository);

  bool isLoggedIn() => _repository.isLoggedIn();

  bool isGuestLoggedIn() => _repository.isGuestLoggedIn();

  String getGuestId() => _repository.getGuestId();

  String getUserToken() => _repository.getUserToken();
}
