import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/signup_body.dart';
import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart';

/// Domain-level contract for authentication operations.
///
/// All methods that can fail return `Either<Failure, T>`.
/// Implemented by [AuthRepositoryImpl] in the data layer.
abstract class AuthRepository {
  /// Authenticate via phone + password.
  Future<Either<Failure, AuthResponse>> login({
    required String phone,
    required String password,
  });

  /// Register a new customer account.
  Future<Either<Failure, AuthResponse>> register(SignupBody body);

  /// Obtain a guest session ID.
  Future<Either<Failure, String>> guestLogin();

  /// Authenticate via a social provider (Google, Facebook, Apple).
  Future<Either<Failure, AuthResponse>> loginWithSocialMedia(
    SocialLoginBody body, {
    int timeout = 60,
  });

  /// Complete social registration (user provides missing phone/details).
  Future<Either<Failure, AuthResponse>> registerWithSocialMedia(
    SocialLoginBody body,
  );

  /// Persist the user's auth token locally and update API headers.
  Future<Either<Failure, void>> saveUserToken(String token);

  /// Push the device FCM token to the server.
  Future<Either<Failure, void>> updateToken();

  /// Refresh the user's zone information.
  Future<Either<Failure, void>> updateZone();

  /// Clear all session data (token, guest ID, cart, address, API headers).
  bool clearSharedData();

  /// Clear only the stored address.
  Future<bool> clearSharedAddress();

  // ─── Synchronous auth-status checks ─────────────────────────────────

  /// Whether a logged-in user token exists locally.
  bool isLoggedIn();

  /// Whether a guest ID exists locally.
  bool isGuestLoggedIn();

  /// Return the stored guest ID (empty string if none).
  String getGuestId();

  // ─── Remembered credentials ─────────────────────────────────────────

  /// Save the user's phone, password, and country code for "Remember me".
  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  );

  String getUserNumber();
  String getUserCountryCode();
  String getUserPassword();
  Future<bool> clearUserNumberAndPassword();

  /// Return the raw user auth token string.
  String getUserToken();

  // ─── Guest contact ──────────────────────────────────────────────────

  Future<bool> saveGuestContactNumber(String number);
  String getGuestContactNumber();

  // ─── Notification preference ────────────────────────────────────────

  bool isNotificationActive();
  void setNotificationActive(bool isActive);

  // ─── Guest ID management ────────────────────────────────────────────

  Future<bool> clearGuestId();
}
