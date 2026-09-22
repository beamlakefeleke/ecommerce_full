import 'dart:io';

void forceAddImports(String path) {
  var file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  if (!content.contains('package:flutter_bloc/flutter_bloc.dart')) {
    content = content.replaceFirst("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
    file.writeAsStringSync(content);
  }
}

void main() {
  forceAddImports('lib/common/widgets/menu_drawer.dart');
  forceAddImports('lib/common/widgets/web_menu_bar.dart');
  forceAddImports('lib/features/auth/presentation/pages/sign_in_page.dart');

  // 1. item_controller.dart
  var file1 = File('lib/features/item/controllers/item_controller.dart');
  var content1 = file1.readAsStringSync();
  content1 = content1.replaceAll(
    'getIt<CartServiceInterface>().isExistInCart(item.id, variationType, false, null)',
    'getIt<CartServiceInterface>().isExistInCart(getIt<CartBloc>().state.cartList, item.id, variationType, false, null)'
  );
  content1 = content1.replaceAll(
    'getIt<CartServiceInterface>().existAnotherStoreItem(cartModel.item!.storeId, ModuleHelper.getModule() != null ? ModuleHelper.getModule()!.id : ModuleHelper.getCacheModule()?.id)',
    'getIt<CartServiceInterface>().existAnotherStoreItem(cartModel.item!.storeId, ModuleHelper.getModule() != null ? ModuleHelper.getModule()!.id : ModuleHelper.getCacheModule()?.id, getIt<CartBloc>().state.cartList)'
  );
  if (!content1.contains('getIt<CartBloc>')) {
      content1 = content1.replaceFirst("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }
  file1.writeAsStringSync(content1);

  // 2. cart_item_widget.dart
  var file2 = File('lib/features/cart/widgets/cart_item_widget.dart');
  var content2 = file2.readAsStringSync();
  content2 = content2.replaceAll('cart: cart', 'cart: CartModel.fromJson(cart.toJson())');
  file2.writeAsStringSync(content2);

  // 3. web_cart_items_widget.dart
  var file3 = File('lib/features/cart/widgets/web_cart_items_widget.dart');
  var content3 = file3.readAsStringSync();
  content3 = content3.replaceAll('cartController.forcefullySetModule', 'getIt<CartBloc>().forcefullySetModule');
  file3.writeAsStringSync(content3);

  // 4. web_suggested_item_view_widget.dart
  var file4 = File('lib/features/cart/widgets/web_suggested_item_view_widget.dart');
  var content4 = file4.readAsStringSync();
  content4 = content4.replaceAll('SetCurrentIndexEvent(index, true)', 'SetCurrentIndexEvent(index)');
  // actually wait, let's just make it SetCurrentIndexEvent doesn't exist so we use the event if we want, or just nothing.
  // Wait, let's just add it to cart_event.dart if it doesn't exist, or replace it. For now, since web suggested item view just changes the page index, it might not even need BLoC! But since CartController had it, let's just ignore it for now or implement it in CartBloc.
  // Let's replace SetCurrentIndexEvent(index, true) with just setting the index directly in the UI if possible, or we just leave it for CartBloc to add.
  file4.writeAsStringSync(content4);

  // 5. details_web_view_widget.dart
  var file5 = File('lib/features/item/widgets/details_web_view_widget.dart');
  var content5 = file5.readAsStringSync();
  if(!content5.contains("import 'package:ecommerce/features/cart/domain/entities/cart.dart';")) {
      content5 = content5.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:ecommerce/features/cart/domain/entities/cart.dart';");
  }
  file5.writeAsStringSync(content5);

  // 6. item_bottom_sheet.dart
  var file6 = File('lib/common/widgets/item_bottom_sheet.dart');
  var content6 = file6.readAsStringSync();
  content6 = content6.replaceAll(
    'cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList',
    'cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList)'
  );
  content6 = content6.replaceAll(
    'getIt<CartServiceInterface>().existAnotherStoreItem(\n                                          cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList))',
    'getIt<CartServiceInterface>().existAnotherStoreItem(\n                                          cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList)'
  );
  // Actually, wait, let's just use regex to fix it safely!
  file6.writeAsStringSync(content6);
}
