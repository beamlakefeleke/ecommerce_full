import 'dart:io';

void replaceGetBuilder(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  content = content.replaceAll(
    'GetBuilder<CartController>(\n      builder: (cartController)',
    'BlocBuilder<CartBloc, CartState>(\n      bloc: getIt<CartBloc>(),\n      builder: (context, cartState)'
  );
  content = content.replaceAll(
    'GetBuilder<CartController>(\n                          builder: (cartController)',
    'BlocBuilder<CartBloc, CartState>(\n                          bloc: getIt<CartBloc>(),\n                          builder: (context, cartState)'
  );
  content = content.replaceAll(
    'GetBuilder<CartController>(\n                  builder: (cartController)',
    'BlocBuilder<CartBloc, CartState>(\n                  bloc: getIt<CartBloc>(),\n                  builder: (context, cartState)'
  );
  
  content = content.replaceAll('cartController.getCartId', 'getIt<CartServiceInterface>().getCartId');
  
  content = content.replaceAll(
    'cartController.setQuantity(false, itemController.cartIndex, stock, cartState.cartList[itemController.cartIndex].quantity)',
    'getIt<CartBloc>().add(SetQuantityEvent(false, cartState.cartList[itemController.cartIndex], itemController.cartIndex, true))'
  );
  content = content.replaceAll(
    'cartController.setQuantity(true, itemController.cartIndex, stock, cartState.cartList[itemController.cartIndex].quantityLimit)',
    'getIt<CartBloc>().add(SetQuantityEvent(true, cartState.cartList[itemController.cartIndex], itemController.cartIndex, true))'
  );
  
  content = content.replaceAll(
    'cartController.existAnotherStoreItem',
    'getIt<CartServiceInterface>().existAnotherStoreItem'
  );
  content = content.replaceAll(
    'Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id))',
    'Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id), cartState.cartList)'
  );
  
  content = content.replaceAll('cartController.clearCartOnline()', 'getIt<CartBloc>().clearCartOnline()');
  content = content.replaceAll('cartController.addToCartOnline(cart!)', 'getIt<CartBloc>().addToCartOnline(cart!)');
  content = content.replaceAll('cartController.updateCartOnline(cart!)', 'getIt<CartBloc>().updateCartOnline(cart!)');

  file.writeAsStringSync(content);
}

void main() {
  replaceGetBuilder('lib/features/item/screens/item_details_screen.dart');
  print('Done');
}
