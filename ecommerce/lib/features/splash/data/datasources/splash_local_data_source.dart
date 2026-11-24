import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Local (SharedPreferences + ApiClient header) data source for the splash
/// feature. All reads are synchronous; writes are async.
abstract class SplashLocalDataSource {
  Future<ModuleModel?> initSharedData();
  void disableIntro();
  bool? showIntro();
  Future<void> setModule(ModuleModel? module);
  Future<void> setCacheModule(ModuleModel? module);
  ModuleModel? getCacheModule();
  ModuleModel? getModule();
  bool getSavedCookiesData();
  Future<void> saveCookiesData(bool data);
  void cookiesStatusChange(String? data);
  bool getAcceptCookiesStatus(String data);
  bool getSuggestedLocationStatus();
  Future<void> saveSuggestedLocationStatus(bool data);
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  SplashLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.apiClient,
  });

  @override
  Future<ModuleModel?> initSharedData() async {
    if (!sharedPreferences.containsKey(AppConstants.theme)) {
      sharedPreferences.setBool(AppConstants.theme, false);
    }
    if (!sharedPreferences.containsKey(AppConstants.countryCode)) {
      sharedPreferences.setString(
        AppConstants.countryCode,
        AppConstants.languages[0].countryCode!,
      );
    }
    if (!sharedPreferences.containsKey(AppConstants.languageCode)) {
      sharedPreferences.setString(
        AppConstants.languageCode,
        AppConstants.languages[0].languageCode!,
      );
    }
    if (!sharedPreferences.containsKey(AppConstants.cartList)) {
      sharedPreferences.setStringList(AppConstants.cartList, []);
    }
    if (!sharedPreferences.containsKey(AppConstants.searchHistory)) {
      sharedPreferences.setStringList(AppConstants.searchHistory, []);
    }
    if (!sharedPreferences.containsKey(AppConstants.notification)) {
      sharedPreferences.setBool(AppConstants.notification, true);
    }
    if (!sharedPreferences.containsKey(AppConstants.intro)) {
      sharedPreferences.setBool(AppConstants.intro, true);
    }
    if (!sharedPreferences.containsKey(AppConstants.notificationCount)) {
      sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    if (!sharedPreferences.containsKey(AppConstants.suggestedLocation)) {
      sharedPreferences.setBool(AppConstants.suggestedLocation, false);
    }

    ModuleModel? module;
    if (sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        module = ModuleModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!),
        );
      } catch (e) {
        debugPrint('Did not get shared Preferences module. Note: $e');
      }
    }
    return module;
  }

  @override
  void disableIntro() {
    sharedPreferences.setBool(AppConstants.intro, false);
  }

  @override
  bool? showIntro() {
    return sharedPreferences.getBool(AppConstants.intro);
  }

  @override
  Future<void> setModule(ModuleModel? module) async {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(
        jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!),
      );
    } catch (e) {
      debugPrint('Did not get shared Preferences address. Note: $e');
    }
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token),
      addressModel?.zoneIds,
      addressModel?.areaIds,
      sharedPreferences.getString(AppConstants.languageCode),
      module?.id,
      addressModel?.latitude,
      addressModel?.longitude,
    );
    if (module != null) {
      await sharedPreferences.setString(
        AppConstants.moduleId,
        jsonEncode(module.toJson()),
      );
    } else {
      await sharedPreferences.remove(AppConstants.moduleId);
    }
  }

  @override
  Future<void> setCacheModule(ModuleModel? module) async {
    if (module != null) {
      await sharedPreferences.setString(
        AppConstants.cacheModuleId,
        jsonEncode(module.toJson()),
      );
    } else {
      await sharedPreferences.remove(AppConstants.cacheModuleId);
    }
  }

  @override
  ModuleModel? getCacheModule() {
    ModuleModel? module;
    if (sharedPreferences.containsKey(AppConstants.cacheModuleId)) {
      try {
        module = ModuleModel.fromJson(
          jsonDecode(
            sharedPreferences.getString(AppConstants.cacheModuleId)!,
          ),
        );
      } catch (e) {
        debugPrint('Did not get shared Preferences cache module. Note: $e');
      }
    }
    return module;
  }

  @override
  ModuleModel? getModule() {
    ModuleModel? module;
    if (sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        module = ModuleModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!),
        );
      } catch (e) {
        debugPrint('Did not get shared Preferences module. Note: $e');
      }
    }
    return module;
  }

  @override
  bool getSavedCookiesData() {
    return sharedPreferences.getBool(AppConstants.acceptCookies) ?? false;
  }

  @override
  Future<void> saveCookiesData(bool data) async {
    await sharedPreferences.setBool(AppConstants.acceptCookies, data);
  }

  @override
  void cookiesStatusChange(String? data) {
    if (data != null) {
      sharedPreferences.setString(AppConstants.cookiesManagement, data);
    }
  }

  @override
  bool getAcceptCookiesStatus(String data) {
    return sharedPreferences.getString(AppConstants.cookiesManagement) !=
            null &&
        sharedPreferences.getString(AppConstants.cookiesManagement) == data;
  }

  @override
  bool getSuggestedLocationStatus() {
    return sharedPreferences.getBool(AppConstants.suggestedLocation) ?? false;
  }

  @override
  Future<void> saveSuggestedLocationStatus(bool data) async {
    await sharedPreferences.setBool(AppConstants.suggestedLocation, data);
  }
}
