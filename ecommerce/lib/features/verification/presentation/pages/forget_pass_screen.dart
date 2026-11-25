import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/auth/domain/entities/social_sign_in_params.dart';
import 'package:ecommerce/features/auth/data/models/social_log_in_body.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_event.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_state.dart';
import 'package:ecommerce/helper/custom_validator.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  final bool fromSocialLogin;
  final SocialLogInBody? socialLogInBody;
  const ForgetPassScreen({
    super.key,
    required this.fromSocialLogin,
    required this.socialLogInBody,
  });

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _numberController = TextEditingController();
  String? _countryDialCode = CountryCode.fromCountryCode(
    getIt<SplashBloc>().state.configModel!.country!,
  ).dialCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VerificationBloc>(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<VerificationBloc, VerificationState>(
            listenWhen: (prev, curr) =>
                prev.status == VerificationStatus.loading &&
                curr.status != VerificationStatus.loading &&
                curr.actionType == VerificationActionType.forgetPassword,
            listener: (context, state) {
              if (state.isSuccess) {
                Get.toNamed(
                  RouteHelper.getVerificationRoute(
                    state.phone ?? '',
                    '',
                    RouteHelper.forgotPassword,
                    '',
                  ),
                );
              } else {
                showCustomSnackBar(state.message);
              }
            },
            builder: (context, verificationState) {
              return Scaffold(
                appBar: CustomAppBar(
                  title: widget.fromSocialLogin
                      ? 'phone'.tr
                      : 'forgot_password'.tr,
                ),
                endDrawer: const MenuDrawer(),
                endDrawerEnableOpenDragGesture: false,
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: FooterView(
                        child: Container(
                          width: context.width > 700 ? 700 : context.width,
                          padding: context.width > 700
                              ? const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                )
                              : const EdgeInsets.all(
                                  Dimensions.paddingSizeLarge,
                                ),
                          margin: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault,
                          ),
                          decoration: context.width > 700
                              ? BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors
                                          .grey[Get.isDarkMode ? 700 : 300]!,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                )
                              : null,
                          child: Column(
                            children: [
                              Image.asset(Images.forgot, height: 220),

                              Padding(
                                padding: const EdgeInsets.all(30),
                                child: Text(
                                  'please_enter_mobile'.tr,
                                  style: robotoRegular,
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              CustomTextField(
                                titleText: 'phone'.tr,
                                controller: _numberController,
                                inputType: TextInputType.phone,
                                inputAction: TextInputAction.done,
                                isPhone: true,
                                showTitle: ResponsiveHelper.isDesktop(context),
                                onCountryChanged: (CountryCode countryCode) {
                                  _countryDialCode = countryCode.dialCode;
                                },
                                countryDialCode: _countryDialCode != null
                                    ? CountryCode.fromCountryCode(
                                        getIt<SplashBloc>()
                                            .state
                                            .configModel!
                                            .country!,
                                      ).code
                                    : getIt<LanguageBloc>()
                                          .state
                                          .locale
                                          .countryCode,
                                onSubmit: (text) => GetPlatform.isWeb
                                    ? _forgetPass(context, _countryDialCode!)
                                    : null,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),

                              CustomButton(
                                buttonText: 'next'.tr,
                                isLoading: verificationState.isLoading,
                                onPressed: () =>
                                    _forgetPass(context, _countryDialCode!),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),

                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${'if_you_have_any_queries_feel_free_to_contact_with_our'.tr} ',
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'help_and_support'.tr,
                                      style: robotoMedium.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeDefault,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => Get.toNamed(
                                          RouteHelper.getSupportRoute(),
                                        ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _forgetPass(BuildContext context, String countryCode) async {
    String phone = _numberController.text.trim();

    String numberWithCountryCode = countryCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(
      numberWithCountryCode,
    );
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else {
      if (widget.fromSocialLogin) {
        widget.socialLogInBody!.phone = numberWithCountryCode;
        getIt<AuthBloc>().add(
          SocialRegistrationRequested(
            SocialSignInParams(
              email: widget.socialLogInBody!.email,
              token: widget.socialLogInBody!.token,
              uniqueId: widget.socialLogInBody!.uniqueId,
              medium: widget.socialLogInBody!.medium,
              phone: numberWithCountryCode,
            ),
          ),
        );
      } else {
        context.read<VerificationBloc>().add(
          ForgetPasswordRequested(numberWithCountryCode),
        );
      }
    }
  }
}
