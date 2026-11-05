import 'dart:async';
import 'dart:io';
import 'package:ecommerce/features/notification/domain/models/notification_body_model.dart';
import 'package:ecommerce/helper/notification_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:meta_seo/meta_seo.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/common/controllers/theme_controller.dart';
import 'package:ecommerce/features/favourite/controllers/favourite_controller.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/theme/dark_theme.dart';
import 'package:ecommerce/theme/light_theme.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/home/widgets/cookies_view.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:ecommerce/core/di/injection.dart' as clean_di;
import 'package:ecommerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/coupon/presentation/bloc/coupon_bloc.dart';
import 'package:ecommerce/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  if (GetPlatform.isWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDFN-73p8zKVZbA0i5DtO215XzAb-xuGSE",
        authDomain: "ammart-8885e.firebaseapp.com",
        databaseURL: "https://ammart-8885e-default-rtdb.firebaseio.com",
        projectId: "ammart-8885e",
        storageBucket: "ammart-8885e.appspot.com",
        messagingSenderId: "1000163153346",
        appId: "1:1000163153346:web:4f702a4b5adbd5c906b25b",
        measurementId: "G-L1GNL2YV61",
      ),
    );

    MetaSEO().config();
  }
  await Firebase.initializeApp();
  Map<String, Map<String, String>> languages = await di.init();
  // Register the migrated (Clean Architecture + BLoC) features. Must run after
  // di.init() so the shared ApiClient is available in the GetX locator.
  clean_di.configureDependencies();

  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "380903914182154",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }
  runApp(MyApp(languages: languages, body: body));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    _route();
  }

  void _route() async {
    final authRepository = clean_di.getIt<AuthRepository>();
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if (AddressHelper.getUserAddressFromSharedPref() != null &&
          AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
        authRepository.clearSharedAddress();
      }

      if (!AuthHelper.isLoggedIn() &&
          !AuthHelper.isGuestLoggedIn() /*&& !ResponsiveHelper.isDesktop(Get.context!)*/ ) {
        await authRepository.guestLogin();
      }

      if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
          Get.find<SplashController>().cacheModule != null) {
        clean_di.getIt<CartBloc>().add(const CartDataOnlineRequested());
      }
    }
    Get.find<SplashController>()
        .getConfigData(loadLandingData: GetPlatform.isWeb)
        .then((bool isSuccess) async {
          if (isSuccess) {
            if (authRepository.isLoggedIn()) {
              authRepository.updateToken();
              if (Get.find<SplashController>().module != null) {
                await Get.find<FavouriteController>().getFavouriteList();
              }
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                return (GetPlatform.isWeb &&
                        splashController.configModel == null)
                    ? const SizedBox()
                    : MultiBlocProvider(
                        providers: [
                          BlocProvider<AddressBloc>(
                            create: (_) => clean_di.getIt<AddressBloc>(),
                          ),
                          BlocProvider<AuthBloc>(
                            create: (_) => clean_di.getIt<AuthBloc>(),
                          ),
                          BlocProvider<BannerBloc>(
                            create: (_) => clean_di.getIt<BannerBloc>(),
                          ),
                          BlocProvider<CartBloc>(
                            create: (_) => clean_di.getIt<CartBloc>(),
                          ),
                          BlocProvider<CategoryBloc>(
                            create: (_) => clean_di.getIt<CategoryBloc>(),
                          ),
                          BlocProvider<ChatBloc>(
                            create: (_) => clean_di.getIt<ChatBloc>(),
                          ),
                          BlocProvider<CheckoutBloc>(
                            create: (_) => clean_di.getIt<CheckoutBloc>(),
                          ),
                          BlocProvider<CouponBloc>(
                            create: (_) => clean_di.getIt<CouponBloc>(),
                          ),
                        ],
                        child: GetMaterialApp(
                          title: AppConstants.appName,
                          debugShowCheckedModeBanner: false,
                          navigatorKey: Get.key,
                          scrollBehavior: const MaterialScrollBehavior()
                              .copyWith(
                                dragDevices: {
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.touch,
                                },
                              ),
                          theme: themeController.darkTheme ? dark() : light(),
                          locale: localizeController.locale,
                          translations: Messages(languages: widget.languages),
                          fallbackLocale: Locale(
                            AppConstants.languages[0].languageCode!,
                            AppConstants.languages[0].countryCode,
                          ),
                          initialRoute: GetPlatform.isWeb
                              ? RouteHelper.getInitialRoute()
                              : RouteHelper.getSignInRoute(RouteHelper.splash),
                          getPages: RouteHelper.routes,
                          defaultTransition: Transition.topLevel,
                          transitionDuration: const Duration(milliseconds: 500),
                          builder: (BuildContext context, widget) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                textScaler: const TextScaler.linear(1),
                              ),
                              child: Material(
                                child: Stack(
                                  children: [
                                    widget!,
                                    GetBuilder<SplashController>(
                                      builder: (splashController) {
                                        if (!splashController
                                                .savedCookiesData &&
                                            !splashController
                                                .getAcceptCookiesStatus(
                                                  splashController
                                                              .configModel !=
                                                          null
                                                      ? splashController
                                                            .configModel!
                                                            .cookiesText!
                                                      : '',
                                                )) {
                                          return ResponsiveHelper.isWeb()
                                              ? const Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: CookiesView(),
                                                )
                                              : const SizedBox();
                                        } else {
                                          return const SizedBox();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
              },
            );
          },
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
