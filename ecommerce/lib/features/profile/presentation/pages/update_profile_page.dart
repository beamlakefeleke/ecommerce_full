import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/profile/domain/entities/user_info.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/image_picker_widget.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/my_text_field.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:ecommerce/features/profile/widgets/profile_bg_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall() {
    if(AuthHelper.isLoggedIn() && context.read<ProfileBloc>().state.userInfo == null) {
      context.read<ProfileBloc>().add(FetchProfileEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.error != null) {
            showCustomSnackBar(state.error!);
          } else if (state.isSuccess && state.successMessage != null) {
            showCustomSnackBar(state.successMessage!, isError: false);
            Get.back();
          }
        },
        builder: (context, state) {
        bool isLoggedIn = AuthHelper.isLoggedIn();
        if(state.userInfo != null && _phoneController.text.isEmpty) {
          _firstNameController.text = state.userInfo!.fName ?? '';
          _lastNameController.text = state.userInfo!.lName ?? '';
          _phoneController.text = state.userInfo!.phone ?? '';
          _emailController.text = state.userInfo!.email ?? '';
        }

        return isLoggedIn ? state.userInfo != null ? ProfileBgWidget(
          backButton: true,
          circularImage: ImagePickerWidget(
            image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${state.userInfo!.image}',
            onTap: () => context.read<ProfileBloc>().add(PickImageEvent()), rawFile: state.rawFile,
          ),
          mainWidget: Column(children: [

            Expanded(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Center(child: FooterView(
                minHeight: 0.45,
                child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(
                    'first_name'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  MyTextField(
                    hintText: 'first_name'.tr,
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    nextFocus: _lastNameFocus,
                    inputType: TextInputType.name,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    'last_name'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  MyTextField(
                    hintText: 'last_name'.tr,
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    nextFocus: _emailFocus,
                    inputType: TextInputType.name,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    'email'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  MyTextField(
                    hintText: 'email'.tr,
                    controller: _emailController,
                    focusNode: _emailFocus,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

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
                  MyTextField(
                    hintText: 'phone'.tr,
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    inputType: TextInputType.phone,
                    isEnabled: false,
                  ),

                  //
                  ResponsiveHelper.isDesktop(context) ? Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    child: UpdateProfileButton(isLoading: state.isLoading, onPressed: () {
                      return _updateProfile(state);
                    }),
                  ) : const SizedBox.shrink() ,

                ])),
              )),
            )),

            ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : Padding(
              padding: EdgeInsets.only(bottom: GetPlatform.isIOS ? Dimensions.paddingSizeLarge : 0),
              child: UpdateProfileButton(isLoading: state.isLoading, onPressed: () => _updateProfile(state)),
            ),

          ]),
        ) : const Center(child: CircularProgressIndicator()) :  NotLoggedInScreen(callBack: (value){
          initCall();
          setState(() {});
        });
      }),
    );
  }

  void _updateProfile(ProfileState state) {
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

class UpdateProfileButton extends StatelessWidget {
  final bool isLoading;
  final Function onPressed;
  const UpdateProfileButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return !isLoading ? CustomButton(
      onPressed: onPressed,
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      buttonText: 'update'.tr,
    ) : const Center(child: CircularProgressIndicator());
  }
}
