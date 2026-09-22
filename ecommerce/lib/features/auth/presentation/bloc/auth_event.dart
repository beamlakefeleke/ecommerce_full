import 'package:ecommerce/features/auth/domain/entities/signup_body.dart';
import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart';

/// Events dispatched to [AuthBloc] from the presentation layer.
///
/// Named as imperative verb + noun per RULES.md §3.
sealed class AuthEvent {
  const AuthEvent();
}

/// User submitted phone + password login form.
class LoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const LoginRequested({required this.phone, required this.password});
}

/// User submitted the registration form.
class RegisterRequested extends AuthEvent {
  final SignupBody body;

  const RegisterRequested({required this.body});
}

/// Initiate a guest session (no account needed).
class GuestLoginRequested extends AuthEvent {
  const GuestLoginRequested();
}

/// User tapped a social login button (Google/Facebook/Apple).
class SocialLoginRequested extends AuthEvent {
  final SocialLoginBody body;

  const SocialLoginRequested({required this.body});
}

/// User completing social registration (providing missing phone, etc.).
class SocialRegisterRequested extends AuthEvent {
  final SocialLoginBody body;

  const SocialRegisterRequested({required this.body});
}

/// User requested logout.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Toggle "Remember me" checkbox.
class RememberMeToggled extends AuthEvent {
  const RememberMeToggled();
}

/// Toggle "Accept terms & conditions" checkbox.
class TermsToggled extends AuthEvent {
  const TermsToggled();
}

/// Save token and update FCM after successful auth (used internally).
class TokenPersistenceRequested extends AuthEvent {
  final String token;

  const TokenPersistenceRequested({required this.token});
}
