import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart';

/// Immutable states emitted by [AuthBloc].
///
/// Named with past-tense / descriptive convention per RULES.md §3.
/// No mutable fields, no side effects.
sealed class AuthState {
  const AuthState();
}

/// Initial state — loaded with remembered credentials if available.
class AuthInitial extends AuthState {
  final bool isRememberMeActive;
  final bool acceptTerms;
  final String savedNumber;
  final String savedPassword;
  final String savedCountryCode;
  final bool isNotificationActive;

  const AuthInitial({
    this.isRememberMeActive = false,
    this.acceptTerms = true,
    this.savedNumber = '',
    this.savedPassword = '',
    this.savedCountryCode = '',
    this.isNotificationActive = true,
  });

  AuthInitial copyWith({
    bool? isRememberMeActive,
    bool? acceptTerms,
    String? savedNumber,
    String? savedPassword,
    String? savedCountryCode,
    bool? isNotificationActive,
  }) {
    return AuthInitial(
      isRememberMeActive: isRememberMeActive ?? this.isRememberMeActive,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      savedNumber: savedNumber ?? this.savedNumber,
      savedPassword: savedPassword ?? this.savedPassword,
      savedCountryCode: savedCountryCode ?? this.savedCountryCode,
      isNotificationActive: isNotificationActive ?? this.isNotificationActive,
    );
  }
}

/// An auth operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Guest login is specifically in progress (separate loading indicator).
class AuthGuestLoading extends AuthState {
  const AuthGuestLoading();
}

/// Login / registration / social auth succeeded.
class AuthSuccess extends AuthState {
  final AuthResponse response;

  const AuthSuccess({required this.response});
}

/// Guest login succeeded.
class AuthGuestSuccess extends AuthState {
  final String guestId;

  const AuthGuestSuccess({required this.guestId});
}

/// Social login returned a user whose phone is not verified.
/// Presentation layer should navigate to the verification screen.
class AuthSocialNeedsVerification extends AuthState {
  final String phone;
  final String token;

  const AuthSocialNeedsVerification({
    required this.phone,
    required this.token,
  });
}

/// Social login returned a user who needs to complete registration.
/// Presentation layer should navigate to the "forgot password" / social
/// registration screen.
class AuthSocialNeedsRegistration extends AuthState {
  final SocialLoginBody body;

  const AuthSocialNeedsRegistration({required this.body});
}

/// Logout completed successfully.
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

/// An auth operation failed.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});
}
