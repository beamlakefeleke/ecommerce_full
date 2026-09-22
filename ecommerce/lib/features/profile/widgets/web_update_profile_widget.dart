import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/common/widgets/image_picker_widget.dart';

class WebUpdateProfileWidget extends StatefulWidget {
  const WebUpdateProfileWidget({super.key});

  @override
  State<WebUpdateProfileWidget> createState() => _WebUpdateProfileWidgetState();
}

class _WebUpdateProfileWidgetState extends State<WebUpdateProfileWidget> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState> (
        listener: (context, state) {
          if (state.error != null) {
            showCustomSnackBar(state.error!);
          } else if (state.isSuccess && state.successMessage != null) {
            showCustomSnackBar(state.successMessage!, isError: false);
          }
        },
        builder: (context, state) {
          // bool isLoggedIn = AuthHelper.isLoggedIn();
          if(state.userInfo != null && _phoneController.text.isEmpty) {
            _firstNameController.text = state.userInfo!.fName ?? '';
            _lastNameController.text = state.userInfo!.lName ?? '';
            _phoneController.text = state.userInfo!.phone ?? '';
            _emailController.text = state.userInfo!.email ?? '';
          }

          return SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children : [
              SizedBox(
                height: 243,
                child: Stack(
                  children: [
                    Container(
                      height: 162,
                      width: Dimensions.webMaxWidth,
                      color: Theme.of(context).primaryColor.withOpacity(0.10),
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                              child: Text('edit_profile'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)))),
                    ),

                    Positioned(
                        top: 96,
                        left: (Dimensions.webMaxWidth/2) - 60,
                        child: ImagePickerWidget(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${state.userInfo!.image}',
                          onTap: () => context.read<ProfileBloc>().add(PickImageEvent()), rawFile: state.rawFile,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),


              Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'first_name'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        CustomTextField(
                          hintText: ' ',
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          nextFocus: _lastNameFocus,
                          inputType: TextInputType.name,
                          capitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'last_name'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    CustomTextField(
                      hintText: ' ',
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      nextFocus: _emailFocus,
                      inputType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                    ),
                  ]))
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'email'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      CustomTextField(
                        hintText: 'email'.tr,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        inputAction: TextInputAction.done,
                        inputType: TextInputType.emailAddress,
                      ),
                    ]),
                  ),

                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(
                          'phone'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text('(${'non_changeable'.tr})', style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error,
                        )),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      CustomTextField(
                        hintText: 'phone'.tr,
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        inputType: TextInputType.phone,
                        isEnabled: false,
                      ),
                    ]),
                  ),
                ],
              ),


              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).hintColor)
                    ),
                    width: 165,
                    child: CustomButton(
                      transparent: true,
                      textColor: Theme.of(context).hintColor,
                      radius: Dimensions.radiusSmall,
                      onPressed: () {
                        _phoneController.text = state.userInfo!.phone ?? '';
                        _firstNameController.text = state.userInfo!.fName ?? '';
                        _lastNameController.text = state.userInfo!.lName ?? '';
                        _emailController.text = state.userInfo!.email ?? '';
                      },
                      buttonText: 'reset'.tr,
                      isBold: false,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  const SizedBox( width: Dimensions.paddingSizeLarge),
                  SizedBox(width: 165, child: buttonWidget(state)),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),


            ]),
          );
        }
    );
  }

  Widget buttonWidget(ProfileState state) {
    return !state.isLoading ? CustomButton(
      radius: Dimensions.radiusSmall,
      onPressed: () => _updateProfile(state),
      buttonText: 'update'.tr,
      isBold: false,
      fontSize: Dimensions.fontSizeSmall,
    ) : const Center(child: CircularProgressIndicator());
  }

  void _updateProfile(ProfileState state) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    if (state.userInfo!.fName == firstName &&
        state.userInfo!.lName == lastName && state.userInfo!.phone == phoneNumber &&
        state.userInfo!.email == _emailController.text && state.pickedFile == null) {
      showCustomSnackBar('change_something_to_update'.tr);
    }else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }else if (lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    }else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    }else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (phoneNumber.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      UserInfo updatedUser = UserInfo(fName: firstName, lName: lastName, email: email, phone: phoneNumber);
      context.read<ProfileBloc>().add(UpdateProfileEvent(updatedUser, state.pickedFile, Get.find<AuthController>().getUserToken()));
    }
  }
}
