import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/location/presentation/helper/location_helper.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_event.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/notification/domain/models/notification_body_model.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/common/widgets/no_internet_screen.dart';
import 'package:flutter/material.dart';
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
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      if (!firstTime) {
        bool isNotConnected =
            result != ConnectivityResult.wifi &&
            result != ConnectivityResult.mobile;
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

    getIt<SplashBloc>().add(const SplashSharedDataInitialized());
    if ((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) &&
        getIt<SplashBloc>().state.cacheModule != null) {
      getIt<CartBloc>().add(const CartDataOnlineRequested());
    }
    _route();
  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged.cancel();
  }

  void _route() {
    getIt<SplashBloc>().add(const SplashConfigRequested());
    getIt<SplashBloc>().stream
        .firstWhere(
          (s) =>
              s.status == SplashConfigStatus.loaded ||
              s.status == SplashConfigStatus.error,
        )
        .then((splashState) {
          final isSuccess = splashState.status == SplashConfigStatus.loaded;
          if (isSuccess) {
            Timer(const Duration(seconds: 1), () async {
              double? minimumVersion = 0;
              if (GetPlatform.isAndroid) {
                minimumVersion = getIt<SplashBloc>()
                    .state
                    .configModel!
                    .appMinimumVersionAndroid;
              } else if (GetPlatform.isIOS) {
                minimumVersion =
                    getIt<SplashBloc>().state.configModel!.appMinimumVersionIos;
              }
              if (AppConstants.appVersion < minimumVersion! ||
                  getIt<SplashBloc>().state.configModel!.maintenanceMode!) {
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
                    getIt<AuthRepository>().updateToken();
                    if (AddressHelper.getUserAddressFromSharedPref() != null) {
                      if (getIt<SplashBloc>().state.module != null) {
                        getIt<FavouriteBloc>().add(
                          const FavouriteListRequested(),
                        );
                      }
                      Get.offNamed(
                        RouteHelper.getInitialRoute(fromSplash: true),
                      );
                    } else {
                      LocationHelper.navigateToLocationScreen(
                        'splash',
                        offNamed: true,
                      );
                    }
                  } else {
                    if (getIt<SplashBloc>().showIntro()!) {
                      if (AppConstants.languages.length > 1) {
                        Get.offNamed(RouteHelper.getLanguageRoute('splash'));
                      } else {
                        Get.offNamed(RouteHelper.getOnBoardingRoute());
                      }
                    } else {
                      if (AuthHelper.isGuestLoggedIn()) {
                        if (AddressHelper.getUserAddressFromSharedPref() !=
                            null) {
                          Get.offNamed(
                            RouteHelper.getInitialRoute(fromSplash: true),
                          );
                        } else {
                          LocationHelper.navigateToLocationScreen(
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
    // initSharedData is dispatched once in initState.
    if (AddressHelper.getUserAddressFromSharedPref() != null &&
        AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
      getIt<AuthRepository>().clearSharedData();
    }

    return Scaffold(
      key: _globalKey,
      body: BlocBuilder<SplashBloc, SplashState>(
        builder: (context, splashController) {
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
