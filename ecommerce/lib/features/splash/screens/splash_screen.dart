import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';

import 'package:ecommerce/features/location/controllers/location_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_state.dart';
import 'package:ecommerce/features/notification/domain/models/notification_body_model.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/common/widgets/no_internet_screen.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  late StreamSubscription<List<ConnectivityResult>> _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (!firstTime) {
        bool isNotConnected =
            results.isEmpty ||
            results.every(
              (r) =>
                  r != ConnectivityResult.wifi &&
                  r != ConnectivityResult.mobile,
            );
        isNotConnected
            ? const SizedBox()
            : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isNotConnected ? Colors.red : Colors.green,
            duration: Duration(seconds: isNotConnected ? 6000 : 3),
            content: Text(
              isNotConnected ? 'no_connection'.tr : 'connected'.tr,
              textAlign: TextAlign.center,
            ),
          ),
        );
        if (!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    if ((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) &&
        Get.find<SplashController>().cacheModule != null) {
      getIt<CartBloc>().add(GetCartDataEvent());
    }
    _route();
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if (isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = 0;
          if (GetPlatform.isAndroid) {
            minimumVersion = Get.find<SplashController>()
                .configModel!
                .appMinimumVersionAndroid;
          } else if (GetPlatform.isIOS) {
            minimumVersion =
                Get.find<SplashController>().configModel!.appMinimumVersionIos;
          }
          if (AppConstants.appVersion < minimumVersion! ||
              Get.find<SplashController>().configModel!.maintenanceMode!) {
            Get.offNamed(
              RouteHelper.getUpdateRoute(
                AppConstants.appVersion < minimumVersion,
              ),
            );
          } else {
            if (widget.body != null) {
              if (widget.body!.notificationType == NotificationType.order) {
                Get.offNamed(
                  RouteHelper.getOrderDetailsRoute(
                    widget.body!.orderId,
                    fromNotification: true,
                  ),
                );
              } else if (widget.body!.notificationType ==
                  NotificationType.general) {
                Get.offNamed(
                  RouteHelper.getNotificationRoute(fromNotification: true),
                );
              } else {
                Get.offNamed(
                  RouteHelper.getChatRoute(
                    notificationBody: widget.body,
                    conversationID: widget.body!.conversationId,
                    fromNotification: true,
                  ),
                );
              }
            } else {
              if (AuthHelper.isLoggedIn()) {
                Get.find<AuthController>().updateToken();
                if (AddressHelper.getUserAddressFromSharedPref() != null) {
                  if (Get.find<SplashController>().module != null) {
                    getIt<FavouriteBloc>().add(const FavouriteListFetched());
                  }
                  Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
                } else {
                  Get.find<LocationController>().navigateToLocationScreen(
                    'splash',
                    offNamed: true,
                  );
                }
              } else {
                if (Get.find<SplashController>().showIntro()!) {
                  if (AppConstants.languages.length > 1) {
                    Get.offNamed(RouteHelper.getLanguageRoute('splash'));
                  } else {
                    Get.offNamed(RouteHelper.getOnBoardingRoute());
                  }
                } else {
                  if (AuthHelper.isGuestLoggedIn()) {
                    if (AddressHelper.getUserAddressFromSharedPref() != null) {
                      Get.offNamed(
                        RouteHelper.getInitialRoute(fromSplash: true),
                      );
                    } else {
                      Get.find<LocationController>().navigateToLocationScreen(
                        'splash',
                        offNamed: true,
                      );
                    }
                  } else {
                    Get.offNamed(
                      RouteHelper.getSignInRoute(RouteHelper.splash),
                    );
                  }
                }
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>().initSharedData();
    if (AddressHelper.getUserAddressFromSharedPref() != null &&
        AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(
        builder: (splashController) {
          return Center(
            child: splashController.hasConnection
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(Images.logo, width: 200),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      // Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: 25)),
                    ],
                  )
                : NoInternetScreen(child: SplashScreen(body: widget.body)),
          );
        },
      ),
    );
  }
}
