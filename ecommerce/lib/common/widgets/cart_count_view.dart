import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/item/controllers/item_controller.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
class CartCountView extends StatelessWidget {
  final Item item;
  final Widget? child;
  const CartCountView({super.key, required this.item, this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      bloc: getIt<CartBloc>(),
      builder: (context, cartState) {
        final cartService = getIt<CartServiceInterface>();
        int cartQty = cartService.cartQuantity(item.id!, cartState.cartList);
        int cartIndex = cartService.isExistInCart(cartState.cartList, item.id, cartService.cartVariant(item.id!, cartState.cartList), false, null);
      return cartQty != 0 ? Center(
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
              onTap: cartState.isLoading ? null : () {
                if (cartState.cartList[cartIndex].quantity! > 1) {
                  getIt<CartBloc>().add(SetQuantityEvent(false, cartState.cartList[cartIndex], cartIndex, true));
                } else {
                  getIt<CartBloc>().add(RemoveFromCartEvent(cartIndex, cartState.cartList[cartIndex].item));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.remove, size: 16, color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: !cartState.isLoading ? Text(
                cartQty.toString(),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
              ) : SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Theme.of(context).cardColor)),
            ),

            InkWell(
              onTap: cartState.isLoading ? null : () {
                getIt<CartBloc>().add(SetQuantityEvent(true, cartState.cartList[cartIndex], cartIndex, true));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.add, size: 16, color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ]),
        ),
      ) : InkWell(
        onTap: () {
          Get.find<ItemController>().itemDirectlyAddToCart(item, context);
        },
        child: child ?? Container(
          height: 25, width: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]
          ),
          child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
        ),
      );
    });
  }
}
