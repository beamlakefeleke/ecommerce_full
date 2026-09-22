import 'dart:io';

void fixDetailsWebView(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  content = content.replaceAll(
    'GetBuilder<CartController>(\n                          builder: (cartController) {',
    'BlocBuilder<CartBloc, CartState>(\n                          bloc: getIt<CartBloc>(),\n                          builder: (context, cartState) {'
  );
  content = content.replaceAll(
    'GetBuilder<CartController>(\n                            builder: (cartController) {',
    'BlocBuilder<CartBloc, CartState>(\n                            bloc: getIt<CartBloc>(),\n                            builder: (context, cartState) {'
  );

  content = content.replaceAll('cartController: cartController,', '');
  content = content.replaceAll('cartController.existAnotherStoreItem', 'getIt<CartServiceInterface>().existAnotherStoreItem');
  content = content.replaceAll('Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id))', 'Get.find<SplashController>().cacheModule!.id : Get.find<SplashController>().module!.id), cartState.cartList)');
  content = content.replaceAll('cartController.clearCartOnline()', 'getIt<CartBloc>().clearCartOnline()');
  content = content.replaceAll('cartController.addToCartOnline(cart!)', 'getIt<CartBloc>().addToCartOnline(cart!)');
  content = content.replaceAll('cartController.updateCartOnline(cart!)', 'getIt<CartBloc>().updateCartOnline(cart!)');

  file.writeAsStringSync(content);
}

void main() {
  fixDetailsWebView('lib/features/item/widgets/details_web_view_widget.dart');
  print('Done');
}
