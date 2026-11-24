import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/common/controllers/theme_controller.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/confirmation_dialog.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/profile/presentation/widgets/profile_button_widget.dart';
import 'package:ecommerce/features/profile/presentation/widgets/profile_card_widget.dart';

class WebProfileWidget extends StatelessWidget {
  const WebProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (p, c) =>
          p.actionStatus != c.actionStatus &&
          c.actionType == ProfileActionType.delete,
      listener: (context, state) {
        if (state.actionStatus == ProfileActionStatus.success) {
          showCustomSnackBar(state.actionMessage, isError: false);
          getIt<AuthRepository>().clearSharedData();
          context.read<FavouriteBloc>().add(const FavouriteCleared());
          Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
        } else if (state.actionStatus == ProfileActionStatus.failure) {
          Get.back();
          showCustomSnackBar(state.actionMessage, isError: true);
        }
      },
      builder: (context, profileController) {
        bool isLoggedIn = AuthHelper.isLoggedIn();
        return SizedBox(
          width: Dimensions.webMaxWidth,
          child: Column(
            children: [
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
                          padding: const EdgeInsets.only(
                            top: Dimensions.paddingSizeDefault,
                          ),
                          child: Text(
                            'profile'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 96,
                      left: (Dimensions.webMaxWidth / 2) - 60,
                      child: ClipOval(
                        child: CustomImage(
                          placeholder: Images.guestIcon,
                          image:
                              '${getIt<SplashBloc>().state.configModel!.baseUrls!.customerImageUrl}'
                              '/${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.image : ''}',
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          isLoggedIn
                              ? '${profileController.userInfoModel!.fName} ${profileController.userInfoModel!.lName}'
                              : 'guest_user'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                          ),
                        ),
                      ),
                    ),

                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            Get.dialog(
                              ConfirmationDialog(
                                icon: Images.support,
                                title: 'are_you_sure_to_delete_account'.tr,
                                description:
                                    'it_will_remove_your_all_information'.tr,
                                isLogOut: true,
                                onYesPressed: () => context
                                    .read<ProfileBloc>()
                                    .add(const ProfileAccountDeleted()),
                              ),
                              useSafeArea: false,
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                Images.profileDelete,
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),
                              Text(
                                'delete_account'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: Dimensions.paddingSizeLarge),
                  Expanded(
                    child: Container(
                      height: ResponsiveHelper.isDesktop(context) ? 130 : 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 0.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: CustomImage(
                              placeholder: Images.guestIcon,
                              image:
                                  '${getIt<SplashBloc>().state.configModel!.baseUrls!.customerImageUrl}'
                                  '/${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.image : ''}',
                              height: 30,
                              width: 30,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(
                            DateConverter.containTAndZToUTCFormat(
                              profileController.userInfoModel!.createdAt!,
                            ),
                            textDirection: TextDirection.ltr,
                            style: robotoMedium.copyWith(
                              fontSize: ResponsiveHelper.isDesktop(context)
                                  ? Dimensions.fontSizeDefault
                                  : Dimensions.fontSizeExtraLarge,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(
                            'since_joining'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // getIt<SplashBloc>().state.configModel!.customerWalletStatus == 1 ? Expanded(child: ProfileCard(
                  //   image: Images.walletProfile,
                  //   data: DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!),
                  //   title: 'since_joining'.tr,
                  // )) : const SizedBox(),
                  const SizedBox(width: Dimensions.paddingSizeExtremeLarge),

                  //SizedBox(width: getIt<SplashBloc>().state.configModel!.customerWalletStatus == 1 ? Dimensions.paddingSizeSmall : 0),
                  getIt<SplashBloc>().state
                              .configModel!
                              .customerWalletStatus ==
                          1
                      ? Expanded(
                          child: ProfileCardWidget(
                            image: Images.walletProfile,
                            data: PriceConverter.convertPrice(
                              profileController.userInfoModel!.walletBalance,
                            ),
                            title: 'wallet_balance'.tr,
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                    width:
                        getIt<SplashBloc>().state
                                .configModel!
                                .customerWalletStatus ==
                            1
                        ? Dimensions.paddingSizeExtremeLarge
                        : 0,
                  ),

                  isLoggedIn
                      ? Expanded(
                          child: ProfileCardWidget(
                            image: Images.shoppingBagIcon,
                            data: profileController.userInfoModel!.orderCount
                                .toString(),
                            title: 'total_order'.tr,
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                    width:
                        getIt<SplashBloc>().state
                                .configModel!
                                .customerWalletStatus ==
                            1
                        ? Dimensions.paddingSizeExtremeLarge
                        : 0,
                  ),

                  getIt<SplashBloc>().state
                              .configModel!
                              .loyaltyPointStatus ==
                          1
                      ? Expanded(
                          child: ProfileCardWidget(
                            image: Images.loyaltyIcon,
                            data:
                                profileController.userInfoModel!.loyaltyPoint !=
                                    null
                                ? profileController.userInfoModel!.loyaltyPoint
                                      .toString()
                                : '0',
                            title: 'loyalty_points'.tr,
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                    width:
                        getIt<SplashBloc>().state
                                .configModel!
                                .loyaltyPointStatus ==
                            1
                        ? Dimensions.paddingSizeLarge
                        : 0,
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeExtremeLarge),

              GridView.count(
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                childAspectRatio: 9,
                children: <Widget>[
                  ProfileButtonWidget(
                    icon: Icons.tonality_outlined,
                    title: 'dark_mode'.tr,
                    isButtonActive: Get.isDarkMode,
                    onTap: () {
                      Get.find<ThemeController>().toggleTheme();
                    },
                  ),

                  isLoggedIn
                      ? BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            return ProfileButtonWidget(
                              icon: Icons.notifications,
                              title: 'notification'.tr,
                              isButtonActive: authState.notification,
                              onTap: () {
                                context.read<AuthBloc>().add(
                                  NotificationToggled(!authState.notification),
                                );
                              },
                            );
                          },
                        )
                      : const SizedBox(),

                  isLoggedIn
                      ? profileController.userInfoModel!.socialId == null
                            ? ProfileButtonWidget(
                                icon: Icons.lock,
                                title: 'change_password'.tr,
                                onTap: () {
                                  Get.toNamed(
                                    RouteHelper.getResetPasswordRoute(
                                      '',
                                      '',
                                      'password-change',
                                    ),
                                  );
                                },
                              )
                            : const SizedBox()
                      : const SizedBox(),

                  isLoggedIn
                      ? ProfileButtonWidget(
                          icon: Icons.edit,
                          title: 'edit_profile'.tr,
                          onTap: () {
                            Get.toNamed(RouteHelper.getUpdateProfileRoute());
                          },
                        )
                      : const SizedBox(),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}
