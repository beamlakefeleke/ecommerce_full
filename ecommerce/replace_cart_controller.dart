import 'dart:io';

void replaceCartController(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  // Replace GetBuilder
  content = content.replaceAll(
    'GetBuilder<CartController>(\n                          builder: (cartController) {',
    'BlocBuilder<CartBloc, CartState>(\n                          bloc: getIt<CartBloc>(),\n                          builder: (context, cartState) {'
  );
  content = content.replaceAll(
    'GetBuilder<CartController>(\n                            builder: (cartController) {',
    'BlocBuilder<CartBloc, CartState>(\n                            bloc: getIt<CartBloc>(),\n                            builder: (context, cartState) {'
  );
  content = content.replaceAll(
    'GetBuilder<CartController>(builder: (cartController) {',
    'BlocBuilder<CartBloc, CartState>(\n      bloc: getIt<CartBloc>(),\n      builder: (context, cartState) {'
  );

  // General CartController references
  content = content.replaceAll('cartController.isLoading', 'cartState.isLoading');
  content = content.replaceAll('Get.find<CartController>().forcefullySetModule', 'getIt<CartBloc>().add(ForcefullySetModuleEvent');
  
  // existAnotherStoreItem
  content = content.replaceAll(
    'Get.find<CartController>().existAnotherStoreItem(',
    'getIt<CartServiceInterface>().existAnotherStoreItem('
  );
  content = content.replaceAll(
    'cartModel.item!.storeId, Get.find<SplashController>().module != null',
    'cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList'
  );

  // Online Cart methods
  content = content.replaceAll('Get.find<CartController>().clearCartOnline()', 'getIt<CartBloc>().clearCartOnline()');
  content = content.replaceAll('Get.find<CartController>().addToCartOnline(onlineCart)', 'getIt<CartBloc>().addToCartOnline(onlineCart)');
  content = content.replaceAll('Get.find<CartController>().updateCartOnline(onlineCart)', 'getIt<CartBloc>().updateCartOnline(onlineCart)');

  // Fix imports
  if (!content.contains('package:flutter_bloc/flutter_bloc.dart') && content.contains('CartBloc')) {
    content = content.replaceAll("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';\nimport 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }

  // Remove GetX imports for CartController if no longer used
  content = content.replaceAll("import 'package:ecommerce/features/cart/controllers/cart_controller.dart';", "");

  file.writeAsStringSync(content);
}

void main() {
  replaceCartController('lib/common/widgets/item_bottom_sheet.dart');
  print('Processed item_bottom_sheet.dart');
}
