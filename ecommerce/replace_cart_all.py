import os
import re

files_to_fix = [
    'lib/common/widgets/item_bottom_sheet.dart',
    'lib/common/widgets/menu_drawer.dart',
    'lib/common/widgets/web_menu_bar.dart',
    'lib/features/auth/presentation/pages/sign_in_page.dart',
    'lib/features/cart/widgets/cart_item_widget.dart',
    'lib/features/cart/widgets/not_available_bottom_sheet_widget.dart',
    'lib/features/cart/widgets/web_cart_items_widget.dart',
    'lib/features/cart/widgets/web_suggested_item_view_widget.dart',
    'lib/features/item/screens/item_details_screen.dart',
    'lib/features/item/widgets/details_web_view_widget.dart',
    'lib/features/store/widgets/bottom_cart_widget.dart'
]

for filepath in files_to_fix:
    if not os.path.exists(filepath):
        continue
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Replace GetBuilder with BlocBuilder
    content = re.sub(
        r'GetBuilder<CartController>\(\s*builder:\s*\(cartController\)\s*\{',
        r'BlocBuilder<CartBloc, CartState>(\nbloc: getIt<CartBloc>(),\nbuilder: (context, cartState) {',
        content, flags=re.MULTILINE
    )

    # 2. Replace cartController properties
    content = re.sub(r'cartController\.isLoading', r'cartState.isLoading', content)
    content = re.sub(r'cartController\.cartList', r'cartState.cartList', content)
    content = re.sub(r'cartController\.addCutlery', r'cartState.addCutlery', content)
    content = re.sub(r'cartController\.notAvailableIndex', r'cartState.notAvailableIndex', content)
    content = re.sub(r'cartController\.notAvailableList', r'cartState.notAvailableList', content)
    content = re.sub(r'cartController\.currentIndex', r'cartState.currentIndex', content)
    content = re.sub(r'cartController\.addOnsList', r'cartState.addOnsList', content)
    content = re.sub(r'cartController\.availableList', r'cartState.availableList', content)

    content = re.sub(r'cartController\.setAvailableIndex\((.*?)\)', r'getIt<CartBloc>().add(SetAvailableIndexEvent(\1, true))', content)
    content = re.sub(r'cartController\.setCurrentIndex\((.*?)\)', r'// TODO: setCurrentIndex', content)
    
    # calculationCart() was replaced by state.subTotal
    content = re.sub(r'cartController\.calculationCart\(\)', r'cartState.subTotal', content)

    # Get.find<CartController>() calls
    content = re.sub(r'Get\.find<CartController>\(\)\.cartList', r'getIt<CartBloc>().state.cartList', content)
    content = re.sub(r'Get\.find<CartController>\(\)\.clearCartList\(\)', r'getIt<CartBloc>().add(ClearCartEvent())', content)
    content = re.sub(r'Get\.find<CartController>\(\)\.getCartDataOnline\(\)', r'getIt<CartBloc>().add(GetCartDataEvent())', content)
    
    # cartController methods
    content = re.sub(
        r'Get\.find<CartController>\(\)\.setQuantity\((.*?),\s*(.*?),\s*(.*?),\s*(.*?)\)',
        r'getIt<CartBloc>().add(SetQuantityEvent(\1, getIt<CartBloc>().state.cartList[\2], \2, true))',
        content
    )
    content = re.sub(
        r'cartController\.setQuantity\((.*?),\s*(.*?),\s*(.*?),\s*(.*?)\)',
        r'getIt<CartBloc>().add(SetQuantityEvent(\1, cartState.cartList[\2], \2, true))',
        content
    )
    
    # forcefullySetModule
    content = re.sub(r'Get\.find<CartController>\(\)\.forcefullySetModule\((.*?)\)', r'getIt<CartBloc>().add(ForcefullySetModuleEvent(\1))', content)
    content = re.sub(r'cartController\.forcefullySetModule\((.*?)\)', r'getIt<CartBloc>().add(ForcefullySetModuleEvent(\1))', content)
    
    # cartController.removeFromCart
    content = re.sub(r'Get\.find<CartController>\(\)\.removeFromCart\((.*?),\s*item:\s*(.*?)\)', r'getIt<CartBloc>().add(RemoveFromCartEvent(\1, \2))', content)
    content = re.sub(r'cartController\.removeFromCart\((.*?)\)', r'getIt<CartBloc>().add(RemoveFromCartEvent(\1, null))', content)
    
    # clearCartOnline
    content = re.sub(r'cartController\.clearCartOnline\(\)', r'getIt<CartBloc>().clearCartOnline()', content)
    # addToCartOnline
    content = re.sub(r'cartController\.addToCartOnline\((.*?)\)', r'getIt<CartBloc>().addToCartOnline(\1)', content)
    # updateCartOnline
    content = re.sub(r'cartController\.updateCartOnline\((.*?)\)', r'getIt<CartBloc>().updateCartOnline(\1)', content)
    
    # existAnotherStoreItem
    content = re.sub(
        r'cartController\.existAnotherStoreItem\((.*?),\s*(.*?)\)',
        r'getIt<CartServiceInterface>().existAnotherStoreItem(\1, \2, cartState.cartList)',
        content
    )

    # getCartId
    content = re.sub(r'cartController\.getCartId\((.*?)\)', r'getIt<CartServiceInterface>().getCartId(\1, cartState.cartList)', content)
    
    # Fix explicitly passed cartController
    content = re.sub(r'final CartController cartController;', '', content)
    content = re.sub(r'required this\.cartController,', '', content)
    content = re.sub(r'cartController:\s*cartController,', '', content)
    content = re.sub(r'cartController:\s*Get\.find<CartController>\(\),', '', content)
    
    # Add imports
    if 'package:flutter_bloc/flutter_bloc.dart' not in content and ('CartBloc' in content or 'cartState' in content):
        imports = """
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';
import 'package:ecommerce/core/di/injection.dart';
"""
        content = content.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{imports}")
        
    # Remove CartController import
    content = content.replace("import 'package:ecommerce/features/cart/controllers/cart_controller.dart';", "")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print("Replacement done.")
