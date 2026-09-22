import 'dart:io';

void replaceCartControllerInFile(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) {
    print('File not found: $filePath');
    return;
  }
  var content = file.readAsStringSync();

  // Basic UI bloc builder replacements
  content = content.replaceAll(
    'GetBuilder<CartController>(builder: (cartController)',
    'BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(), builder: (context, cartState)'
  );
  content = content.replaceAll(
    'GetBuilder<CartController>(\n      builder: (cartController) {',
    'BlocBuilder<CartBloc, CartState>(\n      bloc: getIt<CartBloc>(),\n      builder: (context, cartState) {'
  );
  content = content.replaceAll(
    'GetBuilder<CartController>(\n        builder: (cartController) {',
    'BlocBuilder<CartBloc, CartState>(\n        bloc: getIt<CartBloc>(),\n        builder: (context, cartState) {'
  );
  content = content.replaceAll(
    'GetBuilder<CartController>(\n                          builder: (cartController) {',
    'BlocBuilder<CartBloc, CartState>(\n                          bloc: getIt<CartBloc>(),\n                          builder: (context, cartState) {'
  );

  // State property replacements
  content = content.replaceAll('cartController.isLoading', 'cartState.isLoading');
  content = content.replaceAll('cartController.cartList', 'cartState.cartList');
  content = content.replaceAll('cartController.addCutlery', 'cartState.addCutlery');
  content = content.replaceAll('cartController.notAvailableIndex', 'cartState.notAvailableIndex');
  content = content.replaceAll('cartController.notAvailableList', 'cartState.notAvailableList');

  // getIt<CartBloc>().state properties
  content = content.replaceAll('Get.find<CartController>().cartList', 'getIt<CartBloc>().state.cartList');
  content = content.replaceAll('Get.find<CartController>().addCutlery', 'getIt<CartBloc>().state.addCutlery');
  content = content.replaceAll('Get.find<CartController>().notAvailableIndex', 'getIt<CartBloc>().state.notAvailableIndex');
  content = content.replaceAll('Get.find<CartController>().notAvailableList', 'getIt<CartBloc>().state.notAvailableList');
  
  // Method replacements via BLoC Event
  content = content.replaceAll('Get.find<CartController>().clearCartList()', 'getIt<CartBloc>().add(ClearCartEvent())');
  content = content.replaceAll('Get.find<CartController>().getCartDataOnline()', 'getIt<CartBloc>().add(GetCartDataEvent())');
  content = content.replaceAll('Get.find<CartController>().forcefullySetModule', 'getIt<CartBloc>().add(ForcefullySetModuleEvent');

  // Method replacements via Async Bloc Methods
  content = content.replaceAll('Get.find<CartController>().clearCartOnline()', 'getIt<CartBloc>().clearCartOnline()');
  content = content.replaceAll('Get.find<CartController>().addToCartOnline', 'getIt<CartBloc>().addToCartOnline');
  content = content.replaceAll('Get.find<CartController>().updateCartOnline', 'getIt<CartBloc>().updateCartOnline');

  // Service Interface Replacements
  content = content.replaceAll(
    'Get.find<CartController>().existAnotherStoreItem(',
    'getIt<CartServiceInterface>().existAnotherStoreItem('
  );
  content = content.replaceAll(
    'cartModel.item!.storeId, Get.find<SplashController>().module != null',
    'cartModel.item!.storeId, Get.find<SplashController>().module != null ? Get.find<SplashController>().module!.id : Get.find<SplashController>().cacheModule!.id, getIt<CartBloc>().state.cartList'
  );

  content = content.replaceAll(
    'Get.find<CartController>().cartQuantity(',
    'getIt<CartServiceInterface>().cartQuantity('
  );
  content = content.replaceAll(
    'Get.find<CartController>().isExistInCart(',
    'getIt<CartServiceInterface>().isExistInCart('
  );
  
  // In details_web_view_widget etc
  content = content.replaceAll(
    'Get.find<CartController>().setQuantity(false, cartIndex, stock, quantityLimit)',
    'getIt<CartBloc>().add(SetQuantityEvent(false, getIt<CartBloc>().state.cartList[cartIndex], cartIndex, true))'
  );
  content = content.replaceAll(
    'Get.find<CartController>().setQuantity(true, cartIndex, stock, quantityLimit)',
    'getIt<CartBloc>().add(SetQuantityEvent(true, getIt<CartBloc>().state.cartList[cartIndex], cartIndex, true))'
  );
  content = content.replaceAll(
    'Get.find<CartController>().removeFromCart(cartIndex, item: cart.item)',
    'getIt<CartBloc>().add(RemoveFromCartEvent(cartIndex, cart.item))'
  );
  content = content.replaceAll(
    'Get.find<CartController>().removeFromCart(cartIndex)',
    'getIt<CartBloc>().add(RemoveFromCartEvent(cartIndex, null))'
  );

  // Fix imports
  if (!content.contains('package:flutter_bloc/flutter_bloc.dart') && content.contains('CartBloc')) {
    content = content.replaceAll("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';\nimport 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }

  // Remove GetX imports for CartController if no longer used
  content = content.replaceAll("import 'package:ecommerce/features/cart/controllers/cart_controller.dart';", "");

  file.writeAsStringSync(content);
  print('Processed $filePath');
}

void main() {
  final files = [
    'lib/common/widgets/item_bottom_sheet.dart',
    'lib/features/cart/widgets/not_available_bottom_sheet_widget.dart',
    'lib/features/cart/widgets/web_suggested_item_view_widget.dart',
    'lib/features/cart/widgets/web_cart_items_widget.dart',
    'lib/features/cart/widgets/cart_item_widget.dart',
    'lib/features/item/widgets/details_web_view_widget.dart',
    'lib/features/item/widgets/details_app_bar_widget.dart',
    'lib/features/item/screens/item_details_screen.dart',
    'lib/features/store/widgets/bottom_cart_widget.dart',
    'lib/features/store/screens/store_item_search_screen.dart',
    'lib/features/store/screens/store_screen.dart',
    'lib/features/search/screens/search_screen.dart',
    'lib/features/item/controllers/item_controller.dart',
    'lib/features/checkout/screens/checkout_screen.dart',
    'lib/features/checkout/controllers/checkout_controller.dart',
    'lib/features/splash/screens/splash_screen.dart',
    'lib/features/splash/controllers/splash_controller.dart',
    'lib/features/location/controllers/location_controller.dart',
    'lib/features/menu/widgets/menu_button_widget.dart',
    'lib/main.dart'
  ];

  for (final file in files) {
    replaceCartControllerInFile(file);
  }
}
