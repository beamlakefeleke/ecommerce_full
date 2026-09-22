import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/common/widgets/custom_ink_well.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/controllers/store_controller.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/new_tag.dart';
import 'package:ecommerce/common/widgets/rating_bar.dart';
import 'package:ecommerce/features/store/screens/store_screen.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final bool? isNewStore;
  const StoreCard({super.key, required this.store, this.isNewStore = false});

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy;
    double distance = Get.find<StoreController>().getRestaurantDistance(
      LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
    );

    return Stack(children: [

      Container(
        width: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: ResponsiveHelper.isMobile(context) ? [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 1))] : null,
        ),
        child: CustomInkWell(
          onTap: () {
            if(Get.find<SplashController>().moduleList != null) {
              for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                if(module.id == store.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(id: store.id, page: 'store'),
              arguments: StoreScreen(store: store, fromModule: false),
            );
          },
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          radius: Dimensions.radiusDefault,
          child: Stack(children: [

            Column(children: [

              Expanded(
                flex: 5,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImage(
                      image: '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}''/${store.logo}',
                      height: 50, width: 50, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      SizedBox(
                        width: 190,
                        child: Text(store.name ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      !isPharmacy ? RatingBar(
                        rating: store.avgRating,
                        ratingCount: store.ratingCount,
                        size: 12,
                      ) : Row(children: [

                        Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Expanded(
                          child: Text(store.address ?? '',
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      !isPharmacy ? Row(children: [

                        Icon(Icons.storefront, size: 15, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Flexible(
                          child: Text(store.address ?? '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      ]) : Text('${store.itemCount}' ' ' 'items'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                    ]),
                  ),
                ]),
              ),
              Expanded(
                flex: 2,
                child: Row(children: [

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Row(children: [

                      Image.asset(Images.distanceLine, height: 15, width: 15),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text('${distance > 100 ? '100+' : distance.toStringAsFixed(2)} ${'km'.tr}', style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text('from_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),
                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    ),
                    child: Row(children: [

                      Image.asset(Images.clockIcon, height: 15, width: 15, color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text(Get.find<StoreController>().isOpenNow(store) ? 'open_now'.tr : 'closed_now'.tr, style: robotoBold.copyWith(color: Get.find<StoreController>().isOpenNow(store) ? const Color(0xffECA507) : Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),
                ]),
              ),
            ]),

            Positioned(
              top: 0,
              left: Get.find<LocalizationController>().isLtr ? null : 0,
              right: Get.find<LocalizationController>().isLtr ? 0 : null,
              child: BlocBuilder<FavouriteBloc, FavouriteState>(builder: (context, state) {
                bool isWished = state.wishStoreIdList.contains(store.id);
                return InkWell(
                  onTap: () {
                    if(AuthHelper.isLoggedIn()) {
                      isWished ? getIt<FavouriteBloc>().add(FavouriteRemoved(id: store.id, isStore: true))
                          : getIt<FavouriteBloc>().add(FavouriteAdded(item: null, store: store, isStore: true));
                    }else {
                      showCustomSnackBar('you_are_not_logged_in'.tr);
                    }
                  },
                  child: Icon(
                    isWished ? Icons.favorite : Icons.favorite_border,  size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }),
            ),

          ]),
        ),
      ),

      const NewTag(),
    ]);
  }
}
