import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_loader.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:ecommerce/features/auth/presentation/pages/sign_up_page.dart';
import 'package:ecommerce/features/deliveryman_registration/widgets/condition_check_box_widget.dart';
import 'package:ecommerce/features/auth/widgets/guest_button_widget.dart';
import 'package:ecommerce/features/auth/widgets/social_login_widget.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/location/controllers/location_controller.dart';
import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';
import 'package:ecommerce/features/location/screens/pick_map_screen.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/custom_validator.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SignInPage extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;

  const SignInPage({
    super.key,
    required this.exitFromApp,
    required this.backFromThis,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _countryDialCode;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();

    final fromSignUp = Get.parameters['page'] == RouteHelper.signUp;
    const route = null;

    // TODO: Migrate LocationController to BLoC eventually
    Get.find<LocationController>().checkPermission(() async {
      Get.dialog(const CustomLoader(), barrierDismissible: false);
      AddressModel address = await Get.find<LocationController>()
          .getCurrentLocation(true);
      ZoneResponseModel response = await Get.find<LocationController>().getZone(
        address.latitude,
        address.longitude,
        false,
      );

      if (response.isSuccess) {
        Get.find<LocationController>().saveAddressAndNavigate(
          address,
          fromSignUp,
          route,
          route != null,
          ResponsiveHelper.isDesktop(Get.context),
        );
      } else {
        Get.back();
        if (ResponsiveHelper.isDesktop(Get.context)) {
          showGeneralDialog(
            context: Get.context!,
            pageBuilder: (context, anim1, anim2) {
              return const SizedBox(
                height: 300,
                width: 300,
                child: PickMapScreen(
                  fromSignUp: false,
                  canRoute: true,
                  fromAddAddress: false,
                  route: route ?? RouteHelper.accessLocation,
                ),
              );
            },
          );
        } else {
          Get.toNamed(
            RouteHelper.getPickMapRoute(
              route ?? RouteHelper.accessLocation,
              route != null,
            ),
          );
          showCustomSnackBar('service_not_available_in_current_location'.tr);
        }
      }
    });

    final authBloc = context.read<AuthBloc>();
    _countryDialCode = authBloc.savedCountryCode.isNotEmpty
        ? authBloc.savedCountryCode
        : null;
    _phoneController.text = authBloc.savedNumber;
    _passwordController.text = authBloc.savedPassword;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (value, result) async {
        if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'back_press_again_to_exit'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ),
            );
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context)
            ? Colors.transparent
            : Theme.of(context).cardColor,
        appBar: (ResponsiveHelper.isDesktop(context)
            ? null
            : !widget.exitFromApp
            ? AppBar(
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                actions: const [SizedBox()],
              )
            : null),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: SafeArea(
          child: Center(
            child: Container(
              height: ResponsiveHelper.isDesktop(context) ? 690 : null,
              width: context.width > 700 ? 500 : context.width,
              padding: context.width > 700
                  ? const EdgeInsets.symmetric(horizontal: 0)
                  : const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge),
              decoration: context.width > 700
                  ? BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                      boxShadow: ResponsiveHelper.isDesktop(context)
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                    )
                  : null,
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is AuthError) {
                    showCustomSnackBar(state.message);
                  } else if (state is AuthSocialNeedsVerification) {
                    // Navigate to verification with data
                    Get.toNamed(
                      RouteHelper.getVerificationRoute(
                        state.phone,
                        state.token,
                        RouteHelper.signUp,
                        '', // no password data for social
                      ),
                    );
                  } else if (state is AuthSuccess) {
                    // Update global state & navigate
                    getIt<CartBloc>().add(GetCartDataEvent());

                    final authBloc = context.read<AuthBloc>();
                    final currentState = authBloc.state;
                    final isRememberMeActive = currentState is AuthInitial
                        ? currentState.isRememberMeActive
                        : false;

                    if (isRememberMeActive) {
                      authBloc.saveCredentials(
                        number: _phoneController.text.trim(),
                        password: _passwordController.text.trim(),
                        countryCode: _countryDialCode ?? '',
                      );
                    } else {
                      authBloc.clearCredentials();
                    }

                    // Save token explicitly as we're not inside the repo for login
                    context.read<AuthBloc>().add(
                      TokenPersistenceRequested(token: state.response.token),
                    );

                    if (Get.find<SplashController>()
                            .configModel!
                            .customerVerification! &&
                        !state.response.isPhoneVerified) {
                      List<int> encoded = utf8.encode(
                        _passwordController.text.trim(),
                      );
                      String data = base64Encode(encoded);
                      Get.toNamed(
                        RouteHelper.getVerificationRoute(
                          (_countryDialCode ?? '') +
                              _phoneController.text.trim(),
                          state.response.token,
                          RouteHelper.signUp,
                          data,
                        ),
                      );
                    } else {
                      if (widget.backFromThis) {
                        if (ResponsiveHelper.isDesktop(context)) {
                          Get.offAllNamed(
                            RouteHelper.getInitialRoute(fromSplash: false),
                          );
                        } else {
                          Get.back();
                        }
                      } else {
                        final fromSignUp =
                            Get.parameters['page'] == RouteHelper.signUp;
                        const route = null;

                        Get.find<LocationController>().checkPermission(
                          () async {
                            Get.dialog(
                              const CustomLoader(),
                              barrierDismissible: false,
                            );
                            AddressModel address =
                                await Get.find<LocationController>()
                                    .getCurrentLocation(true);
                            ZoneResponseModel response =
                                await Get.find<LocationController>().getZone(
                                  address.latitude,
                                  address.longitude,
                                  false,
                                );

                            if (response.isSuccess) {
                              Get.find<LocationController>()
                                  .saveAddressAndNavigate(
                                    address,
                                    fromSignUp,
                                    route,
                                    route != null,
                                    ResponsiveHelper.isDesktop(Get.context),
                                  );
                            } else {
                              Get.back();
                              if (ResponsiveHelper.isDesktop(Get.context)) {
                                showGeneralDialog(
                                  context: Get.context!,
                                  pageBuilder: (context, anim1, anim2) {
                                    return const SizedBox(
                                      height: 300,
                                      width: 300,
                                      child: PickMapScreen(
                                        fromSignUp: false,
                                        canRoute: true,
                                        fromAddAddress: false,
                                        route:
                                            route ?? RouteHelper.accessLocation,
                                      ),
                                    );
                                  },
                                );
                              } else {
                                Get.toNamed(
                                  RouteHelper.getPickMapRoute(
                                    route ?? RouteHelper.accessLocation,
                                    route != null,
                                  ),
                                );
                                showCustomSnackBar(
                                  'service_not_available_in_current_location'
                                      .tr,
                                );
                              }
                            }
                          },
                        );
                      }
                    }
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  final isRememberMeActive = state is AuthInitial
                      ? state.isRememberMeActive
                      : false;

                  return Center(
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          ResponsiveHelper.isDesktop(context)
                              ? Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => Get.back(),
                                      icon: const Icon(Icons.clear),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          Padding(
                            padding: ResponsiveHelper.isDesktop(context)
                                ? const EdgeInsets.all(40)
                                : EdgeInsets.zero,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(Images.logo, width: 125),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge,
                                ),
                                Align(
                                  alignment:
                                      Get.find<LocalizationController>().isLtr
                                      ? Alignment.topLeft
                                      : Alignment.topRight,
                                  child: Text(
                                    'sign_in'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),
                                CustomTextField(
                                  titleText: ResponsiveHelper.isDesktop(context)
                                      ? 'phone'.tr
                                      : 'enter_phone_number'.tr,
                                  hintText: '',
                                  controller: _phoneController,
                                  focusNode: _phoneFocus,
                                  nextFocus: _passwordFocus,
                                  inputType: TextInputType.phone,
                                  isPhone: true,
                                  showTitle: ResponsiveHelper.isDesktop(
                                    context,
                                  ),
                                  onCountryChanged: (CountryCode countryCode) {
                                    _countryDialCode = countryCode.dialCode;
                                  },
                                  countryDialCode:
                                      _countryDialCode ??
                                      Get.find<LocalizationController>()
                                          .locale
                                          .countryCode,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge,
                                ),
                                CustomTextField(
                                  titleText: ResponsiveHelper.isDesktop(context)
                                      ? 'password'.tr
                                      : 'enter_your_password'.tr,
                                  hintText: 'enter_your_password'.tr,
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  inputAction: TextInputAction.done,
                                  inputType: TextInputType.visiblePassword,
                                  prefixIcon: Icons.lock,
                                  isPassword: true,
                                  showTitle: ResponsiveHelper.isDesktop(
                                    context,
                                  ),
                                  onSubmit: (text) => (GetPlatform.isWeb)
                                      ? _login(context, _countryDialCode!)
                                      : null,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        onTap: () => context
                                            .read<AuthBloc>()
                                            .add(const RememberMeToggled()),
                                        leading: Checkbox(
                                          visualDensity: const VisualDensity(
                                            horizontal: -4,
                                            vertical: -4,
                                          ),
                                          activeColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                          value: isRememberMeActive,
                                          onChanged: (bool? isChecked) =>
                                              context.read<AuthBloc>().add(
                                                const RememberMeToggled(),
                                              ),
                                        ),
                                        title: Text('remember_me'.tr),
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity: const VisualDensity(
                                          horizontal: 0,
                                          vertical: -4,
                                        ),
                                        dense: true,
                                        horizontalTitleGap: 0,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.toNamed(
                                        RouteHelper.getForgotPassRoute(
                                          false,
                                          null,
                                        ),
                                      ),
                                      child: Text(
                                        '${'forgot_password'.tr}?',
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                                const Align(
                                  alignment: Alignment.center,
                                  child: ConditionCheckBoxWidget(
                                    forDeliveryMan: false,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),
                                CustomButton(
                                  height: ResponsiveHelper.isDesktop(context)
                                      ? 45
                                      : null,
                                  width: ResponsiveHelper.isDesktop(context)
                                      ? 180
                                      : null,
                                  buttonText:
                                      ResponsiveHelper.isDesktop(context)
                                      ? 'login'.tr
                                      : 'sign_in'.tr,
                                  onPressed: () =>
                                      _login(context, _countryDialCode!),
                                  isLoading: isLoading,
                                  radius: ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.radiusSmall
                                      : Dimensions.radiusDefault,
                                  isBold: !ResponsiveHelper.isDesktop(context),
                                  fontSize: ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.fontSizeExtraSmall
                                      : null,
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge,
                                ),
                                ResponsiveHelper.isDesktop(context)
                                    ? const SizedBox()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'do_not_have_account'.tr,
                                            style: robotoRegular.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (ResponsiveHelper.isDesktop(
                                                context,
                                              )) {
                                                Get.back();
                                                Get.dialog(const SignUpPage());
                                              } else {
                                                Get.toNamed(
                                                  RouteHelper.getSignUpRoute(),
                                                );
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              child: Text(
                                                'sign_up'.tr,
                                                style: robotoMedium.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeSmall,
                                ),
                                const SocialLoginWidget(),
                                ResponsiveHelper.isDesktop(context)
                                    ? const SizedBox()
                                    : const GuestButtonWidget(),
                                ResponsiveHelper.isDesktop(context)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'do_not_have_account'.tr,
                                            style: robotoRegular.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (ResponsiveHelper.isDesktop(
                                                context,
                                              )) {
                                                Get.back();
                                                Get.dialog(const SignUpPage());
                                              } else {
                                                Get.toNamed(
                                                  RouteHelper.getSignUpRoute(),
                                                );
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                              child: Text(
                                                'sign_up'.tr,
                                                style: robotoMedium.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context, String countryDialCode) async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String numberWithCountryCode = countryDialCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(
      numberWithCountryCode,
    );
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    } else {
      if (!context.mounted) return;
      context.read<AuthBloc>().add(
        LoginRequested(phone: numberWithCountryCode, password: password),
      );
    }
  }
}
