import 'package:fpdart/fpdart.dart';
import 'package:get/get_connect/connect.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ecommerce/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce/features/auth/data/models/signup_body_model.dart';
import 'package:ecommerce/features/auth/data/models/social_log_in_body.dart';
import 'package:ecommerce/features/auth/domain/entities/auth_response.dart';
import 'package:ecommerce/features/auth/domain/entities/sign_up_params.dart';
import 'package:ecommerce/features/auth/domain/entities/social_sign_in_params.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, AuthResponse>> register(
    SignUpParams params,
    bool isCustomerVerificationOn,
  ) async {
    try {
      final token = await remote.register(SignUpBodyModel.fromEntity(params));
      if (!isCustomerVerificationOn) {
        await local.saveUserToken(token);
        await remote.updateToken();
        await local.clearGuestId();
      }
      return Right(AuthResponse(token: token, isPhoneVerified: true));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login({
    String? phone,
    String? password,
    required bool isCustomerVerificationOn,
  }) async {
    try {
      final Response response = await remote.login(
        phone: phone,
        password: password,
        guestId: local.getGuestId(),
      );
      if (response.statusCode == 200) {
        final bool phoneVerified = response.body['is_phone_verified'] == 1;
        final String token = response.body['token'] ?? '';
        if (!(isCustomerVerificationOn && !phoneVerified)) {
          await local.saveUserToken(token);
          await remote.updateToken();
          await local.clearGuestId();
        }
        return Right(
          AuthResponse(token: token, isPhoneVerified: phoneVerified),
        );
      }
      return Left(ServerFailure(response.statusText ?? 'Login failed'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> guestLogin() async {
    try {
      final deviceToken = await remote.deviceToken();
      final guestId = await remote.guestLogin(deviceToken);
      await local.saveGuestId(guestId);
      return Right(guestId);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialAuthResult>> loginWithSocialMedia(
    SocialSignInParams params,
    int timeout,
    bool isCustomerVerificationOn,
  ) async {
    try {
      final Response response = await remote.loginWithSocialMedia(
        SocialLogInBody.fromEntity(params),
        timeout,
      );
      if (response.statusCode == 200) {
        final String? token = response.body['token'];
        if (token != null && token.isNotEmpty) {
          if (isCustomerVerificationOn &&
              response.body['is_phone_verified'] == 0) {
            return Right(
              SocialAuthResult(
                outcome: SocialAuthOutcome.needsVerification,
                token: token,
                phone: response.body['phone'] ?? params.email,
              ),
            );
          }
          await local.saveUserToken(token);
          await remote.updateToken();
          await local.clearGuestId();
          return const Right(
            SocialAuthResult(outcome: SocialAuthOutcome.authenticated),
          );
        }
        return const Right(
          SocialAuthResult(outcome: SocialAuthOutcome.needsRegistration),
        );
      } else if (response.statusCode == 403 &&
          response.body['errors'][0]['code'] == 'email') {
        return const Right(
          SocialAuthResult(outcome: SocialAuthOutcome.needsRegistration),
        );
      }
      return Right(
        SocialAuthResult(
          outcome: SocialAuthOutcome.failed,
          message: response.statusText,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SocialAuthResult>> registerWithSocialMedia(
    SocialSignInParams params,
    bool isCustomerVerificationOn,
  ) async {
    try {
      final Response response = await remote.registerWithSocialMedia(
        SocialLogInBody.fromEntity(params),
      );
      if (response.statusCode == 200) {
        final String? token = response.body['token'];
        if (isCustomerVerificationOn &&
            response.body['is_phone_verified'] == 0) {
          return Right(
            SocialAuthResult(
              outcome: SocialAuthOutcome.needsVerification,
              token: token,
              phone: params.phone,
            ),
          );
        }
        await local.saveUserToken(token ?? '');
        await remote.updateToken();
        await local.clearGuestId();
        return const Right(
          SocialAuthResult(outcome: SocialAuthOutcome.authenticated),
        );
      }
      return Right(
        SocialAuthResult(
          outcome: SocialAuthOutcome.failed,
          message: response.statusText,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<void> updateToken() => remote.updateToken();

  @override
  Future<void> updateZone() => remote.updateZone();

  // --- local passthrough ---
  @override
  bool isLoggedIn() => local.isLoggedIn();
  @override
  bool isGuestLoggedIn() => local.isGuestLoggedIn();
  @override
  String getGuestId() => local.getGuestId();
  @override
  bool clearSharedData() => local.clearSharedData();
  @override
  Future<bool> clearSharedAddress() => local.clearSharedAddress();
  @override
  bool isNotificationActive() => local.isNotificationActive();
  @override
  void setNotificationActive(bool isActive) =>
      local.setNotificationActive(isActive);
  @override
  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  ) => local.saveUserNumberAndPassword(number, password, countryCode);
  @override
  String getUserNumber() => local.getUserNumber();
  @override
  String getUserCountryCode() => local.getUserCountryCode();
  @override
  String getUserPassword() => local.getUserPassword();
  @override
  Future<bool> clearUserNumberAndPassword() =>
      local.clearUserNumberAndPassword();
  @override
  String getUserToken() => local.getUserToken();
  @override
  Future<bool> saveGuestContactNumber(String number) =>
      local.saveGuestContactNumber(number);
  @override
  String getGuestContactNumber() => local.getGuestContactNumber();
  @override
  Future<bool> saveDmTipIndex(String index) => local.saveDmTipIndex(index);
  @override
  String getDmTipIndex() => local.getDmTipIndex();
  @override
  Future<bool> saveEarningPoint(String point) => local.saveEarningPoint(point);
  @override
  String getEarningPoint() => local.getEarningPoint();
}
