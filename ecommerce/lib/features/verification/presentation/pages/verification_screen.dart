import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_event.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_state.dart';
import 'package:ecommerce/features/location/presentation/helper/location_helper.dart';
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
    return BlocProvider(
      create: (_) => getIt<VerificationBloc>(),
      child: Builder(
        builder: (context) {
          final bloc = context.read<VerificationBloc>();
          return BlocConsumer<VerificationBloc, VerificationState>(
            bloc: bloc,
            listenWhen: (prev, curr) =>
                prev.status == VerificationStatus.loading &&
                curr.status != VerificationStatus.loading,
            listener: (context, state) {
              if (state.isSuccess) {
                if (state.actionType == VerificationActionType.verifyPhone) {
                  showAnimatedDialog(
                    context,
                    Center(
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(
                          Dimensions.paddingSizeExtraLarge,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusExtraLarge,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              Images.checked,
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            Text(
                              'verified'.tr,
                              style: robotoBold.copyWith(
                                fontSize: 30,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    dismissible: false,
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    LocationHelper.navigateToLocationScreen(
                      'verification',
                      offAll: true,
                    );
                  });
                } else if (state.actionType ==
                    VerificationActionType.verifyToken) {
                  Get.toNamed(
                    RouteHelper.getResetPasswordRoute(
                      _number,
                      state.verificationCode,
                      'reset-password',
                    ),
                  );
                } else if (state.actionType ==
                    VerificationActionType.forgetPassword) {
                  showCustomSnackBar(
                    'resend_code_successful'.tr,
                    isError: false,
                  );
                }
              } else {
                showCustomSnackBar(state.message);
              }
            },
            builder: (context, verificationState) {
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
                              ? const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                )
                              : null,
                          margin: context.width > 700
                              ? const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault,
                                )
                              : null,
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
                              getIt<SplashBloc>().state.configModel!.demo!
                                  ? Text(
                                      'for_demo_purpose'.tr,
                                      style: robotoRegular,
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'enter_the_verification_sent_to'
                                                    .tr,
                                            style: robotoRegular.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).disabledColor,
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
                                child: PinCodeTextField(
                                  length: 4,
                                  appContext: context,
                                  keyboardType: TextInputType.number,
                                  animationType: AnimationType.slide,
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    fieldHeight: 60,
                                    fieldWidth: 60,
                                    borderWidth: 1,
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    selectedColor: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.2),
                                    selectedFillColor: Colors.white,
                                    inactiveFillColor: Theme.of(
                                      context,
                                    ).disabledColor.withOpacity(0.2),
                                    inactiveColor: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.2),
                                    activeColor: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.4),
                                    activeFillColor: Theme.of(
                                      context,
                                    ).disabledColor.withOpacity(0.2),
                                  ),
                                  animationDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  enableActiveFill: true,
                                  onChanged: (code) =>
                                      bloc.add(VerificationCodeUpdated(code)),
                                  beforeTextPaste: (text) => true,
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
                                              getIt<AuthBloc>().add(
                                                LoginRequested(
                                                  phone: _number,
                                                  password: widget.password,
                                                ),
                                              );
                                            } else {
                                              bloc.add(
                                                ForgetPasswordRequested(
                                                  _number,
                                                ),
                                              );
                                            }
                                            _startTimer();
                                          }
                                        : null,
                                    child: Text(
                                      '${'resend'.tr}${_seconds > 0 ? ' ($_seconds)' : ''}',
                                    ),
                                  ),
                                ],
                              ),

                              verificationState.verificationCode.length == 4
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeLarge,
                                      ),
                                      child: CustomButton(
                                        buttonText: 'verify'.tr,
                                        isLoading: verificationState.isLoading,
                                        onPressed: () {
                                          if (widget.fromSignUp) {
                                            bloc.add(
                                              VerifyPhoneRequested(
                                                phone: _number,
                                                token: widget.token,
                                              ),
                                            );
                                          } else {
                                            bloc.add(
                                              VerifyTokenRequested(_number),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
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
}
