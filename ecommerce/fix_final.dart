import 'dart:io';

void replaceFiles() {
  // 1. web_cart_items_widget.dart
  var file1 = File('lib/features/cart/widgets/web_cart_items_widget.dart');
  var content1 = file1.readAsStringSync();
  content1 = content1.replaceAll('return  GetBuilder<CartController>(', 'return BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(),');
  content1 = content1.replaceAll('builder: (cartController) {', 'builder: (context, cartState) {');
  content1 = content1.replaceAll('cartController.addOnsList', 'cartState.addOnsList');
  content1 = content1.replaceAll('cartController.availableList', 'cartState.availableList');
  if (!content1.contains('getIt')) {
    content1 = content1.replaceAll("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }
  file1.writeAsStringSync(content1);

  // 2. web_suggested_item_view_widget.dart
  var file2 = File('lib/features/cart/widgets/web_suggested_item_view_widget.dart');
  var content2 = file2.readAsStringSync();
  content2 = content2.replaceAll('GetBuilder<CartController>(', 'BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(),');
  content2 = content2.replaceAll('builder: (cartController) {', 'builder: (context, cartState) {');
  content2 = content2.replaceAll('cartController.currentIndex', 'cartState.currentIndex');
  content2 = content2.replaceAll('cartController.setCurrentIndex', 'getIt<CartBloc>().add(SetCurrentIndexEvent'); // actually SetCurrentIndexEvent doesn't exist yet but we'll see
  if (!content2.contains('getIt')) {
    content2 = content2.replaceAll("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }
  file2.writeAsStringSync(content2);

  // 3. item_bottom_sheet.dart
  var file3 = File('lib/common/widgets/item_bottom_sheet.dart');
  var content3 = file3.readAsStringSync();
  content3 = content3.replaceAll('Expanded(child: GetBuilder<CartController>(', 'Expanded(child: BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(),');
  content3 = content3.replaceAll('builder: (cartController) {', 'builder: (context, cartState) {');
  content3 = content3.replaceAll(
    'cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList',
    'cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList'
  );
  content3 = content3.replaceAll(
    'getIt<CartServiceInterface>().existAnotherStoreItem(\n                                          cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList,',
    'getIt<CartServiceInterface>().existAnotherStoreItem(\n                                          cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList)'
  );
  file3.writeAsStringSync(content3);

  // 4. details_web_view_widget.dart
  var file4 = File('lib/features/item/widgets/details_web_view_widget.dart');
  var content4 = file4.readAsStringSync();
  content4 = content4.replaceAll('GetBuilder<CartController>(', 'BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(),');
  content4 = content4.replaceAll('builder: (cartController) {', 'builder: (context, cartState) {');
  content4 = content4.replaceAll('cartController: cartController,', '');
  content4 = content4.replaceAll(
    'getIt<CartServiceInterface>().existAnotherStoreItem(cartModel!.item!.storeId, Get.find<SplashController>().module!.id)',
    'getIt<CartServiceInterface>().existAnotherStoreItem(cartModel!.item!.storeId, Get.find<SplashController>().module!.id, getIt<CartBloc>().state.cartList)'
  );
  content4 = content4.replaceAll('CartModel? cartModel;', 'Cart? cartModel;'); // Fix type mismatch
  content4 = content4.replaceAll('CartModel cartModel = CartModel(', 'Cart cartModel = Cart(');
  if (!content4.contains('getIt')) {
    content4 = content4.replaceAll("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }
  file4.writeAsStringSync(content4);

  // 5. item_details_screen.dart (fix QuantityButton usage and CartModel usage)
  var file5 = File('lib/features/item/screens/item_details_screen.dart');
  var content5 = file5.readAsStringSync();
  content5 = content5.replaceAll('required this.cartController,', '');
  content5 = content5.replaceAll('final CartController cartController;', '');
  content5 = content5.replaceAll('this.cartController,', '');
  content5 = content5.replaceAll('cartController: cartController,', '');
  content5 = content5.replaceAll('CartModel? cartModel;', 'Cart? cartModel;');
  content5 = content5.replaceAll('CartModel cartModel = CartModel(', 'Cart cartModel = Cart(');
  content5 = content5.replaceAll(
    'cartModel!.item!.storeId, Get.find<SplashController>().module == null ? Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id)',
    'cartModel!.item!.storeId, Get.find<SplashController>().module == null ? Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id, getIt<CartBloc>().state.cartList)'
  );
  content5 = content5.replaceAll('getCartId(itemController.cartIndex)', 'getCartId(itemController.cartIndex, cartState.cartList)');
  file5.writeAsStringSync(content5);

}

void main() {
  replaceFiles();
  print('Done replacements');
}
