import 'dart:async';

import 'package:ecommerce/features/location/controllers/location_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/features/verification/controllers/verification_controller.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_dialog.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';

class VerificationScreen extends StatefulWidget {
  final String? number;
  final bool fromSignUp;
  final String? token;
  final String password;
  const VerificationScreen({
    super.key,
    required this.number,
    required this.password,
    required this.fromSignUp,
    required this.token,
  });

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();

    _number = widget.number!.startsWith('+')
        ? widget.number
        : '+${widget.number!.substring(1, widget.number!.length)}';
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBar(title: 'otp_verification'.tr),
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
                    ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                    : null,
                margin: context.width > 700
                    ? const EdgeInsets.all(Dimensions.paddingSizeDefault)
                    : null,
                decoration: context.width > 700
                    ? BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      )
                    : null,
                child: GetBuilder<VerificationController>(
                  builder: (verificationController) {
                    return Column(
                      children: [
                        Get.find<SplashController>().configModel!.demo!
                            ? Text('for_demo_purpose'.tr, style: robotoRegular)
                            : RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'enter_the_verification_sent_to'.tr,
                                      style: robotoRegular.copyWith(
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' $_number',
                                      style: robotoMedium.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 39,
                            vertical: 35,
                          ),
                          child: MaterialPinField(
                            length: 4,
                            keyboardType: TextInputType.number,
                            theme: MaterialPinTheme(
                              shape: MaterialPinShape.outlined,
                              cellSize: const Size(60, 60),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusSmall,
                              ),
                              entryAnimation: MaterialPinAnimation.slide,
                              animationDuration: const Duration(
                                milliseconds: 300,
                              ),
                              borderColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.2),
                              focusedBorderColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.2),
                              focusedFillColor: Colors.white,
                              fillColor: Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.2),
                              filledBorderColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.4),
                              filledFillColor: Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.2),
                            ),
                            onChanged:
                                verificationController.updateVerificationCode,
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'did_not_receive_the_code'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            TextButton(
                              onPressed: _seconds < 1
                                  ? () {
                                      if (widget.fromSignUp) {
                                          Get.find<AuthController>()
                                              .login(_number!, widget.password)
                                            .then((value) {
                                              if (value.isSuccess) {
                                                _startTimer();
                                                showCustomSnackBar(
                                                  'resend_code_successful'.tr,
                                                  isError: false,
                                                );
                                              } else {
                                                showCustomSnackBar(
                                                  value.message,
                                                );
                                              }
                                            });
                                      } else {
                                        verificationController
                                            .forgetPassword(_number)
                                            .then((value) {
                                              if (value.isSuccess) {
                                                _startTimer();
                                                showCustomSnackBar(
                                                  'resend_code_successful'.tr,
                                                  isError: false,
                                                );
                                              } else {
                                                showCustomSnackBar(
                                                  value.message,
                                                );
                                              }
                                            });
                                      }
                                    }
                                  : null,
                              child: Text(
                                '${'resend'.tr}${_seconds > 0 ? ' ($_seconds)' : ''}',
                              ),
                            ),
                          ],
                        ),

                        verificationController.verificationCode.length == 4
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeLarge,
                                ),
                                child: CustomButton(
                                  buttonText: 'verify'.tr,
                                  isLoading: verificationController.isLoading,
                                  onPressed: () {
                                    if (widget.fromSignUp) {
                                      verificationController
                                          .verifyPhone(_number, widget.token)
                                          .then((value) {
                                            if (value.isSuccess) {
                                              showAnimatedDialog(
                                                context,
                                                Center(
                                                  child: Container(
                                                    width: 300,
                                                    padding: const EdgeInsets.all(
                                                      Dimensions
                                                          .paddingSizeExtraLarge,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Dimensions
                                                                .radiusExtraLarge,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Image.asset(
                                                          Images.checked,
                                                          width: 100,
                                                          height: 100,
                                                        ),
                                                        const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeLarge,
                                                        ),
                                                        Text(
                                                          'verified'.tr,
                                                          style: robotoBold.copyWith(
                                                            fontSize: 30,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .bodyLarge!
                                                                    .color,
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                dismissible: false,
                                              );
                                              Future.delayed(
                                                const Duration(seconds: 2),
                                                () {
                                                  Get.find<LocationController>()
                                                      .navigateToLocationScreen(
                                                        'verification',
                                                        offAll: true,
                                                      );
                                                },
                                              );
                                            } else {
                                              showCustomSnackBar(value.message);
                                            }
                                          });
                                    } else {
                                      verificationController
                                          .verifyToken(_number)
                                          .then((value) {
                                            if (value.isSuccess) {
                                              Get.toNamed(
                                                RouteHelper.getResetPasswordRoute(
                                                  _number,
                                                  verificationController
                                                      .verificationCode,
                                                  'reset-password',
                                                ),
                                              );
                                            } else {
                                              showCustomSnackBar(value.message);
                                            }
                                          });
                                    }
                                  },
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
