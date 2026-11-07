import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/item/presentation/bloc/item_bloc.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final bool isExistInCart;
  final int cartIndex;
  final int? quantityLimit;
  final bool isLoading;
  const QuantityButton({
    super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cartIndex,
    this.isCartWidget = false,
    this.quantityLimit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading
          ? null
          : () {
              if (isExistInCart) {
                if (!isIncrement && quantity! > 1) {
                  context.read<CartBloc>().add(
                    CartItemQuantityUpdated(
                      isIncrement: false,
                      cartIndex: cartIndex,
                      stock: stock,
                      quantityLimit: quantityLimit,
                    ),
                  );
                } else if (isIncrement && quantity! > 0) {
                  if (quantity! < stock! ||
                      !Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .stock!) {
                    context.read<CartBloc>().add(
                      CartItemQuantityUpdated(
                        isIncrement: true,
                        cartIndex: cartIndex,
                        stock: stock,
                        quantityLimit: quantityLimit,
                      ),
                    );
                  } else {
                    showCustomSnackBar('out_of_stock'.tr);
                  }
                }
              } else {
                if (!isIncrement && quantity! > 1) {
                  context.read<ItemBloc>().add(
                    ItemQuantityChanged(
                      isIncrement: false,
                      stock: stock,
                      quantityLimit: quantityLimit,
                    ),
                  );
                } else if (isIncrement && quantity! > 0) {
                  if (quantity! < stock! ||
                      !Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .stock!) {
                    context.read<ItemBloc>().add(
                      ItemQuantityChanged(
                        isIncrement: true,
                        stock: stock,
                        quantityLimit: quantityLimit,
                      ),
                    );
                  } else {
                    showCustomSnackBar('out_of_stock'.tr);
                  }
                }
              }
            },
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (quantity! == 1 && !isIncrement) || isLoading
              ? Theme.of(context).disabledColor
              : Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement
                ? Colors.white
                : quantity! == 1
                ? Colors.black
                : Colors.white,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}
