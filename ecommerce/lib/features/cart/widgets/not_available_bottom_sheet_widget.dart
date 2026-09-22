import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/core/di/injection.dart';

import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
class NotAvailableBottomSheetWidget extends StatelessWidget {
  const NotAvailableBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
        child: Column(children: [
          !ResponsiveHelper.isDesktop(context) ? Container(
            height: 4, width: 35,
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
          ) : const SizedBox(),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('if_any_product_is_not_available'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            IconButton(
              onPressed: ()=> Get.back(),
              icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
            )
          ]),

          BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(),
            builder: (context, cartState) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartState.notAvailableList.length,
                  itemBuilder: (context, index){
                return InkWell(
                  onTap: () => getIt<CartBloc>().add(SetAvailableIndexEvent(index, true)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cartState.notAvailableIndex == index ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: cartState.notAvailableIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                    margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: Text(
                      cartState.notAvailableList[index].tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: cartState.notAvailableIndex == index ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).disabledColor),
                    ),
                  ),
                );
              });
            }
          ),

          BlocBuilder<CartBloc, CartState>(bloc: getIt<CartBloc>(),
            builder: (context, cartState) {
              return CustomButton(
                buttonText: 'apply'.tr,
                onPressed: cartState.notAvailableIndex == -1 ? null : (){
                 Get.back();
                },
              );
            }
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge)
        ]),
      ),
    );
  }
}
