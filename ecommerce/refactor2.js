const fs = require('fs');
const file = 'lib/features/cart/screens/cart_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// Fix CheckoutButton
content = content.replace(/class CheckoutButton extends StatelessWidget {[\s\S]*?const CheckoutButton\({super\.key, required this\.cartController, required this\.availableList}\);/, 
  `class CheckoutButton extends StatelessWidget {
  final CartState cartState;
  final List<bool> availableList;
  const CheckoutButton({super.key, required this.cartState, required this.availableList});`);

content = content.replace(/CheckoutButton\(cartController: null \/\*TODO\*\//, 'CheckoutButton(cartState: cartState');

fs.writeFileSync(file, content);
