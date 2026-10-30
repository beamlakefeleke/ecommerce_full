import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce/features/cart/data/models/cart_model.dart';
import 'package:ecommerce/helper/module_helper.dart';
import 'package:ecommerce/util/app_constants.dart';

abstract class CartLocalDataSource {
  Future<void> saveCartList(List<CartModel> cartList);
  List<CartModel> loadCartList();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveCartList(List<CartModel> cartList) async {
    final List<String> carts =
        sharedPreferences.getStringList(AppConstants.cartList) ?? [];

    // Keep items from other modules, replace items for the current module
    final int? currentModuleId =
        ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.id;
    final List<String> kept = carts.where((s) {
      final CartModel m = CartModel.fromJson(jsonDecode(s));
      return m.item?.moduleId != currentModuleId;
    }).toList();

    for (final CartModel m in cartList) {
      kept.add(jsonEncode(m.toJson()));
    }
    await sharedPreferences.setStringList(AppConstants.cartList, kept);
  }

  @override
  List<CartModel> loadCartList() {
    final List<String> carts =
        sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    return carts.map((s) => CartModel.fromJson(jsonDecode(s))).toList();
  }
}
