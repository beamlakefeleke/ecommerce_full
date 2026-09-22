import 'package:get/get_utils/get_utils.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/cart/domain/models/online_cart_model.dart';

import 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';
import 'package:ecommerce/features/cart/domain/entities/online_cart.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart' as item_variation;

class CartService implements CartServiceInterface {
  CartService();

  @override
  int availableSelectedIndex(int selectedIndex, int index) {
    int notAvailableIndex = selectedIndex;
    if(notAvailableIndex == index){
      notAvailableIndex = -1;
    }else {
      notAvailableIndex = index;
    }
    return notAvailableIndex;
  }

  @override
  ModuleModel? forcefullySetModule(ModuleModel? selectedModule, List<ModuleModel>? moduleList, int moduleId) {
    ModuleModel? module;
    if(selectedModule == null && moduleList != null){
      for(ModuleModel m in moduleList) {
        if(m.id == moduleId) {
          module = m;
          break;
        }
      }
    }
    return module;
  }

  @override
  List<AddOns> prepareAddonList(Cart cart) {
    List<AddOns> addOnList = [];
    for (var addOnId in cart.addOnIds!) {
      for(AddOns addOns in cart.item!.addOns!) {
        if(addOns.id == addOnId.id) {
          addOnList.add(addOns);
          break;
        }
      }
    }
    return addOnList;
  }

  @override
  double calculateAddonPrice(double addOns, List<AddOns> addOnList, Cart cart) {
    double addonPrice = addOns;
    for(int index=0; index<addOnList.length; index++) {
      addonPrice = addonPrice + (addOnList[index].price! * cart.addOnIds![index].quantity!);
    }
    return addonPrice;
  }

  @override
  double calculateVariationPrice(bool isFoodVariation, Cart cart, double? discount, String? discountType, double variationPrice) {
    double price = variationPrice;
    if(isFoodVariation) {
      for(int index = 0; index< cart.item!.foodVariations!.length; index++) {
        for(int i=0; i<cart.item!.foodVariations![index].variationValues!.length; i++) {
          if(cart.foodVariations![index][i]!) {
            price += (PriceConverter.convertWithDiscount(cart.item!.foodVariations![index].variationValues![i].optionPrice!, discount, discountType, isFoodVariation: true)! * cart.quantity!);
          }
        }
      }
    } else {

      String variationType = '';
      for(int i=0; i<cart.variation!.length; i++) {
        variationType = cart.variation![i].type!;
      }

      for (item_variation.Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          price = (PriceConverter.convertWithDiscount(variation.price!, discount, discountType)! * cart.quantity!);
          break;
        }
      }
    }
    return price;
  }

  @override
  double calculateVariationWithoutDiscountPrice(bool isFoodVariation, Cart cart, double variationWithoutDiscount) {
    double variationWithoutDiscountPrice = variationWithoutDiscount;
    if(!isFoodVariation) {
      String variationType = '';
      for(int i=0; i<cart.variation!.length; i++) {
        variationType = cart.variation![i].type!;
      }
      for (item_variation.Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          variationWithoutDiscountPrice = (variation.price! * cart.quantity!);
          break;
        }
      }
    } else {
      for(int index = 0; index< cart.item!.foodVariations!.length; index++) {
        for(int i=0; i<cart.item!.foodVariations![index].variationValues!.length; i++) {
          if(cart.foodVariations![index][i]!) {
            variationWithoutDiscountPrice += (cart.item!.foodVariations![index].variationValues![i].optionPrice! * cart.quantity!);
          }
        }
      }
    }
    return variationWithoutDiscountPrice;
  }

  @override
  bool checkVariation(bool isFoodVariation, Cart cart) {
    bool haveVariation = false;
    if(!isFoodVariation) {
      String variationType = '';
      for(int i=0; i<cart.variation!.length; i++) {
        variationType = cart.variation![i].type!;
      }
      for (item_variation.Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          haveVariation = true;
          break;
        }
      }
    }
    return haveVariation;
  }



  @override
  int? getCartId(int cartIndex, List<Cart> cartList) {
    if(cartIndex != -1) {
      return cartList[cartIndex].id;
    } else {
      return null;
    }
  }

  @override
  int decideItemQuantity(bool isIncrement, List<Cart> cartList, int cartIndex, int? stock, int ? quantityLimit, bool moduleStock) {
    int quantity = cartList[cartIndex].quantity!;
    if (isIncrement) {
      if(moduleStock && cartList[cartIndex].quantity! >= stock!) {
        showCustomSnackBar('out_of_stock'.tr);
      }else if(quantityLimit != null){
        if(quantity >= quantityLimit && quantityLimit != 0) {
          showCustomSnackBar('${'maximum_quantity_limit'.tr} $quantityLimit');
        } else {
          quantity = quantity + 1;
        }
      } else {
        quantity = quantity + 1;
      }
    } else {
      quantity = quantity - 1;
    }
    return quantity;
  }

  @override
  double calculateDiscountedPrice(Cart cart, int quantity, bool isFoodVariation) {
    double? discount = cart.item!.storeDiscount == 0 ? cart.item!.discount : cart.item!.storeDiscount;
    String? discountType = cart.item!.storeDiscount == 0 ? cart.item!.discountType : 'percent';
    double variationPrice = 0;
    double addonPrice = 0;

    if(isFoodVariation) {
      for(int index = 0; index< cart.item!.foodVariations!.length; index++) {
        for(int i=0; i<cart.item!.foodVariations![index].variationValues!.length; i++) {
          if(cart.foodVariations![index][i]!) {
            variationPrice += (PriceConverter.convertWithDiscount(cart.item!.foodVariations![index].variationValues![i].optionPrice!, discount, discountType, isFoodVariation: true)! * cart.quantity!);
          }
        }
      }

      List<AddOns> addOnList = [];
      for (var addOnId in cart.addOnIds!) {
        for(AddOns addOns in cart.item!.addOns!) {
          if(addOns.id == addOnId.id) {
            addOnList.add(addOns);
            break;
          }
        }
      }
      for(int index=0; index<addOnList.length; index++) {
        addonPrice = addonPrice + (addOnList[index].price! * cart.addOnIds![index].quantity!);
      }
    }
    double discountedPrice = addonPrice + variationPrice + (cart.item!.price! * quantity) - PriceConverter.calculation(cart.item!.price!, discount, discountType!, quantity);
    return discountedPrice;
  }

  @override
  List<Cart> formatOnlineCartToLocalCart({required List<OnlineCart> onlineCartModel}) {
    List<Cart> cartList = [];
    for (OnlineCart cart in onlineCartModel) {
      double price = cart.item!.price!;
      double? discount = cart.item!.storeDiscount == 0 ? cart.item!.discount! : cart.item!.storeDiscount!;
      String? discountType = (cart.item!.storeDiscount == 0) ? cart.item!.discountType : 'percent';
      double discountedPrice = PriceConverter.convertWithDiscount(price, discount, discountType)!;

      double? discountAmount = price - discountedPrice;
      int? quantity = cart.quantity;
      int? stock = cart.item!.stock ?? 0;

      List<List<bool?>> selectedFoodVariations = [];
      List<bool> collapsVariation = [];

      if(cart.item!.moduleType == 'food') {
        for(int index=0; index<cart.item!.foodVariations!.length; index++) {
          selectedFoodVariations.add([]);
          collapsVariation.add(true);
          for(int i=0; i < cart.item!.foodVariations![index].variationValues!.length; i++) {
            if(cart.item!.foodVariations![index].variationValues![i].isSelected ?? false){
              selectedFoodVariations[index].add(true);
            } else {
              selectedFoodVariations[index].add(false);
            }
          }
        }
      } else {
        String variationType = cart.productVariation != null && cart.productVariation!.isNotEmpty ? cart.productVariation![0].type! : '';
        for (item_variation.Variation variation in cart.item!.variations!) {
          if (variation.type == variationType) {
            discountedPrice = (PriceConverter.convertWithDiscount(variation.price!, discount, discountType)! * cart.quantity!);
            break;
          }
        }
      }

      List<CartAddOn> addOnIdList = [];
      List<AddOns> addOnsList = [];
      for (int index = 0; index < cart.addOnIds!.length; index++) {
        addOnIdList.add(CartAddOn(id: cart.addOnIds![index], quantity: cart.addOnQtys![index]));
        for (int i=0; i< cart.item!.addOns!.length; i++) {
          if(cart.addOnIds![index] == cart.item!.addOns![i].id) {
            addOnsList.add(AddOns(id: cart.item!.addOns![i].id, name: cart.item!.addOns![i].name, price: cart.item!.addOns![i].price));
          }
        }
      }

      int? quantityLimit = cart.item!.quantityLimit;

      cartList.add(
        Cart(
          id: cart.id,
          price: price,
          discountedPrice: discountedPrice,
          variation: cart.productVariation ?? [],
          foodVariations: selectedFoodVariations,
          discountAmount: discountAmount,
          quantity: quantity,
          addOnIds: addOnIdList,
          addOns: addOnsList,
          isCampaign: false,
          stock: stock,
          item: cart.item,
          quantityLimit: quantityLimit,
        ),
      );
    }

    return cartList;
  }

  @override
  int isExistInCart(List<Cart> cartList, int? itemID, String variationType, bool isUpdate, int? cartIndex) {
    for(int index=0; index<cartList.length; index++) {
      if(cartList[index].item!.id == itemID && (cartList[index].variation!.isNotEmpty
          ? cartList[index].variation![0].type == variationType : true)) {
        if((isUpdate && index == cartIndex)) {
          return -1;
        }else {
          return index;
        }
      }
    }
    return -1;
  }

  @override
  bool existAnotherStoreItem(int? storeID, int? moduleId, List<Cart> cartList) {
    for(Cart c in cartList) {
      if(c.item!.storeId != storeID && c.item!.moduleId == moduleId) {
        return true;
      }
    }
    return false;
  }

  @override
  int cartQuantity(int itemId, List<Cart> cartList) {
    int quantity = 0;
    for(Cart cart in cartList) {
      if(cart.item!.id == itemId) {
        quantity += cart.quantity!;
      }

    }
    return quantity;
  }

  @override
  String cartVariant(int itemId, List<Cart> cartList) {
    String variant = '';
    for(Cart cart in cartList) {
      if(cart.item!.id == itemId) {
        if(!ModuleHelper.getModuleConfig(cart.item!.moduleType).newVariation!) {
          variant = (cart.variation != null && cart.variation!.isNotEmpty) ? cart.variation![0].type! : '';
        }
      }
    }
    return variant;
  }

}





