import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// App-wide session query helper. Session state (logged-in / guest / token) is
/// infra, not UI state, so it is read straight from the migrated
/// [AuthRepository] via get_it — not from a Bloc.
class AuthHelper {
  static AuthRepository get _repo => getIt<AuthRepository>();

  static bool isGuestLoggedIn() => _repo.isGuestLoggedIn();

  static String getGuestId() => _repo.getGuestId();

  static bool isLoggedIn() => _repo.isLoggedIn();
}
