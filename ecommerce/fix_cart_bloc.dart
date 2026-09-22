import 'dart:io';

void fixCartBlocOnlineCart(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  content = content.replaceAll(
    'Future<bool> addToCartOnline(OnlineCart cart) async {',
    'Future<bool> addToCartOnline(dynamic cartModel) async {\n    // Map dynamic model to entity\n    final cart = OnlineCart(\n      id: cartModel.cartId,\n      itemId: cartModel.itemId,\n      price: cartModel.price,\n      foodVariation: null, // map if needed\n      quantity: cartModel.quantity,\n      addOnIds: cartModel.addOnIds,\n      addOnQtys: cartModel.addOnQtys,\n      itemType: cartModel.itemType,\n    );'
  );
  
  content = content.replaceAll(
    'Future<bool> updateCartOnline(OnlineCart cart) async {',
    'Future<bool> updateCartOnline(dynamic cart) async {'
  );

  content = content.replaceAll(
    'final result = await updateCartOnlineUseCase((cart as OnlineCartModel).toJson());',
    'final result = await updateCartOnlineUseCase(cart.toJson());'
  );

  file.writeAsStringSync(content);
}

void main() {
  fixCartBlocOnlineCart('lib/features/cart/presentation/bloc/cart_bloc.dart');
}
