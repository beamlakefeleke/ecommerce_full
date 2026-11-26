import 'dart:convert';
import 'package:ecommerce/features/splash/presentation/bloc/splash_event.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/common/widgets/confirmation_dialog.dart';
import 'package:ecommerce/common/widgets/custom_loader.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_event.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_state.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/home/screens/home_screen.dart';
import 'package:ecommerce/features/location/domain/entities/zone_response.dart';
import 'package:ecommerce/features/location/domain/repositories/location_repository.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_bloc.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_event.dart';
import 'package:ecommerce/features/location/presentation/pages/pick_map_screen.dart';
import 'package:ecommerce/features/location/presentation/widgets/module_dialog_widget.dart';
import 'package:ecommerce/features/location/presentation/widgets/permission_dialog_widget.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_bloc.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_state.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/images.dart';

/// Stateless orchestrator for the location feature's side-effects: navigation,
/// Firebase topic (un)subscription, cart reset, zone persistence and the
/// cross-feature calls the legacy `LocationController` / `LocationService` ran.
///
/// Blocs stay side-effect free; this helper runs the effects. Navigation keeps
/// using GetX (`Get.toNamed/offAllNamed/back/dialog`) per the project's
/// transitional routing rule until `go_router` lands. Data access goes through
/// the migrated `LocationRepository` (via `getIt`), not a GetX controller.
class LocationHelper {
  const LocationHelper._();

  static LocationRepository get _repo => getIt<LocationRepository>();

  static const ZoneResult _emptyZone = ZoneResult(
    isSuccess: false,
    message: null,
    zoneIds: [],
    zoneData: [],
    areaIds: [],
  );

  static Future<ZoneResult> _zone(
    String? lat,
    String? lng, {
    bool handleError = false,
  }) async {
    final either = await _repo.getZone(lat, lng, handleError: handleError);
    return either.fold((_) => _emptyZone, (z) => z);
  }

  // ── Permission ───────────────────────────────────────────────────────────

  static void checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    } else {
      onTap();
    }
  }

  static Future<bool> checkLocationActive() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    Position myPosition;
    try {
      myPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return false;
    }

    final saved = AddressHelper.getUserAddressFromSharedPref();
    if (saved?.latitude == null || saved?.longitude == null) return false;

    final double distance =
        Geolocator.distanceBetween(
          double.parse(saved!.latitude!),
          double.parse(saved.longitude!),
          myPosition.latitude,
          myPosition.longitude,
        ) /
        1000;
    return distance > 1;
  }

  // ── Save + navigate ──────────────────────────────────────────────────────

  static void saveAddressAndNavigate(
    AddressModel? address,
    bool fromSignUp,
    String? route,
    bool canRoute,
    bool isDesktop,
  ) {
    if (getIt<CartBloc>().state.cartList.isNotEmpty) {
      Get.dialog(
        ConfirmationDialog(
          icon: Images.warning,
          title: 'are_you_sure_to_reset'.tr,
          description: 'if_you_change_location'.tr,
          onYesPressed: () {
            Get.back();
            _prepareZoneData(address!, fromSignUp, route, canRoute, isDesktop);
          },
          onNoPressed: () {
            Get.back();
            Get.back();
          },
        ),
      );
    } else {
      _prepareZoneData(address!, fromSignUp, route, canRoute, isDesktop);
    }
  }

  static void _prepareZoneData(
    AddressModel address,
    bool fromSignUp,
    String? route,
    bool canRoute,
    bool isDesktop,
  ) async {
    final ZoneResult response = await _zone(
      address.latitude,
      address.longitude,
    );
    if (response.isSuccess) {
      getIt<CartBloc>().add(const CartCleared());
      address.zoneId = response.zoneIds[0];
      address.zoneIds = [...response.zoneIds];
      address.zoneData = [...response.zoneData];
      address.areaIds = [...response.areaIds];
      autoNavigate(address, fromSignUp, route, canRoute, isDesktop);
    } else {
      Get.back();
      showCustomSnackBar(response.message);
    }
  }

  static void autoNavigate(
    AddressModel? address,
    bool fromSignUp,
    String? route,
    bool canRoute,
    bool isDesktop,
  ) async {
    final splash = getIt<SplashBloc>().state;
    if (isDesktop && splash.configModel!.module == null) {
      final Map<String, String> header = _prepareHeader(address!.zoneIds);
      getIt<SplashBloc>().add(SplashModulesRequested(headers: header));
      if (Get.isDialogOpen!) {
        Get.back();
      }
      Get.dialog(
        ModuleDialogWidget(
          callback: () => _saveDataAndFirebaseConfig(
            address,
            fromSignUp,
            route,
            canRoute,
            isDesktop,
          ),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.7),
      );
    } else {
      _saveDataAndFirebaseConfig(
        address!,
        fromSignUp,
        route,
        canRoute,
        isDesktop,
      );
    }
  }

  static void _saveDataAndFirebaseConfig(
    AddressModel address,
    bool fromSignUp,
    String? route,
    bool canRoute,
    bool isDesktop,
  ) async {
    _configureFirebaseMessaging(address);
    await AddressHelper.saveUserAddressInSharedPref(address);
    final authRepo = getIt<AuthRepository>();
    if (authRepo.isLoggedIn()) {
      if (getIt<SplashBloc>().state.module != null) {
        getIt<FavouriteBloc>().add(const FavouriteListRequested());
      }
      await authRepo.updateZone();
    }
    HomeScreen.loadData(true);
    getIt<CheckoutBloc>().add(const CheckoutPrevDataCleared());
    _handleRoute(fromSignUp, route, canRoute);
  }

  static Future<void> navigateToLocationScreen(
    String page, {
    bool offNamed = false,
    bool offAll = false,
  }) async {
    final bool fromSignup = page == RouteHelper.signUp;
    final bool fromHome = page == 'home';

    if (!fromHome && AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      autoNavigate(
        AddressHelper.getUserAddressFromSharedPref(),
        fromSignup,
        null,
        false,
        ResponsiveHelper.isDesktop(Get.context),
      );
    } else if (getIt<AuthRepository>().isLoggedIn()) {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      final addressBloc = getIt<AddressBloc>();
      addressBloc.add(const AddressListRequested());
      await addressBloc.stream.firstWhere(
        (s) => s.status != AddressStatus.loading,
      );
      Get.back();
      _authorizeNavigation(
        page,
        addressBloc.state.addresses.isEmpty,
        offNamed: offNamed,
        offAll: offAll,
      );
    } else {
      _defaultNavigation(page);
    }
  }

  static Future<void> setStoreAddressToUserAddress(LatLng storeAddress) async {
    final geoEither = await _repo.getAddressFromGeocode(storeAddress);
    final String addressFromGeocode = geoEither.fold(
      (_) => 'Unknown Location Found',
      (a) => a,
    );

    final ZoneResult responseModel = await _zone(
      storeAddress.latitude.toString(),
      storeAddress.longitude.toString(),
    );

    final AddressModel addressModel = AddressModel(
      latitude: storeAddress.latitude.toString(),
      longitude: storeAddress.longitude.toString(),
      addressType: 'others',
      zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
      zoneIds: responseModel.zoneIds,
      address: addressFromGeocode,
      zoneData: responseModel.zoneData,
      areaIds: responseModel.areaIds,
    );
    await AddressHelper.saveUserAddressInSharedPref(addressModel);

    final splash = getIt<SplashBloc>().state;
    final Map<String, String> header = _prepareHeader(addressModel.zoneIds);
    getIt<SplashBloc>().add(SplashModulesRequested(headers: header));
    for (final ModuleModel m in splash.moduleList ?? const []) {
      if (m.id == getIt<StoreBloc>().state.store?.moduleId) {
        getIt<SplashBloc>().add(SplashModuleSet(m));
      }
    }
  }

  static Future<void> syncZoneData() async {
    final saved = AddressHelper.getUserAddressFromSharedPref();
    final ZoneResult response = await _zone(saved?.latitude, saved?.longitude);

    if (response.zoneIds.isEmpty) {
      await AddressHelper.saveUserAddressInSharedPref(AddressModel());
      Get.toNamed(RouteHelper.getAccessLocationRoute(RouteHelper.splash));
    } else {
      final AddressModel address =
          AddressHelper.getUserAddressFromSharedPref()!;
      address.zoneId = response.zoneIds[0];
      address.zoneIds = [...response.zoneIds];
      address.zoneData = [...response.zoneData];
      address.areaIds = [...response.areaIds];
      await AddressHelper.saveUserAddressInSharedPref(address);
    }
    // Keep any app-wide listeners of zone state fresh.
    getIt<LocationBloc>().add(
      ZoneRequested(
        lat: saved?.latitude,
        lng: saved?.longitude,
        markerLoad: false,
      ),
    );
  }

  // ── Firebase + headers + routing (ported from legacy LocationService) ─────

  static Map<String, String> _prepareHeader(List<int>? zoneIds) => {
    'Content-Type': 'application/json; charset=UTF-8',
    AppConstants.zoneId: zoneIds != null ? jsonEncode(zoneIds) : '',
  };

  static void _configureFirebaseMessaging(AddressModel address) {
    if (GetPlatform.isWeb) return;
    final saved = AddressHelper.getUserAddressFromSharedPref();
    if (saved != null) {
      if (saved.zoneIds != null) {
        for (final int zoneID in saved.zoneIds!) {
          FirebaseMessaging.instance.unsubscribeFromTopic(
            'zone_${zoneID}_customer',
          );
        }
      } else {
        FirebaseMessaging.instance.unsubscribeFromTopic(
          'zone_${saved.zoneId}_customer',
        );
      }
    } else {
      FirebaseMessaging.instance.subscribeToTopic(
        'zone_${address.zoneId}_customer',
      );
    }
    if (address.zoneIds != null) {
      for (final int zoneID in address.zoneIds!) {
        FirebaseMessaging.instance.subscribeToTopic('zone_${zoneID}_customer');
      }
    } else {
      FirebaseMessaging.instance.subscribeToTopic(
        'zone_${address.zoneId}_customer',
      );
    }
  }

  static void _handleRoute(bool fromSignUp, String? route, bool canRoute) {
    if (fromSignUp) {
      Get.offAllNamed(RouteHelper.getInterestRoute());
    } else if (route != null && canRoute) {
      Get.offAllNamed(route);
    } else {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
  }

  static void _authorizeNavigation(
    String page,
    bool addressListEmpty, {
    bool offNamed = false,
    bool offAll = false,
  }) {
    if (addressListEmpty) {
      if (ResponsiveHelper.isDesktop(Get.context)) {
        showGeneralDialog(
          context: Get.context!,
          pageBuilder: (_, _, _) => SizedBox(
            height: 300,
            width: 300,
            child: PickMapScreen(
              fromSignUp: page == RouteHelper.signUp,
              canRoute: false,
              fromAddAddress: false,
              route: null,
            ),
          ),
        );
      } else {
        Get.toNamed(RouteHelper.getPickMapRoute(page, false));
      }
    } else if (offNamed) {
      Get.offNamed(RouteHelper.getAccessLocationRoute(page));
    } else if (offAll) {
      Get.offAllNamed(RouteHelper.getAccessLocationRoute(page));
    } else {
      Get.toNamed(RouteHelper.getAccessLocationRoute(page));
    }
  }

  static void _defaultNavigation(String page) {
    if (ResponsiveHelper.isDesktop(Get.context)) {
      showGeneralDialog(
        context: Get.context!,
        pageBuilder: (_, _, _) => SizedBox(
          height: Get.context!.height * 0.75,
          width: 300,
          child: PickMapScreen(
            fromSignUp: page == RouteHelper.signUp,
            canRoute: false,
            fromAddAddress: false,
            route: null,
          ),
        ),
      );
    } else {
      Get.toNamed(RouteHelper.getPickMapRoute(page, false));
    }
  }
}
