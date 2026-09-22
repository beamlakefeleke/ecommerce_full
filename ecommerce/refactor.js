const fs = require('fs');
const file = 'lib/features/cart/screens/cart_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// Imports
content = content.replace(/import 'package:ecommerce\/features\/cart\/controllers\/cart_controller.dart';/, 
  `import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';`);

// initCall logic
content = content.replace(/Future<void> initCall\(\) async {[\s\S]*?  }/, 
`void initCall() {
    final cartBloc = getIt<CartBloc>();
    if(cartBloc.state.cartList.isEmpty) {
      cartBloc.add(const GetCartDataEvent());
    }
    _loadStoreData(cartBloc.state.cartList);
  }

  void _loadStoreData(List<Cart> cartList) {
    if(cartList.isNotEmpty){
      Get.find<StoreController>().getCartStoreSuggestedItemList(cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: cartList[0].item!.storeId, name: null), false, fromCart: true);
    }
  }`);

// GetBuilder to BlocBuilder
content = content.replace(/GetBuilder<CartController>\(builder: \(cartController\) {/, 
  'BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(), builder: (context, cartState) {');

// cartController. to cartState.
content = content.replace(/cartController\.cartList/g, 'cartState.cartList');
content = content.replace(/cartController\.addOnsList/g, 'cartState.addOnsList');
content = content.replace(/cartController\.availableList/g, 'cartState.availableList');
content = content.replace(/cartController\.notAvailableList/g, 'cartState.notAvailableList');
content = content.replace(/cartController\.notAvailableIndex/g, 'cartState.notAvailableIndex');
content = content.replace(/cartController\.addCutlery/g, 'cartState.addCutlery');
content = content.replace(/cartController\.subTotal/g, 'cartState.subTotal');
content = content.replace(/cartController\.itemDiscountPrice/g, 'cartState.itemDiscountPrice');
content = content.replace(/cartController\.itemPrice/g, 'cartState.itemPrice');
content = content.replace(/cartController\.addOns/g, 'cartState.addOns');

// Method replacements
content = content.replace(/cartController\.forcefullySetModule\((.*?)\)/g, 'getIt<CartBloc>().add(ForcefullySetModuleEvent($1))');
content = content.replace(/cartController\.updateCutlery\(\)/g, 'getIt<CartBloc>().add(const UpdateCutleryEvent(true))');
content = content.replace(/cartController\.setAvailableIndex\((.*?)\)/g, 'getIt<CartBloc>().add(SetAvailableIndexEvent($1, true))');

// pricingView signature
content = content.replace(/Widget pricingView\(CartController cartController, Item item\)/, 
  'Widget pricingView(CartState cartState, Item item)');
content = content.replace(/pricingView\(cartController/g, 'pricingView(cartState');

// CheckoutButton
content = content.replace(/CheckoutButton\(cartController: cartController/, 'CheckoutButton(cartController: null /*TODO*/');

fs.writeFileSync(file, content);
