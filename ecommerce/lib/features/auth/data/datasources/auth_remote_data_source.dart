import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/connect.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/auth/data/models/signup_body_model.dart';
import 'package:ecommerce/features/auth/data/models/social_log_in_body.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Raw API access for auth. Returns the GetX [Response] for the social
/// endpoints (the repository inspects status/body to decide the branch) and
/// throws [ServerException]/[NetworkException] for the simple register/login/
/// guest flows.
abstract class AuthRemoteDataSource {
  /// Returns the registration token on success.
  Future<String> register(SignUpBodyModel body);

  Future<Response> login({String? phone, String? password, String? guestId});

  Future<String> guestLogin(String? deviceToken);

  Future<Response> loginWithSocialMedia(SocialLogInBody body, int timeout);
  Future<Response> registerWithSocialMedia(SocialLogInBody body);

  Future<Response> updateToken({String notificationDeviceToken});
  Future<void> updateZone();
  Future<void> clearRemoteToken();

  Future<String?> deviceToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> register(SignUpBodyModel body) async {
    final Response response = await apiClient.postData(
      AppConstants.registerUri,
      body.toJson(),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return response.body['token'];
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Response> login({
    String? phone,
    String? password,
    String? guestId,
  }) async {
    final Map<String, String> data = {
      "phone": phone ?? '',
      "password": password ?? '',
    };
    if (guestId != null && guestId.isNotEmpty) {
      data.addAll({"guest_id": guestId});
    }
    return apiClient.postData(AppConstants.loginUri, data, handleError: false);
  }

  @override
  Future<String> guestLogin(String? deviceToken) async {
    final Response response = await apiClient.postData(
      AppConstants.guestLoginUri,
      {'fcm_token': deviceToken},
    );
    if (response.statusCode == 200) {
      return response.body['guest_id'].toString();
    }
    throw _exceptionFor(response);
  }

  @override
  Future<Response> loginWithSocialMedia(SocialLogInBody body, int timeout) {
    return apiClient.postData(
      AppConstants.socialLoginUri,
      body.toJson(),
      timeout: timeout,
    );
  }

  @override
  Future<Response> registerWithSocialMedia(SocialLogInBody body) {
    return apiClient.postData(AppConstants.socialRegisterUri, body.toJson());
  }

  @override
  Future<Response> updateToken({String notificationDeviceToken = ''}) async {
    String? token;
    if (notificationDeviceToken.isEmpty) {
      if (GetPlatform.isIOS && !GetPlatform.isWeb) {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        final NotificationSettings settings = await FirebaseMessaging.instance
            .requestPermission(
              alert: true,
              announcement: false,
              badge: true,
              carPlay: false,
              criticalAlert: false,
              provisional: false,
              sound: true,
            );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          token = await deviceToken();
        }
      } else {
        token = await deviceToken();
      }
      if (!GetPlatform.isWeb) {
        FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
      }
    }
    return apiClient.postData(AppConstants.tokenUri, {
      "_method": "put",
      "cm_firebase_token": notificationDeviceToken.isNotEmpty
          ? notificationDeviceToken
          : token,
    }, handleError: false);
  }

  @override
  Future<void> updateZone() async {
    await apiClient.getData(AppConstants.updateZoneUri);
  }

  @override
  Future<void> clearRemoteToken() async {
    if (!GetPlatform.isWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      await apiClient.postData(AppConstants.tokenUri, {
        "_method": "put",
        "cm_firebase_token": '@',
      }, handleError: false);
    }
  }

  @override
  Future<String?> deviceToken() async {
    String? token = '@';
    if (!GetPlatform.isWeb) {
      try {
        token = (await FirebaseMessaging.instance.getToken())!;
      } catch (_) {}
    }
    if (token != null && kDebugMode) {
      print('--------Device Token---------- $token');
    }
    return token;
  }

  Exception _exceptionFor(Response response) {
    if (response.statusCode == null ||
        response.statusCode == 0 ||
        response.statusCode == 1) {
      return NetworkException(response.statusText ?? 'No internet connection');
    }
    return ServerException(response.statusText ?? 'Server error');
  }
}
