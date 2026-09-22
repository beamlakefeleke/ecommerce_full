import 'dart:convert';
import 'package:ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSource({required this.sharedPreferences});

  void addSharedPrefCartList(List<CartModel> cartProductList) {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<String> cartStringList = [];
    for(String cartString in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cartString));
      if(cartModel.item!.moduleId != _getModuleId()) {
        cartStringList.add(cartString);
      }
    }
    for(CartModel cartModel in cartProductList) {
      cartStringList.add(jsonEncode(cartModel.toJson()));
    }
    sharedPreferences.setStringList(AppConstants.cartList, cartStringList);
  }

  List<CartModel> getSharedPrefCartList() {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<CartModel> cartList = [];
    for(String cartString in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cartString));
      if(cartModel.item!.moduleId == _getModuleId()) {
        cartList.add(cartModel);
      }
    }
    return cartList;
  }

  int _getModuleId() {
    return ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id ?? 0;
  }
}
