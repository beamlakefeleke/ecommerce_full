import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ecommerce/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce/features/auth/data/models/auth_response_model.dart';
import 'package:ecommerce/features/auth/data/models/signup_body_model.dart';
import 'package:ecommerce/features/auth/data/models/social_login_body_model.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/signup_body.dart';
import 'package:ecommerce/features/auth/domain/entities/social_login_body.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Catches data-source exceptions and converts them to typed [Failure]s.
/// Returns `Either<Failure, T>` — no raw exceptions cross the domain boundary.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final guestId = _localDataSource.getGuestId();
      final response = await _remoteDataSource.login(
        phone: phone,
        password: password,
        guestId: guestId,
      );

      if (response.statusCode == 200) {
        final model = AuthResponseModel.fromJson(response.body);
        return Right(model.toEntity());
      } else {
        return Left(ServerFailure(
          response.statusText ?? 'Login failed',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register(SignupBody body) async {
    try {
      final model = SignupBodyModel.fromEntity(body);
      final response = await _remoteDataSource.register(model.toJson());

      if (response.statusCode == 200) {
        final token = response.body['token'] as String? ?? '';
        return Right(AuthResponse(
          token: token,
          isPhoneVerified: true, // registration doesn't return verification status
        ));
      } else {
        return Left(ServerFailure(
          response.statusText ?? 'Registration failed',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> guestLogin() async {
    try {
      final deviceToken = await _localDataSource.getDeviceToken();
      final response = await _remoteDataSource.guestLogin(deviceToken);

      if (response.statusCode == 200) {
        final guestId = response.body['guest_id'].toString();
        await _localDataSource.saveGuestId(guestId);
        return Right(guestId);
      } else {
        return Left(ServerFailure(
          response.statusText ?? 'Guest login failed',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> loginWithSocialMedia(
    SocialLoginBody body, {
    int timeout = 60,
  }) async {
    try {
      final model = SocialLoginBodyModel.fromEntity(body);
      final response = await _remoteDataSource.loginWithSocialMedia(
        model.toJson(),
        timeout: timeout,
      );

      if (response.statusCode == 200) {
        final authModel = AuthResponseModel.fromJson(response.body);
        return Right(authModel.toEntity());
      } else if (response.statusCode == 403) {
        // 403 with email error code → user needs to register
        final errors = response.body['errors'] as List<dynamic>?;
        if (errors != null &&
            errors.isNotEmpty &&
            errors[0]['code'] == 'email') {
          return Right(const AuthResponse(
            token: '',
            isPhoneVerified: false,
          ));
        }
        return Left(ServerFailure(
          response.statusText ?? 'Social login forbidden',
          statusCode: 403,
        ));
      } else {
        return Left(ServerFailure(
          response.statusText ?? 'Social login failed',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> registerWithSocialMedia(
    SocialLoginBody body,
  ) async {
    try {
      final model = SocialLoginBodyModel.fromEntity(body);
      final response =
          await _remoteDataSource.registerWithSocialMedia(model.toJson());

      if (response.statusCode == 200) {
        final authModel = AuthResponseModel.fromJson(response.body);
        return Right(authModel.toEntity());
      } else {
        return Left(ServerFailure(
          response.statusText ?? 'Social registration failed',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserToken(String token) async {
    try {
      await _localDataSource.saveUserToken(token);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateToken() async {
    try {
      await _localDataSource.setupNotifications();
      final deviceToken = await _localDataSource.getDeviceToken();
      final response =
          await _remoteDataSource.updateToken(deviceToken ?? '@');
      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(
          response.statusText ?? 'Token update failed',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateZone() async {
    try {
      final response = await _remoteDataSource.updateZone();
      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(
          response.statusText ?? 'Zone update failed',
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ─── Delegated local operations ───────────────────────────────────

  @override
  bool clearSharedData() => _localDataSource.clearSharedData();

  @override
  Future<bool> clearSharedAddress() => _localDataSource.clearSharedAddress();

  @override
  bool isLoggedIn() => _localDataSource.isLoggedIn();

  @override
  bool isGuestLoggedIn() => _localDataSource.isGuestLoggedIn();

  @override
  String getGuestId() => _localDataSource.getGuestId();

  @override
  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  ) =>
      _localDataSource.saveUserNumberAndPassword(number, password, countryCode);

  @override
  String getUserNumber() => _localDataSource.getUserNumber();

  @override
  String getUserCountryCode() => _localDataSource.getUserCountryCode();

  @override
  String getUserPassword() => _localDataSource.getUserPassword();

  @override
  Future<bool> clearUserNumberAndPassword() =>
      _localDataSource.clearUserNumberAndPassword();

  @override
  String getUserToken() => _localDataSource.getUserToken();

  @override
  Future<bool> saveGuestContactNumber(String number) =>
      _localDataSource.saveGuestContactNumber(number);

  @override
  String getGuestContactNumber() =>
      _localDataSource.getGuestContactNumber();

  @override
  bool isNotificationActive() => _localDataSource.isNotificationActive();

  @override
  void setNotificationActive(bool isActive) {
    if (isActive) {
      updateToken();
    } else {
      _localDataSource.unsubscribeNotifications();
      _remoteDataSource.updateToken('@');
    }
    _localDataSource.setNotificationActive(isActive);
  }

  @override
  Future<bool> clearGuestId() => _localDataSource.clearGuestId();
}
