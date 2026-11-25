import 'dart:convert';
import 'package:ecommerce/features/taxi_booking/controllers/booking_checkout_controller.dart';
import 'package:ecommerce/features/taxi_booking/controllers/car_selection_controller.dart';
import 'package:ecommerce/features/taxi_booking/controllers/rider_controller.dart';
import 'package:ecommerce/common/controllers/theme_controller.dart';
import 'package:ecommerce/features/taxi_booking/repo/car_selection_repo.dart';
import 'package:ecommerce/features/taxi_booking/repo/rider_repo.dart';
import 'package:ecommerce/api/api_client.dart';

import 'package:ecommerce/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:ecommerce/features/auth/controllers/store_registration_controller.dart';
import 'package:ecommerce/features/auth/domain/reposotories/auth_repository.dart';
import 'package:ecommerce/features/auth/domain/reposotories/auth_repository_interface.dart';
import 'package:ecommerce/features/auth/domain/reposotories/deliveryman_registration_repository.dart';
import 'package:ecommerce/features/auth/domain/reposotories/deliveryman_registration_repository_interface.dart';
import 'package:ecommerce/features/auth/domain/reposotories/store_registration_repository.dart';
import 'package:ecommerce/features/auth/domain/reposotories/store_registration_repository_interface.dart';
import 'package:ecommerce/features/auth/domain/services/deliveryman_registration_service.dart';
import 'package:ecommerce/features/auth/domain/services/deliveryman_registration_service_interface.dart';
import 'package:ecommerce/features/auth/domain/services/store_registration_service.dart';
import 'package:ecommerce/features/auth/domain/services/store_registration_service_interface.dart';
// Store feature migrated to Clean Architecture + BLoC in lib/core/di/injection.dart
// Wallet feature migrated to Clean Architecture + BLoC in lib/core/di/injection.dart
// Verification feature migrated to Clean Architecture + BLoC in lib/core/di/injection.dart
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/features/language/data/models/language_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

Future<Map<String, Map<String, String>>> init() async {
  /// Core
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(
    () => ApiClient(
      appBaseUrl: AppConstants.baseUrl,
      sharedPreferences: Get.find(),
    ),
  );

  /// Repository
  Get.lazyPut(
    () => RiderRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
  );
  Get.lazyPut(() => CarSelectionRepo(apiClient: Get.find()));

  /// Repository interface
  AuthRepositoryInterface authRepositoryInterface = AuthRepository(
    apiClient: Get.find(),
    sharedPreferences: Get.find(),
  );
  Get.lazyPut(() => authRepositoryInterface);

  DeliverymanRegistrationRepositoryInterface
  deliverymanRegistrationRepositoryInterface =
      DeliverymanRegistrationRepository(apiClient: Get.find());
  Get.lazyPut(() => deliverymanRegistrationRepositoryInterface);

  StoreRegistrationRepositoryInterface storeRegistrationRepositoryInterface =
      StoreRegistrationRepository(apiClient: Get.find());
  Get.lazyPut(() => storeRegistrationRepositoryInterface);

  // StoreRepositoryInterface and StoreService moved to injection.dart (_registerStore)
  // StoreController moved to injection.dart (_registerStore) as StoreBloc

  // WalletRepository/Service moved to injection.dart (_registerWallet)

  // VerificationRepository/Service moved to injection.dart (_registerVerification)

  /// Service Interface
  DeliverymanRegistrationServiceInterface
  deliverymanRegistrationServiceInterface = DeliverymanRegistrationService(
    deliverymanRegistrationRepoInterface: Get.find(),
    authRepositoryInterface: Get.find(),
  );
  Get.lazyPut(() => deliverymanRegistrationServiceInterface);

  StoreRegistrationServiceInterface storeRegistrationServiceInterface =
      StoreRegistrationService(
        deliverymanRegistrationRepositoryInterface: Get.find(),
        storeRegistrationRepoInterface: Get.find(),
      );
  Get.lazyPut(() => storeRegistrationServiceInterface);

  // StoreServiceInterface moved to injection.dart (_registerStore)

  // WalletService moved to injection.dart (_registerWallet)

  // VerificationService moved to injection.dart (_registerVerification)

  /// Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(
    () => DeliverymanRegistrationController(
      deliverymanRegistrationServiceInterface: Get.find(),
    ),
  );
  Get.lazyPut(
    () => StoreRegistrationController(
      storeRegistrationServiceInterface: Get.find(),
    ),
  );
  // StoreController moved to StoreBloc in injection.dart
  // WalletController moved to WalletBloc in injection.dart
  Get.lazyPut(() => RiderController(riderRepo: Get.find()));
  Get.lazyPut(() => CarSelectionController(carSelectionRepo: Get.find()));
  Get.lazyPut(() => BookingCheckoutController(riderRepo: Get.find()));
  // VerificationController moved to VerificationBloc in injection.dart

  /// Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  for (LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues = await rootBundle.loadString(
      'assets/language/${languageModel.languageCode}.json',
    );
    Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);
    Map<String, String> json = {};
    mappedJson.forEach((key, value) {
      json[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
        json;
  }
  return languages;
}
