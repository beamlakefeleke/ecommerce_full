import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/common/controllers/theme_controller.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/confirmation_dialog.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:ecommerce/features/profile/widgets/profile_button_widget.dart';
import 'package:ecommerce/features/profile/widgets/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/profile/widgets/web_profile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    if(AuthHelper.isLoggedIn() && context.read<ProfileBloc>().state.userInfo == null) {
      context.read<ProfileBloc>().add(FetchProfileEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showWalletCard = Get.find<SplashController>().configModel!.customerWalletStatus == 1
        || Get.find<SplashController>().configModel!.loyaltyPointStatus == 1;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      key: UniqueKey(),
      body: BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
        bool isLoggedIn = AuthHelper.isLoggedIn();
        return (isLoggedIn && state.userInfo == null) ? const Center(child: CircularProgressIndicator()) :

            SingleChildScrollView(
              child: FooterView(
                minHeight: isLoggedIn ?  ResponsiveHelper.isDesktop(context) ? 0.4 : 0.6 : 0.35,
                child:(isLoggedIn && ResponsiveHelper.isDesktop(context)) ? const WebProfileWidget() : Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: Dimensions.webMaxWidth, height: context.height,
                  child: Center(
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                        child: SafeArea(
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            !ResponsiveHelper.isDesktop(context) ? IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back_ios),
                            ) : const SizedBox(),

                            Text('profile'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            const SizedBox(width: 50),
                          ]),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtremeLarge, right: Dimensions.paddingSizeExtremeLarge, bottom: Dimensions.paddingSizeLarge),
                        child: Row(children: [

                          ClipOval(child: CustomImage(
                            placeholder: Images.guestIcon,
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                                '/${(state.userInfo != null && isLoggedIn) ? state.userInfo!.image : ''}',
                            height: 70, width: 70, fit: BoxFit.cover,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                isLoggedIn ? '${state.userInfo!.fName} ${state.userInfo!.lName}' : 'guest_user'.tr,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              isLoggedIn ? Text(
                                state.userInfo!.email ?? '',
                                style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6)),
                              ) : const SizedBox(),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              isLoggedIn ? Text(
                                '${'joined'.tr} ${DateConverter.containTAndZToUTCFormat(state.userInfo!.createdAt!)}',
                                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                              ) : const SizedBox(),
                            ]),
                          ),

                        ]),
                      ),

                      showWalletCard ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? ProfileCardWidget(
                          image: Images.wallet,
                          title: state.userInfo != null ? state.userInfo!.walletBalance.toString() : '0',
                          data: 'wallet_balance'.tr,
                        ) : const SizedBox.shrink(),

                        Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ? ProfileCardWidget(
                          image: Images.loyal,
                          title: state.userInfo != null ? state.userInfo!.loyaltyPoint != null ? state.userInfo!.loyaltyPoint.toString() : '0' : '0',
                          data: 'loyalty_point'.tr,
                        ) : const SizedBox.shrink(),
                      ]) : const SizedBox(),
                      SizedBox(height: showWalletCard ? Dimensions.paddingSizeDefault : 0),

                      ProfileButtonWidget(icon: Icons.tonality_outlined, title: 'dark_mode'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                        Get.find<ThemeController>().toggleTheme();
                      }),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
                        return ProfileButtonWidget(
                          icon: Icons.notifications, title: 'notification'.tr,
                          isButtonActive: authController.notification, onTap: () {
                          authController.setNotificationActive(!authController.notification);
                        },
                        );
                      }) : const SizedBox(),
                      SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

                      isLoggedIn ? ProfileButtonWidget(icon: Icons.lock, title: 'change_password'.tr, onTap: () {
                        Get.toNamed(RouteHelper.getResetPasswordRoute('', '', 'password-change'));
                      }) : const SizedBox(),
                      SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

                      isLoggedIn ? ProfileButtonWidget(icon: Icons.edit, title: 'edit_profile'.tr, onTap: () {
                        Get.toNamed(RouteHelper.getUpdateProfileRoute());
                      }) : const SizedBox(),
                      SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

                      isLoggedIn ? ProfileButtonWidget(
                        icon: Icons.delete, title: 'delete_account'.tr,
                        iconImage: Images.profileDelete,
                        color: Theme.of(context).colorScheme.error,
                        onTap: () {
                          Get.dialog(ConfirmationDialog(
                            icon: Images.support,
                            title: 'are_you_sure_to_delete_account'.tr,
                            description: 'it_will_remove_your_all_information'.tr,
                            isLogOut: true,
                            onYesPressed: () => context.read<ProfileBloc>().add(DeleteUserEvent()),
                          ), useSafeArea: false);
                        },
                      ) : const SizedBox(),
                      SizedBox(height: isLoggedIn ? Dimensions.paddingSizeLarge : 0),

                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(AppConstants.appVersion.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                      ]),
                    ]),
                  ),
                ),
              ),
            );
      }),
    );
  }
}
