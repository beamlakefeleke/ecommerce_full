import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Local storage access for the language feature (shared prefs + the shared
/// `ApiClient` header). Throws [CacheException]; the repository converts it to
/// a [Failure].
abstract class LanguageLocalDataSource {
  Locale getSavedLocale();
  void saveLanguage(Locale locale);
  void updateHeader(Locale locale, int? moduleId);
}

class LanguageLocalDataSourceImpl implements LanguageLocalDataSource {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  LanguageLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.apiClient,
  });

  @override
  Locale getSavedLocale() {
    try {
      return Locale(
        sharedPreferences.getString(AppConstants.languageCode) ??
            AppConstants.languages[0].languageCode!,
        sharedPreferences.getString(AppConstants.countryCode) ??
            AppConstants.languages[0].countryCode,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  void saveLanguage(Locale locale) {
    try {
      sharedPreferences.setString(
        AppConstants.languageCode,
        locale.languageCode,
      );
      sharedPreferences.setString(
        AppConstants.countryCode,
        locale.countryCode!,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  void updateHeader(Locale locale, int? moduleId) {
    try {
      final AddressModel? addressModel = _getAddressFromSharedPref();
      apiClient.updateHeader(
        sharedPreferences.getString(AppConstants.token),
        addressModel?.zoneIds,
        addressModel?.areaIds,
        locale.languageCode,
        moduleId,
        addressModel?.latitude,
        addressModel?.longitude,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  AddressModel? _getAddressFromSharedPref() {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
        jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!),
      );
    } catch (e) {
      debugPrint('Did not get shared Preferences address: $e');
    }
    return addressModel;
  }
}
