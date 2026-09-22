
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_state.dart';
import 'package:ecommerce/features/menu/domain/models/menu_model.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/features/auth/presentation/pages/sign_in_page.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/confirmation_dialog.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MenuButtonWidget extends StatelessWidget {
  final MenuModel menu;
  final bool isProfile;
  final bool isLogout;
  const MenuButtonWidget({super.key, required this.menu, required this.isProfile, required this.isLogout});

  @override
  Widget build(BuildContext context) {
    int count = ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4;
    double size = ((context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth : context.width)/count)-Dimensions.paddingSizeDefault;

    return InkWell(
      onTap: () async {
        if(isLogout) {
          Get.back();
          if(AuthHelper.isLoggedIn()) {
            Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () {
              Get.find<ProfileController>().clearUserInfo();
              Get.find<AuthController>().clearSharedData();
              Get.find<AuthController>().socialLogout();
              getIt<CartBloc>().add(ClearCartEvent());
              getIt<FavouriteBloc>().add(const FavouriteLocalCleared());
              if(!ResponsiveHelper.isDesktop(context)) {
                Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
              } else{
                Get.dialog(const SignInPage(exitFromApp: true, backFromThis: true));
              }
            }), useSafeArea: false);
          }else {
            if (!ResponsiveHelper.isDesktop(context)) {
              getIt<FavouriteBloc>().add(const FavouriteLocalCleared());
              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
            } else{
              Get.dialog(const SignInPage(exitFromApp: true, backFromThis: true));
            }
          }
        }else if(menu.route.startsWith('http')) {
          if(await canLaunchUrlString(menu.route)) {
            launchUrlString(menu.route, mode: LaunchMode.externalApplication);
          }
        }else {
            launchUrlString(menu.route, mode: LaunchMode.externalApplication);
          }
        }else {
          Get.offNamed(menu.route);
        }
      },
      child: Column(children: [

        Container(
          height: size-(size*0.2),
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            color: isLogout ? AuthHelper.isLoggedIn() ? Colors.red : Colors.green : Theme.of(context).primaryColor,
            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
          ),
          alignment: Alignment.center,
          child: isProfile ? ProfileImageWidget(size: size) : Image.asset(menu.icon, width: size, height: size, color: Colors.white),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(menu.title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center),

      ]),
    );
  }
}

class ProfileImageWidget extends StatelessWidget {
  final double size;
  const ProfileImageWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      return Container(
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2, color: Colors.white)),
        child: ClipOval(
          child: CustomImage(
            image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                '/${(profileController.userInfoModel != null && AuthHelper.isLoggedIn()) ? profileController.userInfoModel!.image ?? '' : ''}',
            width: size, height: size, fit: BoxFit.cover,
          ),
        ),
      );
    });
  }
}

