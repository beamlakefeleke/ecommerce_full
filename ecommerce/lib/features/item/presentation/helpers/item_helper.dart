import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/cart_snackbar.dart';
import 'package:ecommerce/common/widgets/confirmation_dialog.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/item_bottom_sheet.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/item/presentation/pages/item_details_screen.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/images.dart';

/// Pure item helpers ported from the legacy `ItemService` / `ItemController`.
/// Stateless so both [ItemBloc] and (still-GetX) consumers can call them
/// without a GetX controller.
class ItemHelper {
  const ItemHelper._();

  static double? getStartingPrice(Item item) {
    double? startingPrice = 0;
    if (item.choiceOptions != null && item.choiceOptions!.isNotEmpty) {
      final List<double?> priceList = [];
      for (var variation in item.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
    } else {
      startingPrice = item.price;
    }
    return startingPrice;
  }

  static bool isAvailable(Item item) {
    return DateConverter.isAvailable(
      item.availableTimeStarts,
      item.availableTimeEnds,
    );
  }

  static double? getDiscount(Item item) =>
      item.storeDiscount == 0 ? item.discount : item.storeDiscount;

  static String? getDiscountType(Item item) =>
      item.storeDiscount == 0 ? item.discountType : 'percent';

  static List<bool> initializeCartAddonActiveList(
    List<AddOn>? addOnIds,
    List<AddOns>? addOns,
  ) {
    final List<int?> addOnIdList = [];
    final List<bool> addOnActiveList = [];
    for (var addOnId in addOnIds!) {
      addOnIdList.add(addOnId.id);
    }
    for (var addOn in addOns!) {
      addOnActiveList.add(addOnIdList.contains(addOn.id));
    }
    return addOnActiveList;
  }

  static List<int?> initializeCartAddonsQtyList(
    List<AddOn>? addOnIds,
    List<AddOns>? addOns,
  ) {
    final List<int?> addOnIdList = [];
    final List<int?> addOnQtyList = [];
    for (var addOnId in addOnIds!) {
      addOnIdList.add(addOnId.id);
    }
    for (var addOn in addOns!) {
      if (addOnIdList.contains(addOn.id)) {
        addOnQtyList.add(addOnIds[addOnIdList.indexOf(addOn.id)].quantity);
      } else {
        addOnQtyList.add(1);
      }
    }
    return addOnQtyList;
  }

  static List<bool> collapseVariation(List<FoodVariation>? foodVariations) {
    final List<bool> collapse = [];
    for (int index = 0; index < foodVariations!.length; index++) {
      collapse.add(true);
    }
    return collapse;
  }

  static List<int> initializeCartVariationIndexes(
    List<Variation>? variation,
    List<ChoiceOptions>? choiceOptions,
  ) {
    final List<int> variationIndex = [];
    final List<String> variationTypes = [];
    if (variation!.isNotEmpty && variation[0].type != null) {
      variationTypes.addAll(variation[0].type!.split('-'));
    }
    int varIndex = 0;
    for (var choiceOption in choiceOptions!) {
      for (int index = 0; index < choiceOption.options!.length; index++) {
        if (choiceOption.options![index].trim().replaceAll(' ', '') ==
            variationTypes[varIndex].trim()) {
          variationIndex.add(index);
          break;
        }
      }
      varIndex++;
    }
    return variationIndex;
  }

  static List<List<bool?>> initializeSelectedVariation(
    List<FoodVariation>? foodVariations,
  ) {
    final List<List<bool?>> selectedVariations = [];
    for (int index = 0; index < foodVariations!.length; index++) {
      selectedVariations.add([]);
      for (int i = 0; i < foodVariations[index].variationValues!.length; i++) {
        selectedVariations[index].add(false);
      }
    }
    return selectedVariations;
  }

  static List<bool> initializeCollapseVariation(
    List<FoodVariation>? foodVariations,
  ) {
    final List<bool> collapse = [];
    for (int index = 0; index < foodVariations!.length; index++) {
      collapse.add(true);
    }
    return collapse;
  }

  static List<int> initializeVariationIndexes(
    List<ChoiceOptions>? choiceOptions,
  ) {
    final List<int> variationIndex = [];
    for (int i = 0; i < choiceOptions!.length; i++) {
      variationIndex.add(0);
    }
    return variationIndex;
  }

  static List<bool> initializeAddonActiveList(List<AddOns>? addOns) {
    final List<bool> list = [];
    for (int i = 0; i < addOns!.length; i++) {
      list.add(false);
    }
    return list;
  }

  static List<int> initializeAddonQtyList(List<AddOns>? addOns) {
    final List<int> list = [];
    for (int i = 0; i < addOns!.length; i++) {
      list.add(1);
    }
    return list;
  }

  static String prepareVariationType(
    List<ChoiceOptions>? choiceOptions,
    List<int>? variationIndex,
  ) {
    String variationType = '';
    if (!ModuleHelper.getModuleConfig(
      ModuleHelper.getModule() != null
          ? ModuleHelper.getModule()!.moduleType
          : ModuleHelper.getCacheModule()!.moduleType,
    ).newVariation!) {
      final List<String> variationList = [];
      for (int index = 0; index < choiceOptions!.length; index++) {
        variationList.add(
          choiceOptions[index].options![variationIndex![index]].replaceAll(
            ' ',
            '',
          ),
        );
      }
      bool isFirst = true;
      for (var variation in variationList) {
        if (isFirst) {
          variationType = '$variationType$variation';
          isFirst = false;
        } else {
          variationType = '$variationType-$variation';
        }
      }
    }
    return variationType;
  }

  static int setAddOnQuantity(bool isIncrement, int addOnQty) {
    return isIncrement ? addOnQty + 1 : addOnQty - 1;
  }

  static int setQuantity(
    bool isIncrement,
    bool moduleStock,
    int? stock,
    int qty,
    int? quantityLimit, {
    bool getxSnackBar = false,
  }) {
    int quantity = qty;
    if (isIncrement) {
      if (moduleStock && quantity >= stock!) {
        showCustomSnackBar('out_of_stock'.tr);
      } else {
        if (quantityLimit != null) {
          if (quantity >= quantityLimit && quantityLimit != 0) {
            showCustomSnackBar(
              '${'maximum_quantity_limit'.tr} $quantityLimit',
              getXSnackBar: getxSnackBar,
            );
          } else {
            quantity = quantity + 1;
          }
        } else {
          quantity = quantity + 1;
        }
      }
    } else {
      quantity = quantity - 1;
    }
    return quantity;
  }

  static List<List<bool?>> setNewCartVariationIndex(
    int index,
    int i,
    List<FoodVariation>? foodVariations,
    List<List<bool?>> selectedVariations,
  ) {
    final List<List<bool?>> resultVariations = selectedVariations;
    if (!foodVariations![index].multiSelect!) {
      for (int j = 0; j < resultVariations[index].length; j++) {
        if (foodVariations[index].required!) {
          resultVariations[index][j] = j == i;
        } else {
          if (resultVariations[index][j]!) {
            resultVariations[index][j] = false;
          } else {
            resultVariations[index][j] = j == i;
          }
        }
      }
    } else {
      if (!resultVariations[index][i]! &&
          selectedVariationLength(resultVariations, index) >=
              foodVariations[index].max!) {
        showCustomSnackBar(
          '${'maximum_variation_for'.tr} ${foodVariations[index].name} ${'is'.tr} ${foodVariations[index].max}',
          getXSnackBar: true,
        );
      } else {
        resultVariations[index][i] = !resultVariations[index][i]!;
      }
    }
    return resultVariations;
  }

  static int selectedVariationLength(
    List<List<bool?>> selectedVariations,
    int index,
  ) {
    int length = 0;
    for (bool? isSelected in selectedVariations[index]) {
      if (isSelected!) {
        length++;
      }
    }
    return length;
  }

  // ── Navigation / direct add-to-cart (ported from legacy ItemController) ────

  /// True when the cart already holds items from a different store/module.
  static bool existAnotherStoreItem(int? storeId, int? moduleId) {
    final cartList = getIt<CartBloc>().state.cartList;
    for (var cart in cartList) {
      if (cart.item!.storeId != storeId || cart.item!.moduleId != moduleId) {
        return true;
      }
    }
    return false;
  }

  static void navigateToItemPage(
    Item? item,
    BuildContext context, {
    bool inStore = false,
    bool isCampaign = false,
  }) {
    if (Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .showRestaurantText! ||
        item!.moduleType == 'food') {
      ResponsiveHelper.isMobile(context)
          ? Get.bottomSheet(
              ItemBottomSheet(
                item: item,
                inStorePage: inStore,
                isCampaign: isCampaign,
              ),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            )
          : Get.dialog(
              Dialog(
                child: ItemBottomSheet(
                  item: item,
                  inStorePage: inStore,
                  isCampaign: isCampaign,
                ),
              ),
            );
    } else {
      Get.toNamed(
        RouteHelper.getItemDetailsRoute(item.id, inStore),
        arguments: ItemDetailsScreen(item: item, inStorePage: inStore),
      );
    }
  }

  static void itemDirectlyAddToCart(
    Item? item,
    BuildContext context, {
    bool inStore = false,
    bool isCampaign = false,
  }) {
    if (((item!.foodVariations != null && item.foodVariations!.isEmpty) &&
            item.moduleType == AppConstants.food) ||
        (item.variations != null &&
            item.variations!.isEmpty &&
            item.moduleType != AppConstants.food)) {
      final double price = item.price!;
      final double discount = item.discount!;
      final double discountPrice = PriceConverter.convertWithDiscount(
        price,
        discount,
        item.discountType,
      )!;

      final CartModel cartModel = CartModel(
        null,
        price,
        discount,
        [],
        [],
        (price - discountPrice),
        1,
        [],
        [],
        isCampaign,
        item.stock,
        item,
        item.quantityLimit,
      );

      final OnlineCart onlineCart = OnlineCart(
        null,
        isCampaign ? null : item.id,
        isCampaign ? item.id : null,
        price.toString(),
        '',
        null,
        ModuleHelper.getModuleConfig(item.moduleType).newVariation! ? [] : null,
        1,
        [],
        [],
        [],
        'Item',
      );
      if (Get.find<SplashController>()
              .configModel!
              .moduleConfig!
              .module!
              .stock! &&
          item.stock! <= 0) {
        showCustomSnackBar('out_of_stock'.tr);
      } else if (existAnotherStoreItem(
        cartModel.item!.storeId,
        ModuleHelper.getModule() != null
            ? ModuleHelper.getModule()?.id
            : ModuleHelper.getCacheModule()?.id,
      )) {
        Get.dialog(
          ConfirmationDialog(
            icon: Images.warning,
            title: 'are_you_sure_to_reset'.tr,
            description:
                Get.find<SplashController>()
                    .configModel!
                    .moduleConfig!
                    .module!
                    .showRestaurantText!
                ? 'if_you_continue'.tr
                : 'if_you_continue_without_another_store'.tr,
            onYesPressed: () {
              getIt<CartBloc>().add(const CartCleared());
              getIt<CartBloc>().add(CartOnlineSynced(onlineCart));
              Get.back();
              showCartSnackBar();
            },
          ),
          barrierDismissible: false,
        );
      } else {
        getIt<CartBloc>().add(CartOnlineSynced(onlineCart));
        showCartSnackBar();
      }
    } else if (Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .showRestaurantText! ||
        item.moduleType == AppConstants.food) {
      ResponsiveHelper.isMobile(context)
          ? Get.bottomSheet(
              ItemBottomSheet(
                item: item,
                inStorePage: inStore,
                isCampaign: isCampaign,
              ),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            )
          : Get.dialog(
              Dialog(
                child: ItemBottomSheet(
                  item: item,
                  inStorePage: inStore,
                  isCampaign: isCampaign,
                ),
              ),
            );
    } else {
      Get.toNamed(
        RouteHelper.getItemDetailsRoute(item.id, inStore),
        arguments: ItemDetailsScreen(item: item, inStorePage: inStore),
      );
    }
  }
}
