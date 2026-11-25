import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/store/domain/helpers/store_helper.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:get/get.dart' as getx;

class StoreDescriptionViewWidget extends StatelessWidget {
  final Store? store;
  const StoreDescriptionViewWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = StoreHelper.isStoreOpenNow(
      store!.active!,
      store!.schedules,
    );
    final Color? textColor = ResponsiveHelper.isDesktop(context) ? Colors.white : null;

    return Column(
      children: [
        ResponsiveHelper.isDesktop(context)
            ? Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: Stack(
                      children: [
                        CustomImage(
                          image:
                              '${getIt<SplashBloc>().state.configModel!.baseUrls!.storeImageUrl}/${store!.logo}',
                          height: ResponsiveHelper.isDesktop(context) ? 140 : 60,
                          width: ResponsiveHelper.isDesktop(context) ? 140 : 70,
                          fit: BoxFit.cover,
                        ),
                        isAvailable
                            ? const SizedBox()
                            : Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(Dimensions.radiusSmall),
                                    ),
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                  child: Text(
                                    'closed_now'.tr,
                                    textAlign: TextAlign.center,
                                    style: robotoRegular.copyWith(
                                      color: Colors.white,
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store!.name!,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            BlocBuilder<FavouriteBloc, FavouriteState>(
                              builder: (context, favouriteState) {
                                final bool isWished = favouriteState
                                    .wishStoreIdList
                                    .contains(store!.id);
                                return InkWell(
                                  onTap: () {
                                    if (AuthHelper.isLoggedIn()) {
                                      if (isWished) {
                                        context.read<FavouriteBloc>().add(
                                          FavouriteRemoved(
                                            id: store!.id,
                                            isStore: true,
                                          ),
                                        );
                                      } else {
                                        context.read<FavouriteBloc>().add(
                                          FavouriteAdded(
                                            store: store,
                                            isStore: true,
                                          ),
                                        );
                                      }
                                    } else {
                                      showCustomSnackBar('you_are_not_logged_in'.tr);
                                    }
                                  },
                                  child: ResponsiveHelper.isDesktop(context)
                                      ? Container(
                                          padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeExtraSmall,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall,
                                            ),
                                            border: Border.all(color: Colors.white),
                                          ),
                                          child: Center(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isWished
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                const SizedBox(
                                                  width: Dimensions.paddingSizeExtraSmall,
                                                ),
                                                Text(
                                                  'wish_list'.tr,
                                                  style: robotoRegular.copyWith(
                                                    fontWeight: FontWeight.w200,
                                                    color: Colors.white,
                                                    fontSize: Dimensions.fontSizeSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          isWished
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isWished
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).disabledColor,
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store!.address ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                final String? hostname =
                                    html.window.location.hostname;
                                final String protocol =
                                    html.window.location.protocol;
                                // filteringUrl logic: replace current route slug param
                                final List<String> routes =
                                    getx.Get.currentRoute.split('?');
                                final String slug = store!.slug ?? '';
                                final String shareUrl =
                                    '$protocol//$hostname${routes[0]}?slug=${slug.isNotEmpty ? slug : store!.id}';
                                Clipboard.setData(ClipboardData(text: shareUrl));
                                showCustomSnackBar(
                                  'store_url_copied'.tr,
                                  isError: false,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                ),
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                                child: const Icon(
                                  Icons.share,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ResponsiveHelper.isDesktop(context)
                              ? Dimensions.paddingSizeSmall
                              : 0,
                        ),
                        Row(
                          children: [
                            Text(
                              'minimum_order_amount'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Expanded(
                              child: Text(
                                PriceConverter.convertPrice(store!.minimumOrder),
                                textDirection: TextDirection.ltr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        SizedBox(
          height: ResponsiveHelper.isDesktop(context) ? 30 : Dimensions.paddingSizeSmall,
        ),
        ResponsiveHelper.isDesktop(context)
            ? IntrinsicHeight(
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    _ratingView(context, textColor),
                    const Expanded(child: SizedBox()),
                    const VerticalDivider(color: Colors.white, thickness: 1),
                    const Expanded(child: SizedBox()),
                    _locationView(context, textColor),
                    const Expanded(child: SizedBox()),
                    const VerticalDivider(color: Colors.white, thickness: 1),
                    const Expanded(child: SizedBox()),
                    _deliveryTimeView(context, textColor),
                    if (store!.delivery! && store!.freeDelivery!) ...[
                      const Expanded(child: SizedBox()),
                      const VerticalDivider(color: Colors.white, thickness: 1),
                      const Expanded(child: SizedBox()),
                      _freeDeliveryView(context, textColor),
                    ],
                    const Expanded(child: SizedBox()),
                  ],
                ),
              )
            : Row(
                children: [
                  const Expanded(child: SizedBox()),
                  _ratingView(context, textColor),
                  const Expanded(child: SizedBox()),
                  _locationView(context, textColor),
                  const Expanded(child: SizedBox()),
                  _deliveryTimeViewMobile(context, textColor),
                  if (store!.delivery! && store!.freeDelivery!) ...[
                    const Expanded(child: SizedBox()),
                    _freeDeliveryView(context, textColor),
                  ],
                  const Expanded(child: SizedBox()),
                ],
              ),
      ],
    );
  }

  Widget _ratingView(BuildContext context, Color? textColor) {
    return InkWell(
      onTap: () => getx.Get.toNamed(RouteHelper.getStoreReviewRoute(store!.id)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                store!.avgRating!.toStringAsFixed(1),
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            '${store!.ratingCount} + ${'ratings'.tr}',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationView(BuildContext context, Color? textColor) {
    return InkWell(
      onTap: () => getx.Get.toNamed(
        RouteHelper.getMapRoute(
          AddressModel(
            id: store!.id,
            address: store!.address,
            latitude: store!.latitude,
            longitude: store!.longitude,
            contactPersonNumber: '',
            contactPersonName: '',
            addressType: '',
          ),
          'store',
          getIt<SplashBloc>()
                  .getModuleConfig(
                    getIt<SplashBloc>().state.module!.moduleType!,
                  )
                  ?.newVariation ?? false,
        ),
      ),
      child: Column(
        children: [
          ResponsiveHelper.isDesktop(getx.Get.context!)
              ? Image.asset(Images.storeLocationIcon, height: 20, width: 20)
              : Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            'location'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryTimeView(BuildContext context, Color? textColor) {
    return Column(
      children: [
        Image.asset(Images.storeDeliveryTimeIcon, height: 20, width: 20),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          store!.deliveryTime!,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _deliveryTimeViewMobile(BuildContext context, Color? textColor) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.timer, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              store!.deliveryTime!,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(
          'delivery_time'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _freeDeliveryView(BuildContext context, Color? textColor) {
    return Column(
      children: [
        Icon(Icons.money_off, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        Text(
          'free_delivery'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
