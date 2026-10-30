import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/sign_up_params.dart';
import 'package:ecommerce/features/auth/domain/entities/social_sign_in_params.dart';

/// Result of a social sign-in attempt. Mirrors the branching the legacy
/// AuthService did (navigate to verification / forgot-password / location).
enum SocialAuthOutcome {
  authenticated, // token saved, proceed to location
  needsVerification, // phone not verified -> verification screen
  needsRegistration, // email not found -> forgot/register flow
  failed,
}

class SocialAuthResult {
  final SocialAuthOutcome outcome;
  final String? token;
  final String? phone;
  final String? message;

  const SocialAuthResult({
    required this.outcome,
    this.token,
    this.phone,
    this.message,
  });
}

abstract class AuthRepository {
  // --- remote auth ---
  Future<Either<Failure, AuthResponse>> register(
    SignUpParams params,
    bool isCustomerVerificationOn,
  );

  Future<Either<Failure, AuthResponse>> login({
    String? phone,
    String? password,
    required bool isCustomerVerificationOn,
  });

  Future<Either<Failure, String>> guestLogin();

  Future<Either<Failure, SocialAuthResult>> loginWithSocialMedia(
    SocialSignInParams params,
    int timeout,
    bool isCustomerVerificationOn,
  );

  Future<Either<Failure, SocialAuthResult>> registerWithSocialMedia(
    SocialSignInParams params,
    bool isCustomerVerificationOn,
  );

  Future<void> updateToken();
  Future<void> updateZone();

  // --- local session state (SharedPreferences) ---
  bool isLoggedIn();
  bool isGuestLoggedIn();
  String getGuestId();
  bool clearSharedData();
  Future<bool> clearSharedAddress();

  bool isNotificationActive();
  void setNotificationActive(bool isActive);

  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  );
  String getUserNumber();
  String getUserCountryCode();
  String getUserPassword();
  Future<bool> clearUserNumberAndPassword();
  String getUserToken();

  Future<bool> saveGuestContactNumber(String number);
  String getGuestContactNumber();

  Future<bool> saveDmTipIndex(String index);
  String getDmTipIndex();
  Future<bool> saveEarningPoint(String point);
  String getEarningPoint();
}
