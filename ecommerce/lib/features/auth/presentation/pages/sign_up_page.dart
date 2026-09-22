import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:ecommerce/features/auth/domain/entities/signup_body.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:ecommerce/features/auth/presentation/pages/sign_in_page.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/deliveryman_registration/widgets/condition_check_box_widget.dart';
import 'package:ecommerce/helper/custom_validator.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();
    _countryDialCode = CountryCode.fromCountryCode(
            Get.find<SplashController>().configModel!.country!)
        .dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context)
          ? Colors.transparent
          : Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Center(
          child: Container(
            width: context.width > 700 ? 700 : context.width,
            padding: context.width > 700
                ? const EdgeInsets.all(0)
                : const EdgeInsets.all(Dimensions.paddingSizeLarge),
            margin: context.width > 700
                ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                : null,
            decoration: context.width > 700
                ? BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  )
                : null,
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  showCustomSnackBar(state.message);
                } else if (state is AuthSuccess) {
                  String numberWithCountryCode =
                      (_countryDialCode ?? '') + _phoneController.text.trim();
                  
                  // Save token explicitly as we're not inside the repo for register
                  context.read<AuthBloc>().add(
                      TokenPersistenceRequested(token: state.response.token));

                  if (Get.find<SplashController>()
                          .configModel!
                          .customerVerification! &&
                      !state.response.isPhoneVerified) {
                    List<int> encoded =
                        utf8.encode(_passwordController.text.trim());
                    String data = base64Encode(encoded);

                    Get.toNamed(RouteHelper.getVerificationRoute(
                      numberWithCountryCode,
                      state.response.token,
                      RouteHelper.signUp,
                      data,
                    ));
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInPage(
                          exitFromApp: false,
                          backFromThis: false,
                        ),
                      ),
                    );
                  }
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                final acceptTerms = state is AuthInitial ? state.acceptTerms : true;

                return SingleChildScrollView(
                  child: Stack(
                    children: [
                      ResponsiveHelper.isDesktop(context)
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
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
                                  height: Dimensions.paddingSizeExtraLarge),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text('sign_up'.tr,
                                    style: robotoBold.copyWith(
                                        fontSize:
                                            Dimensions.fontSizeExtraLarge)),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeDefault),
                              Row(children: [
                                Expanded(
                                  child: CustomTextField(
                                    titleText: 'first_name'.tr,
                                    hintText: 'ex_jhon'.tr,
                                    controller: _firstNameController,
                                    focusNode: _firstNameFocus,
                                    nextFocus: _lastNameFocus,
                                    inputType: TextInputType.name,
                                    capitalization: TextCapitalization.words,
                                    prefixIcon: Icons.person,
                                    showTitle:
                                        ResponsiveHelper.isDesktop(context),
                                  ),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: CustomTextField(
                                    titleText: 'last_name'.tr,
                                    hintText: 'ex_doe'.tr,
                                    controller: _lastNameController,
                                    focusNode: _lastNameFocus,
                                    nextFocus:
                                        ResponsiveHelper.isDesktop(context)
                                            ? _emailFocus
                                            : _phoneFocus,
                                    inputType: TextInputType.name,
                                    capitalization: TextCapitalization.words,
                                    prefixIcon: Icons.person,
                                    showTitle:
                                        ResponsiveHelper.isDesktop(context),
                                  ),
                                )
                              ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),
                              Row(children: [
                                ResponsiveHelper.isDesktop(context)
                                    ? Expanded(
                                        child: CustomTextField(
                                          titleText: 'email'.tr,
                                          hintText: 'enter_email'.tr,
                                          controller: _emailController,
                                          focusNode: _emailFocus,
                                          nextFocus: ResponsiveHelper.isDesktop(
                                                  context)
                                              ? _phoneFocus
                                              : _passwordFocus,
                                          inputType: TextInputType.emailAddress,
                                          prefixImage: Images.mail,
                                          showTitle: ResponsiveHelper.isDesktop(
                                              context),
                                        ),
                                      )
                                    : const SizedBox(),
                                SizedBox(
                                    width: ResponsiveHelper.isDesktop(context)
                                        ? Dimensions.paddingSizeSmall
                                        : 0),
                                Expanded(
                                  child: CustomTextField(
                                    titleText:
                                        ResponsiveHelper.isDesktop(context)
                                            ? 'phone'.tr
                                            : 'enter_phone_number'.tr,
                                    controller: _phoneController,
                                    focusNode: _phoneFocus,
                                    nextFocus:
                                        ResponsiveHelper.isDesktop(context)
                                            ? _passwordFocus
                                            : _emailFocus,
                                    inputType: TextInputType.phone,
                                    isPhone: true,
                                    showTitle:
                                        ResponsiveHelper.isDesktop(context),
                                    onCountryChanged: (CountryCode countryCode) {
                                      _countryDialCode = countryCode.dialCode;
                                    },
                                    countryDialCode: _countryDialCode != null
                                        ? CountryCode.fromCountryCode(
                                                Get.find<SplashController>()
                                                    .configModel!
                                                    .country!)
                                            .code
                                        : Get.find<LocalizationController>()
                                            .locale
                                            .countryCode,
                                  ),
                                ),
                              ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),
                              !ResponsiveHelper.isDesktop(context)
                                  ? CustomTextField(
                                      titleText: 'email'.tr,
                                      hintText: 'enter_email'.tr,
                                      controller: _emailController,
                                      focusNode: _emailFocus,
                                      nextFocus: _passwordFocus,
                                      inputType: TextInputType.emailAddress,
                                      prefixIcon: Icons.mail,
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                  height: !ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeLarge
                                      : 0),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(children: [
                                        CustomTextField(
                                          titleText: 'password'.tr,
                                          hintText: '8_character'.tr,
                                          controller: _passwordController,
                                          focusNode: _passwordFocus,
                                          nextFocus: _confirmPasswordFocus,
                                          inputType:
                                              TextInputType.visiblePassword,
                                          prefixIcon: Icons.lock,
                                          isPassword: true,
                                          showTitle: ResponsiveHelper.isDesktop(
                                              context),
                                        ),
                                      ]),
                                    ),
                                    SizedBox(
                                        width:
                                            ResponsiveHelper.isDesktop(context)
                                                ? Dimensions.paddingSizeSmall
                                                : 0),
                                    ResponsiveHelper.isDesktop(context)
                                        ? Expanded(
                                            child: CustomTextField(
                                            titleText: 'confirm_password'.tr,
                                            hintText: '8_character'.tr,
                                            controller:
                                                _confirmPasswordController,
                                            focusNode: _confirmPasswordFocus,
                                            nextFocus:
                                                Get.find<SplashController>()
                                                            .configModel!
                                                            .refEarningStatus ==
                                                        1
                                                    ? _referCodeFocus
                                                    : null,
                                            inputAction:
                                                Get.find<SplashController>()
                                                            .configModel!
                                                            .refEarningStatus ==
                                                        1
                                                    ? TextInputAction.next
                                                    : TextInputAction.done,
                                            inputType:
                                                TextInputType.visiblePassword,
                                            prefixIcon: Icons.lock,
                                            isPassword: true,
                                            showTitle: ResponsiveHelper.isDesktop(
                                                context),
                                            onSubmit: (text) => (GetPlatform
                                                    .isWeb)
                                                ? _register(
                                                    context, _countryDialCode!)
                                                : null,
                                          ))
                                        : const SizedBox()
                                  ]),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),
                              !ResponsiveHelper.isDesktop(context)
                                  ? CustomTextField(
                                      titleText: 'confirm_password'.tr,
                                      hintText: '8_character'.tr,
                                      controller: _confirmPasswordController,
                                      focusNode: _confirmPasswordFocus,
                                      nextFocus: Get.find<SplashController>()
                                                  .configModel!
                                                  .refEarningStatus ==
                                              1
                                          ? _referCodeFocus
                                          : null,
                                      inputAction: Get.find<SplashController>()
                                                  .configModel!
                                                  .refEarningStatus ==
                                              1
                                          ? TextInputAction.next
                                          : TextInputAction.done,
                                      inputType: TextInputType.visiblePassword,
                                      prefixIcon: Icons.lock,
                                      isPassword: true,
                                      onSubmit: (text) => (GetPlatform.isWeb)
                                          ? _register(
                                              context, _countryDialCode!)
                                          : null,
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                  height: !ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeLarge
                                      : 0),
                              (Get.find<SplashController>()
                                          .configModel!
                                          .refEarningStatus ==
                                      1)
                                  ? CustomTextField(
                                      titleText: 'refer_code'.tr,
                                      hintText: 'enter_refer_code'.tr,
                                      controller: _referCodeController,
                                      focusNode: _referCodeFocus,
                                      inputAction: TextInputAction.done,
                                      inputType: TextInputType.text,
                                      capitalization: TextCapitalization.words,
                                      prefixImage: Images.referCode,
                                      prefixSize: 14,
                                      showTitle:
                                          ResponsiveHelper.isDesktop(context),
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),
                              const ConditionCheckBoxWidget(
                                  forDeliveryMan: true),
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),
                              CustomButton(
                                height: ResponsiveHelper.isDesktop(context)
                                    ? 45
                                    : null,
                                width: ResponsiveHelper.isDesktop(context)
                                    ? 180
                                    : null,
                                radius: ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.radiusSmall
                                    : Dimensions.radiusDefault,
                                isBold: !ResponsiveHelper.isDesktop(context),
                                fontSize: ResponsiveHelper.isDesktop(context)
                                    ? Dimensions.fontSizeExtraSmall
                                    : null,
                                buttonText: 'sign_up'.tr,
                                isLoading: isLoading,
                                onPressed: acceptTerms
                                    ? () async {
                                        _register(context, _countryDialCode!);
                                      }
                                    : null,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeExtraLarge),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('already_have_account'.tr,
                                        style: robotoRegular.copyWith(
                                            color: Theme.of(context).hintColor)),
                                    InkWell(
                                      onTap: () {
                                        if (ResponsiveHelper.isDesktop(
                                            context)) {
                                          Get.back();
                                          Get.dialog(const SignInPage(
                                              exitFromApp: false,
                                              backFromThis: false));
                                        } else {
                                          if (Get.currentRoute ==
                                              RouteHelper.signUp) {
                                            Get.back();
                                          } else {
                                            Get.toNamed(
                                                RouteHelper.getSignInRoute(
                                                    RouteHelper.signUp));
                                          }
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeExtraSmall),
                                        child: Text('sign_in'.tr,
                                            style: robotoMedium.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                      ),
                                    ),
                                  ]),
                            ]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _register(BuildContext context, String countryCode) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String number = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String referCode = _referCodeController.text.trim();

    String numberWithCountryCode = countryCode + number;
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    } else if (lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    } else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    } else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else if (number.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    } else if (password != confirmPassword) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    } else {
      SignupBody signUpBody = SignupBody(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: numberWithCountryCode,
        password: password,
        refCode: referCode,
      );
      if (!context.mounted) return;
      context.read<AuthBloc>().add(RegisterRequested(body: signUpBody));
    }
  }
}
