import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/domain/services/cart_service_interface.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:get/get.dart';

import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';

class BottomCartWidget extends StatelessWidget {
  const BottomCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(), builder: (context, cartState) {
        return Container(
          height: GetPlatform.isIOS ? 100 : 70, width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge,/* vertical: Dimensions.PADDING_SIZE_SMALL*/),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: const Color(0xFF2A2A2A).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${'item'.tr}: ${cartState.cartList.length}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(children: [
                Text(
                  '${'total'.tr}: ',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),

                Text(
                  PriceConverter.convertPrice(cartState.subTotal),
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                ),
              ]),
            ]),

            CustomButton(buttonText: 'view_cart'.tr,width: 130,height: 45, onPressed: () => Get.toNamed(RouteHelper.getCartRoute()))
          ]),
        );
      });
  }
}
