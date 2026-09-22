import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';

class DeliveryInstructionView extends StatefulWidget {
  const DeliveryInstructionView({super.key});

  @override
  State<DeliveryInstructionView> createState() => _DeliveryInstructionViewState();
}

class _DeliveryInstructionViewState extends State<DeliveryInstructionView> {
  ExpansionTileController controller = ExpansionTileController();

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: widget.key,
                controller: controller,
                title: Text('add_more_delivery_instruction'.tr, style: robotoMedium),
                trailing: Icon(state.isExpanded ? Icons.remove : Icons.add, size: 18),
                tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                onExpansionChanged: (value) => context.read<CheckoutBloc>().add(const ExpandToggled()),

                children: [

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: AppConstants.deliveryInstructionList.length,
                      itemBuilder: (context, index){
                      bool isSelected = state.selectedInstruction == index;
                    return InkWell(
                      onTap: () {
                        context.read<CheckoutBloc>().add(InstructionSelected(index: index));
                        if(controller.isExpanded) {
                          controller.collapse();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
                        ),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        child: Row(children: [
                          Icon(Icons.ac_unit, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, size: 18),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: Text(
                              AppConstants.deliveryInstructionList[index].tr,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                            ),
                          ),
                        ]),

                      ),
                    );
                  }),
                ],
              ),
            ),

            state.selectedInstruction != -1 ? Padding(
              padding:  EdgeInsets.symmetric(vertical: state.isExpanded ? Dimensions.paddingSizeSmall : 0),
              child: Row(children: [
                Text(
                  AppConstants.deliveryInstructionList[state.selectedInstruction].tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                ),

                InkWell(
                  onTap: ()=> context.read<CheckoutBloc>().add(const InstructionSelected(index: -1)),
                  child: const Icon(Icons.clear, size: 16),
                ),
              ])
            ) : const SizedBox(),

          ]);
        }
      ),
    );
  }
}
