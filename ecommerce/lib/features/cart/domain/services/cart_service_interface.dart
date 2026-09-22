import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/cart/domain/entities/cart.dart';
import 'package:ecommerce/features/cart/domain/models/online_cart_model.dart';
import 'package:ecommerce/features/cart/domain/entities/online_cart.dart';

abstract class CartServiceInterface {
  int availableSelectedIndex(int selectedIndex, int index);
  ModuleModel? forcefullySetModule(ModuleModel? module, List<ModuleModel>? moduleList, int moduleId);
  List<AddOns> prepareAddonList(Cart cart);
  double calculateAddonPrice(double addOns, List<AddOns> addOnList, Cart cart);
  double calculateVariationPrice(bool isFoodVariation, Cart cart, double? discount, String? discountType, double variationPrice);
  double calculateVariationWithoutDiscountPrice(bool isFoodVariation, Cart cart, double variationWithoutDiscount);
  bool checkVariation(bool isFoodVariation, Cart cart);
  int? getCartId(int cartIndex, List<Cart> cartList);
  int decideItemQuantity(bool isIncrement, List<Cart> cartList, int cartIndex, int? stock, int ? quantityLimit, bool moduleStock);
  double calculateDiscountedPrice(Cart cart, int quantity, bool isFoodVariation);
  List<Cart> formatOnlineCartToLocalCart({required List<OnlineCart> onlineCartModel});
  int isExistInCart(List<Cart> cartList, int? itemID, String variationType, bool isUpdate, int? cartIndex);
  bool existAnotherStoreItem(int? storeID, int? moduleId, List<Cart> cartList);
  int cartQuantity(int itemId, List<Cart> cartList);
  String cartVariant(int itemId, List<Cart> cartList);
}
