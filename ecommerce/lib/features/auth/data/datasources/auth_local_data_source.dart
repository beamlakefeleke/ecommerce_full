import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Local auth session state (SharedPreferences) plus ApiClient header/token
/// management. Pure infra; no business decisions.
abstract class AuthLocalDataSource {
  Future<bool> saveUserToken(String token);
  bool isLoggedIn();
  bool isGuestLoggedIn();
  Future<bool> saveGuestId(String id);
  String getGuestId();
  Future<bool> clearGuestId();
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

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.apiClient,
  });

  @override
  Future<bool> saveUserToken(String token) async {
    apiClient.token = token;
    final stored = sharedPreferences.getString(AppConstants.userAddress);
    if (stored != null) {
      final AddressModel address = AddressModel.fromJson(jsonDecode(stored));
      apiClient.updateHeader(
        token,
        address.zoneIds,
        address.areaIds,
        sharedPreferences.getString(AppConstants.languageCode),
        ModuleHelper.getModule()?.id,
        address.latitude,
        address.longitude,
      );
    } else {
      apiClient.updateHeader(
        token,
        null,
        null,
        sharedPreferences.getString(AppConstants.languageCode),
        ModuleHelper.getModule()?.id,
        null,
        null,
      );
    }
    return sharedPreferences.setString(AppConstants.token, token);
  }

  @override
  bool isLoggedIn() => sharedPreferences.containsKey(AppConstants.token);

  @override
  bool isGuestLoggedIn() => sharedPreferences.containsKey(AppConstants.guestId);

  @override
  Future<bool> saveGuestId(String id) =>
      sharedPreferences.setString(AppConstants.guestId, id);

  @override
  String getGuestId() =>
      sharedPreferences.getString(AppConstants.guestId) ?? '';

  @override
  Future<bool> clearGuestId() => sharedPreferences.remove(AppConstants.guestId);

  @override
  bool clearSharedData() {
    if (!GetPlatform.isWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      apiClient.postData(AppConstants.tokenUri, {
        "_method": "put",
        "cm_firebase_token": '@',
      }, handleError: false);
    }
    sharedPreferences.remove(AppConstants.token);
    sharedPreferences.remove(AppConstants.guestId);
    sharedPreferences.setStringList(AppConstants.cartList, []);
    sharedPreferences.remove(AppConstants.userAddress);
    apiClient.token = null;
    apiClient.updateHeader(null, null, null, null, null, null, null);
    return true;
  }

  @override
  Future<bool> clearSharedAddress() async {
    await sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }

  @override
  bool isNotificationActive() =>
      sharedPreferences.getBool(AppConstants.notification) ?? true;

  @override
  void setNotificationActive(bool isActive) {
    sharedPreferences.setBool(AppConstants.notification, isActive);
    if (!isActive && !GetPlatform.isWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      if (isLoggedIn()) {
        FirebaseMessaging.instance.unsubscribeFromTopic(
          'zone_${AddressHelper.getUserAddressFromSharedPref()!.zoneId}_customer',
        );
      }
    }
  }

  @override
  Future<void> saveUserNumberAndPassword(
    String number,
    String password,
    String countryCode,
  ) async {
    await sharedPreferences.setString(AppConstants.userPassword, password);
    await sharedPreferences.setString(AppConstants.userNumber, number);
    await sharedPreferences.setString(
      AppConstants.userCountryCode,
      countryCode,
    );
  }

  @override
  String getUserNumber() =>
      sharedPreferences.getString(AppConstants.userNumber) ?? '';

  @override
  String getUserCountryCode() =>
      sharedPreferences.getString(AppConstants.userCountryCode) ?? '';

  @override
  String getUserPassword() =>
      sharedPreferences.getString(AppConstants.userPassword) ?? '';

  @override
  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.userPassword);
    await sharedPreferences.remove(AppConstants.userCountryCode);
    return sharedPreferences.remove(AppConstants.userNumber);
  }

  @override
  String getUserToken() =>
      sharedPreferences.getString(AppConstants.token) ?? '';

  @override
  Future<bool> saveGuestContactNumber(String number) =>
      sharedPreferences.setString(AppConstants.guestNumber, number);

  @override
  String getGuestContactNumber() =>
      sharedPreferences.getString(AppConstants.guestNumber) ?? '';

  @override
  Future<bool> saveDmTipIndex(String index) =>
      sharedPreferences.setString(AppConstants.dmTipIndex, index);

  @override
  String getDmTipIndex() =>
      sharedPreferences.getString(AppConstants.dmTipIndex) ?? '';

  @override
  Future<bool> saveEarningPoint(String point) =>
      sharedPreferences.setString(AppConstants.earnPoint, point);

  @override
  String getEarningPoint() =>
      sharedPreferences.getString(AppConstants.earnPoint) ?? '';
}
