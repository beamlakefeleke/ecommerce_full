import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';

class WebDeliveryInstructionView extends StatefulWidget {
  const WebDeliveryInstructionView({super.key});

  @override
  State<WebDeliveryInstructionView> createState() =>
      _WebDeliveryInstructionViewState();
}

class _WebDeliveryInstructionViewState
    extends State<WebDeliveryInstructionView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.20),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        child: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'add_more_delivery_instruction'.tr,
                      style: robotoMedium,
                    ),
                    IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        context.read<CheckoutBloc>().add(
                          const CheckoutExpandToggled(),
                        );
                      },
                      icon: Icon(
                        state.isExpand
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ),
                  ],
                ),

                !state.isExpand
                    ? const SizedBox()
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
                              childAspectRatio: 4,
                              crossAxisCount: 3,
                            ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: AppConstants.deliveryInstructionList.length,
                        itemBuilder: (context, index) {
                          bool isSelected = state.selectedInstruction == index;
                          return InkWell(
                            onTap: () {
                              context.read<CheckoutBloc>().add(
                                CheckoutInstructionSet(index),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.05)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.ac_unit,
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).disabledColor,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppConstants
                                          .deliveryInstructionList[index]
                                          .tr,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                !state.isExpand
                    ? const SizedBox()
                    : const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            );
          },
        ),
      ),
    );
  }
}
