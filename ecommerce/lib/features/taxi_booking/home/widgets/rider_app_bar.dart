import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/location/controllers/location_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:ecommerce/features/notification/presentation/bloc/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
class RiderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RiderAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : Container(
      width: Dimensions.webMaxWidth, height: 70, color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: GetBuilder<SplashController>(
        builder: (splashController) {
          return Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              (splashController.module != null && splashController.configModel!.module == null) ? InkWell(
                onTap: () => splashController.removeModule(),
                child: Image.asset(Images.moduleIcon, height: 22, width: 22, color: Theme.of(context).textTheme.bodyLarge!.color),
              ) : const SizedBox(),
              SizedBox(width: (splashController.module != null && splashController.configModel!.module
                  == null) ? Dimensions.paddingSizeExtraSmall : 0),
              Expanded(child: InkWell(
                onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                  ),
                  child: GetBuilder<LocationController>(builder: (locationController) {
                    return Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          AddressHelper.getUserAddressFromSharedPref()!.addressType == 'home' ? Icons.home_filled
                              : AddressHelper.getUserAddressFromSharedPref()!.addressType == 'office' ? Icons.work : Icons.location_on,
                          size: 20, color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            AddressHelper.getUserAddressFromSharedPref()!.address!,
                            style: robotoRegular.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodyLarge!.color),
                      ],
                    );
                  }),
                ),
              )),
              InkWell(
                child: BlocBuilder<NotificationBloc, NotificationState>(builder: (context, state) {
                  return Stack(children: [
                    Icon(Icons.notifications, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
                    state.hasUnread ? Positioned(top: 0, right: 0, child: Container(
                      height: 10, width: 10, decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor, shape: BoxShape.circle,
                      border: Border.all(width: 1, color: Theme.of(context).cardColor),
                    ),
                    )) : const SizedBox(),
                  ]);
                }),
                onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
              ),
            ]),
          );
        }
      ),
    );
  }

  @override
  Size get preferredSize => Size(Get.width, GetPlatform.isDesktop ? 70 : 70);
}
