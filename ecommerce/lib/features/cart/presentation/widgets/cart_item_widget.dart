import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ecommerce/common/widgets/custom_ink_well.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/language/controllers/language_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/item_bottom_sheet.dart';
import 'package:ecommerce/common/widgets/quantity_button.dart';
import 'package:ecommerce/common/widgets/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CartItemWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  const CartItemWidget({
    super.key,
    required this.cart,
    required this.cartIndex,
    required this.isAvailable,
    required this.addOns,
  });

  @override
  Widget build(BuildContext context) {
    final double? startingPrice = _calculatePriceWithVariation(item: cart.item);
    final double? endingPrice = _calculatePriceWithVariation(
      item: cart.item,
      isStartingPrice: false,
    );
    final String variationText = _setupVariationText(cart: cart) ?? '';
    final String addOnText = _setupAddonsText(cart: cart) ?? '';

    final double? discount = cart.item!.storeDiscount == 0
        ? cart.item!.discount
        : cart.item!.storeDiscount;
    final String? discountType = cart.item!.storeDiscount == 0
        ? cart.item!.discountType
        : 'percent';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: Slidable(
        key: UniqueKey(),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (context) => context.read<CartBloc>().add(
                CartItemRemoved(index: cartIndex, item: cart.item),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(
                  Get.find<LocalizationController>().isLtr
                      ? Dimensions.radiusDefault
                      : 0,
                ),
                left: Radius.circular(
                  Get.find<LocalizationController>().isLtr
                      ? 0
                      : Dimensions.radiusDefault,
                ),
              ),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: !ResponsiveHelper.isMobile(context)
                ? [const BoxShadow()]
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: CustomInkWell(
            onTap: () {
              ResponsiveHelper.isMobile(context)
                  ? showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (con) => ItemBottomSheet(
                        item: cart.item,
                        cartIndex: cartIndex,
                        cart: cart,
                      ),
                    )
                  : showDialog(
                      context: context,
                      builder: (con) => Dialog(
                        child: ItemBottomSheet(
                          item: cart.item,
                          cartIndex: cartIndex,
                          cart: cart,
                        ),
                      ),
                    );
            },
            radius: Dimensions.radiusDefault,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
              horizontal: Dimensions.paddingSizeSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                          child: CustomImage(
                            image:
                                '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${cart.item!.image}',
                            height: ResponsiveHelper.isDesktop(context)
                                ? 90
                                : 65,
                            width: ResponsiveHelper.isDesktop(context)
                                ? 90
                                : 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (!isAvailable)
                          Positioned(
                            top: 0,
                            left: 0,
                            bottom: 0,
                            right: 0,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                              child: Text(
                                'not_available_now_break'.tr,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  cart.item!.name!,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall,
                              ),
                              if ((Get.find<SplashController>()
                                          .configModel!
                                          .moduleConfig!
                                          .module!
                                          .unit! &&
                                      cart.item!.unitType != null &&
                                      !Get.find<SplashController>()
                                          .getModuleConfig(
                                            cart.item!.moduleType,
                                          )
                                          .newVariation!) ||
                                  (Get.find<SplashController>()
                                          .configModel!
                                          .moduleConfig!
                                          .module!
                                          .vegNonVeg! &&
                                      Get.find<SplashController>()
                                          .configModel!
                                          .toggleVegNonVeg!))
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                    horizontal: Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusSmall,
                                    ),
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.2),
                                  ),
                                  child: Text(
                                    Get.find<SplashController>()
                                            .configModel!
                                            .moduleConfig!
                                            .module!
                                            .unit!
                                        ? cart.item!.unitType ?? ''
                                        : cart.item!.veg == 0
                                        ? 'non_veg'.tr
                                        : 'veg'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),

                          RatingBar(
                            rating: cart.item!.avgRating,
                            size: 12,
                            ratingCount: cart.item!.ratingCount,
                          ),
                          const SizedBox(height: 5),

                          Wrap(
                            children: [
                              Text(
                                '${PriceConverter.convertPrice(startingPrice, discount: discount, discountType: discountType)}'
                                '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice, discount: discount, discountType: discountType)}' : ''}',
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                              SizedBox(
                                width: (discount ?? 0) > 0
                                    ? Dimensions.paddingSizeExtraSmall
                                    : 0,
                              ),
                              if ((discount ?? 0) > 0)
                                Text(
                                  '${PriceConverter.convertPrice(startingPrice)}'
                                  '${endingPrice != null ? ' - ${PriceConverter.convertPrice(endingPrice)}' : ''}',
                                  textDirection: TextDirection.ltr,
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                  ),
                                ),
                            ],
                          ),

                          if (ResponsiveHelper.isDesktop(context) &&
                              Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .addOn! &&
                              addOnText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeExtraSmall,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${'addons'.tr}: ',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      addOnText,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (ResponsiveHelper.isDesktop(context) &&
                              variationText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: Dimensions.paddingSizeExtraSmall,
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      variationText,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Quantity controls
                    BlocBuilder<CartBloc, CartState>(
                      buildWhen: (p, c) => p.isLoading != c.isLoading,
                      builder: (context, cartState) {
                        return Row(
                          children: [
                            QuantityButton(
                              onTap: cartState.isLoading
                                  ? null
                                  : () {
                                      if (cart.quantity! > 1) {
                                        context.read<CartBloc>().add(
                                          CartItemQuantityUpdated(
                                            isIncrement: false,
                                            cartIndex: cartIndex,
                                            stock: cart.stock,
                                            quantityLimit: cart.quantityLimit,
                                          ),
                                        );
                                      } else {
                                        context.read<CartBloc>().add(
                                          CartItemRemoved(
                                            index: cartIndex,
                                            item: cart.item,
                                          ),
                                        );
                                      }
                                    },
                              isIncrement: false,
                              showRemoveIcon: cart.quantity! == 1,
                            ),
                            Text(
                              cart.quantity.toString(),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraLarge,
                              ),
                            ),
                            QuantityButton(
                              onTap: cartState.isLoading
                                  ? null
                                  : () {
                                      if (cartState.cartList.isNotEmpty) {
                                        context.read<CartBloc>().add(
                                          CartModuleForcefullySet(
                                            cartState
                                                .cartList[0]
                                                .item!
                                                .moduleId!,
                                          ),
                                        );
                                      }
                                      context.read<CartBloc>().add(
                                        CartItemQuantityUpdated(
                                          isIncrement: true,
                                          cartIndex: cartIndex,
                                          stock: cart.stock,
                                          quantityLimit: cart.quantityLimit,
                                        ),
                                      );
                                    },
                              isIncrement: true,
                              color: cartState.isLoading
                                  ? Theme.of(context).disabledColor
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                if (!ResponsiveHelper.isDesktop(context) &&
                    Get.find<SplashController>()
                        .configModel!
                        .moduleConfig!
                        .module!
                        .addOn! &&
                    addOnText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeExtraSmall,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                        ),
                        Text(
                          '${'addons'.tr}: ',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            addOnText,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!ResponsiveHelper.isDesktop(context) &&
                    variationText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeExtraSmall,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                        ),
                        Text(
                          '${'variations'.tr}: ',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            variationText,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double? _calculatePriceWithVariation({
    required Item? item,
    bool isStartingPrice = true,
  }) {
    double? startingPrice;
    double? endingPrice;
    if (item!.variations!.isNotEmpty) {
      final List<double?> priceList =
          item.variations!.map((v) => v.price).toList()
            ..sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if (priceList[0]! < priceList[priceList.length - 1]!) {
        endingPrice = priceList[priceList.length - 1];
      }
    } else {
      startingPrice = item.price;
    }
    return isStartingPrice ? startingPrice : endingPrice;
  }

  String? _setupVariationText({required CartModel cart}) {
    String variationText = '';
    if (Get.find<SplashController>()
        .getModuleConfig(cart.item!.moduleType)
        .newVariation!) {
      for (int i = 0; i < cart.foodVariations!.length; i++) {
        if (cart.foodVariations![i].contains(true)) {
          variationText =
              '$variationText${variationText.isNotEmpty ? ', ' : ''}${cart.item!.foodVariations![i].name} (';
          for (int j = 0; j < cart.foodVariations![i].length; j++) {
            if (cart.foodVariations![i][j]!) {
              variationText =
                  '$variationText${variationText.endsWith('(') ? '' : ', '}${cart.item!.foodVariations![i].variationValues![j].level}';
            }
          }
          variationText = '$variationText)';
        }
      }
    } else if (cart.variation!.isNotEmpty) {
      final List<String> types = cart.variation![0].type!.split('-');
      if (types.length == cart.item!.choiceOptions!.length) {
        for (int i = 0; i < cart.item!.choiceOptions!.length; i++) {
          variationText =
              '$variationText${i == 0 ? '' : ',  '}${cart.item!.choiceOptions![i].title} - ${types[i]}';
        }
      } else {
        variationText = cart.item!.variations![0].type ?? '';
      }
    }
    return variationText;
  }

  String? _setupAddonsText({required CartModel cart}) {
    String addOnText = '';
    int index0 = 0;
    final List<int?> ids = cart.addOnIds!.map((a) => a.id).toList();
    final List<int?> qtys = cart.addOnIds!.map((a) => a.quantity).toList();
    for (final addOn in cart.item!.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText =
            '$addOnText${index0 == 0 ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        index0++;
      }
    }
    return addOnText;
  }
}
