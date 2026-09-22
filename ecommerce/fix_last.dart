import 'dart:io';

void replaceFiles() {
  // 1. menu_drawer.dart
  var file1 = File('lib/common/widgets/menu_drawer.dart');
  var content1 = file1.readAsStringSync();
  content1 = content1.replaceAll(
    'Get.find<CartController>().clearCartList();',
    'getIt<CartBloc>().add(ClearCartEvent());'
  );
  if (!content1.contains('CartBloc') && content1.contains('getIt<CartBloc>')) {
    content1 = content1.replaceFirst("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }
  file1.writeAsStringSync(content1);

  // 2. web_menu_bar.dart
  var file2 = File('lib/common/widgets/web_menu_bar.dart');
  var content2 = file2.readAsStringSync();
  content2 = content2.replaceAll('GetBuilder<CartController>(builder: (cartController) {', 'BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(), builder: (context, cartState) {');
  content2 = content2.replaceAll('cartController.cartList', 'cartState.cartList');
  if (!content2.contains('CartBloc') && content2.contains('getIt<CartBloc>')) {
    content2 = content2.replaceFirst("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }
  file2.writeAsStringSync(content2);

  // 3. sign_in_page.dart
  var file3 = File('lib/features/auth/presentation/pages/sign_in_page.dart');
  var content3 = file3.readAsStringSync();
  content3 = content3.replaceAll(
    'Get.find<CartController>().getCartDataOnline();',
    'getIt<CartBloc>().add(GetCartDataEvent());'
  );
  if (!content3.contains('CartBloc') && content3.contains('getIt<CartBloc>')) {
    content3 = content3.replaceFirst("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
  }
  file3.writeAsStringSync(content3);

  // 4. cart_item_widget.dart
  var file4 = File('lib/features/cart/widgets/cart_item_widget.dart');
  if(file4.existsSync()){
    var content4 = file4.readAsStringSync();
    content4 = content4.replaceAll('GetBuilder<CartController>(', 'BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(),');
    content4 = content4.replaceAll('builder: (cartController) {', 'builder: (context, cartState) {');
    content4 = content4.replaceAll('Get.find<CartController>().setQuantity(false, cartIndex, cart.stock, cart.quantityLimit);', 'getIt<CartBloc>().add(SetQuantityEvent(false, cartState.cartList[cartIndex], cartIndex, true));');
    content4 = content4.replaceAll('Get.find<CartController>().setQuantity(true, cartIndex, cart.stock, cart.quantityLimit);', 'getIt<CartBloc>().add(SetQuantityEvent(true, cartState.cartList[cartIndex], cartIndex, true));');
    if (!content4.contains('CartBloc') && content4.contains('getIt<CartBloc>')) {
        content4 = content4.replaceFirst("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
    }
    file4.writeAsStringSync(content4);
  }

  // 5. not_available_bottom_sheet_widget.dart
  var file5 = File('lib/features/cart/widgets/not_available_bottom_sheet_widget.dart');
  if(file5.existsSync()) {
    var content5 = file5.readAsStringSync();
    content5 = content5.replaceAll('GetBuilder<CartController>(', 'BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(),');
    content5 = content5.replaceAll('builder: (cartController) {', 'builder: (context, cartState) {');
    content5 = content5.replaceAll('cartController.setAvailableIndex(index)', 'getIt<CartBloc>().add(SetAvailableIndexEvent(index, true))');
    content5 = content5.replaceAll('cartController.notAvailableIndex', 'cartState.notAvailableIndex');
    content5 = content5.replaceAll('cartController.notAvailableList', 'cartState.notAvailableList');
    if (!content5.contains('CartBloc') && content5.contains('getIt<CartBloc>')) {
        content5 = content5.replaceFirst("import 'package:get/get.dart';", "import 'package:get/get.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';\nimport 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';\nimport 'package:ecommerce/core/di/injection.dart';");
    }
    file5.writeAsStringSync(content5);
  }
}

void main() {
  replaceFiles();
  print('Final fix complete.');
}
