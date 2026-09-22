import 'dart:io';

void main() {
  final file = File('lib/features/cart/screens/cart_screen.dart');
  var content = file.readAsStringSync();
  
  // Replace variationPrice
  content = content.replaceAll('cartController.variationPrice', 'cartState.variationPrice');

  // Fix CheckoutButton invocation in pricingView
  content = content.replaceAll(
    'CheckoutButton(cartController: cartController, availableList: cartState.availableList)',
    'CheckoutButton(cartState: cartState, availableList: cartState.availableList)'
  );

  // Fix CheckoutButton invocation at the end of build method
  content = content.replaceAll(
    'CheckoutButton(cartController: null /*TODO*/, availableList: cartState.availableList)',
    'CheckoutButton(cartState: cartState, availableList: cartState.availableList)'
  );

  // Fix suggestedItemView signature
  content = content.replaceAll(
    'Widget suggestedItemView(List<CartModel> cartList){',
    'Widget suggestedItemView(List<Cart> cartList){'
  );
  
  content = content.replaceAll(
    'for (CartModel cartItem in cartList) {',
    'for (Cart cartItem in cartList) {'
  );

  file.writeAsStringSync(content);
  print('Fixed cart_screen.dart variables.');
}
