import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:get/get.dart';

class NotAvailableBottomSheetWidget extends StatelessWidget {
  const NotAvailableBottomSheetWidget({super.key});

  // Static option list exposed for use in cart_screen's pricing view.
  static const List<String> options = [
    'remove_and_place_order',
    'wait_for_all_items',
    'cancel_order',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context)
            ? const BorderRadius.vertical(
                top: Radius.circular(Dimensions.radiusExtraLarge),
              )
            : const BorderRadius.all(
                Radius.circular(Dimensions.radiusExtraLarge),
              ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
        ),
        child: BlocBuilder<CartBloc, CartState>(
          buildWhen: (p, c) => p.notAvailableIndex != c.notAvailableIndex,
          builder: (context, state) {
            return Column(
              children: [
                if (!ResponsiveHelper.isDesktop(context))
                  Container(
                    height: 4,
                    width: 35,
                    margin: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'if_any_product_is_not_available'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final bool selected = state.notAvailableIndex == index;
                    return InkWell(
                      onTap: () => context.read<CartBloc>().add(
                        CartNotAvailableIndexSet(index),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusSmall,
                          ),
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor,
                            width: 0.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        margin: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeDefault,
                        ),
                        child: Text(
                          options[index].tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: selected
                                ? Theme.of(context).textTheme.bodyMedium!.color
                                : Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                CustomButton(
                  buttonText: 'apply'.tr,
                  onPressed: state.notAvailableIndex == -1
                      ? null
                      : () => Get.back(),
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
            );
          },
        ),
      ),
    );
  }
}
