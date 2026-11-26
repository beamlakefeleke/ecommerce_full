import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/profile/domain/models/userinfo_model.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:ecommerce/features/verification/domain/usecases/verification_usecases.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/helper/route_helper.dart';

class NewPassScreen extends StatefulWidget {
  final String? resetToken;
  final String? number;
  final bool fromPasswordChange;
  const NewPassScreen({
    super.key,
    required this.resetToken,
    required this.number,
    required this.fromPasswordChange,
  });

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

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
                curr.actionType == VerificationActionType.resetPassword,
            listener: (context, state) {
              if (state.isSuccess) {
                getIt<AuthBloc>().add(
                  LoginRequested(
                    phone: '+${widget.number!.trim()}',
                    password: _newPasswordController.text.trim(),
                  ),
                );
                Get.offAllNamed(RouteHelper.getSignInRoute('reset-password'));
              } else {
                showCustomSnackBar(state.message);
              }
            },
            builder: (context, verificationState) {
              return Scaffold(
                backgroundColor: Theme.of(context).cardColor,
                appBar: CustomAppBar(
                  title: widget.fromPasswordChange
                      ? 'change_password'.tr
                      : 'reset_password'.tr,
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
                              : null,
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
                              Image.asset(Images.forgetIcon, width: 100),
                              const SizedBox(
                                height: Dimensions.paddingSizeExtraLarge,
                              ),

                              Text(
                                'enter_new_password'.tr,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                              const SizedBox(height: 50),

                              Column(
                                children: [
                                  CustomTextField(
                                    titleText: 'new_password'.tr,
                                    controller: _newPasswordController,
                                    focusNode: _newPasswordFocus,
                                    nextFocus: _confirmPasswordFocus,
                                    inputType: TextInputType.visiblePassword,
                                    prefixImage: Images.lock,
                                    isPassword: true,
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),

                                  CustomTextField(
                                    titleText: 'confirm_password'.tr,
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocus,
                                    inputAction: TextInputAction.done,
                                    inputType: TextInputType.visiblePassword,
                                    prefixImage: Images.lock,
                                    isPassword: true,
                                    onSubmit: (text) => GetPlatform.isWeb
                                        ? _resetPassword(context)
                                        : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              BlocBuilder<ProfileBloc, ProfileState>(
                                bloc: getIt<ProfileBloc>(),
                                builder: (context, profileState) {
                                  final isLoading = widget.fromPasswordChange
                                      ? profileState.isLoading
                                      : verificationState.isLoading;
                                  return CustomButton(
                                    buttonText: 'submit'.tr,
                                    isLoading: isLoading,
                                    onPressed: () => _resetPassword(context),
                                  );
                                },
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

  void _resetPassword(BuildContext context) {
    String password = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    } else if (password != confirmPassword) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    } else {
      if (widget.fromPasswordChange) {
        final profileBloc = getIt<ProfileBloc>();
        UserInfoModel user = profileBloc.state.userInfoModel!;
        user.password = password;
        profileBloc.add(ProfilePasswordChanged(user));
      } else {
        context.read<VerificationBloc>().add(
          ResetPasswordRequested(
            ResetPasswordParams(
              resetToken: widget.resetToken,
              number: '+${widget.number!.trim()}',
              password: password,
              confirmPassword: confirmPassword,
            ),
          ),
        );
      }
    }
  }
}
