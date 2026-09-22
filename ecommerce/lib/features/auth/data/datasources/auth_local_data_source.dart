import 'dart:convert';

import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles all auth-related local storage operations
/// (SharedPreferences, FCM token, API header updates).
class AuthLocalDataSource {
  final SharedPreferences _prefs;
  final ApiClient _apiClient;

  const AuthLocalDataSource(this._prefs, this._apiClient);

  // ─── Token management ─────────────────────────────────────────────

  Future<bool> saveUserToken(String token) async {
    _apiClient.token = token;
    if (_prefs.getString(AppConstants.userAddress) != null) {
      final addressModel = AddressModel.fromJson(
        jsonDecode(_prefs.getString(AppConstants.userAddress)!),
      );
      _apiClient.updateHeader(
        token,
        addressModel.zoneIds,
        addressModel.areaIds,
        _prefs.getString(AppConstants.languageCode),
        ModuleHelper.getModule()?.id,
        addressModel.latitude,
        addressModel.longitude,
      );
    } else {
      _apiClient.updateHeader(
        token,
        null,
        null,
        _prefs.getString(AppConstants.languageCode),
        ModuleHelper.getModule()?.id,
        null,
        null,
      );
    }
    return _prefs.setString(AppConstants.token, token);
  }

  String getUserToken() {
    return _prefs.getString(AppConstants.token) ?? '';
  }

  bool isLoggedIn() {
    return _prefs.containsKey(AppConstants.token);
  }

  // ─── Guest ID management ──────────────────────────────────────────

  Future<bool> saveGuestId(String id) async {
    return _prefs.setString(AppConstants.guestId, id);
  }

  String getGuestId() {
    return _prefs.getString(AppConstants.guestId) ?? '';
  }

  bool isGuestLoggedIn() {
    return _prefs.containsKey(AppConstants.guestId);
  }

  Future<bool> clearGuestId() async {
    return _prefs.remove(AppConstants.guestId);
  }

  // ─── Session clearing ─────────────────────────────────────────────

  bool clearSharedData() {
    if (!GetPlatform.isWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      _apiClient.postData(
        AppConstants.tokenUri,
        {'_method': 'put', 'cm_firebase_token': '@'},
        handleError: false,
      );
    }
    _prefs.remove(AppConstants.token);
    _prefs.remove(AppConstants.guestId);
    _prefs.setStringList(AppConstants.cartList, []);
    _prefs.remove(AppConstants.userAddress);
    _apiClient.token = null;
    _apiClient.updateHeader(null, null, null, null, null, null, null);
    return true;
  }

  Future<bool> clearSharedAddress() async {
    await _prefs.remove(AppConstants.userAddress);
    return true;
  }

  // ─── Saved credentials (Remember me) ─────────────────────────────

  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  ) async {
    await _prefs.setString(AppConstants.userPassword, password);
    await _prefs.setString(AppConstants.userNumber, number);
    await _prefs.setString(AppConstants.userCountryCode, countryCode);
  }

  String getUserNumber() => _prefs.getString(AppConstants.userNumber) ?? '';
  String getUserCountryCode() =>
      _prefs.getString(AppConstants.userCountryCode) ?? '';
  String getUserPassword() =>
      _prefs.getString(AppConstants.userPassword) ?? '';

  Future<bool> clearUserNumberAndPassword() async {
    await _prefs.remove(AppConstants.userPassword);
    await _prefs.remove(AppConstants.userCountryCode);
    return _prefs.remove(AppConstants.userNumber);
  }

  // ─── Guest contact ────────────────────────────────────────────────

  Future<bool> saveGuestContactNumber(String number) async {
    return _prefs.setString(AppConstants.guestNumber, number);
  }

  String getGuestContactNumber() =>
      _prefs.getString(AppConstants.guestNumber) ?? '';

  // ─── Notification preference ──────────────────────────────────────

  bool isNotificationActive() =>
      _prefs.getBool(AppConstants.notification) ?? true;

  void setNotificationActive(bool isActive) {
    _prefs.setBool(AppConstants.notification, isActive);
  }

  // ─── FCM device token ─────────────────────────────────────────────

  Future<String?> getDeviceToken() async {
    String? deviceToken = '@';
    if (!GetPlatform.isWeb) {
      try {
        deviceToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {}
    }
    if (deviceToken != null && kDebugMode) {
      print('--------Device Token---------- $deviceToken');
    }
    return deviceToken;
  }

  // ─── FCM notification setup ───────────────────────────────────────

  Future<void> setupNotifications() async {
    if (GetPlatform.isIOS && !GetPlatform.isWeb) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    if (!GetPlatform.isWeb) {
      FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
    }
  }

  void unsubscribeNotifications() {
    if (!GetPlatform.isWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      if (isLoggedIn()) {
        final address = AddressHelper.getUserAddressFromSharedPref();
        if (address != null) {
          FirebaseMessaging.instance.unsubscribeFromTopic(
            'zone_${address.zoneId}_customer',
          );
        }
      }
    }
  }
}
