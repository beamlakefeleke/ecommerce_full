import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/controllers/store_controller.dart';
import 'package:ecommerce/common/models/config_model.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/features/checkout/widgets/slot_widget.dart';
class TimeSlotBottomSheet extends StatelessWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  const TimeSlotBottomSheet({super.key, required this.tomorrowClosed, required this.todayClosed, required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ?
          const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
          : const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          !ResponsiveHelper.isDesktop(context) ? InkWell(
            onTap: ()=> Get.back(),
            child: Container(
              height: 4, width: 35,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
            ),
          ) : const SizedBox(),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
              child: BlocBuilder<CheckoutBloc, CheckoutState>(
                  builder: (context, state) {
                    return GetBuilder<StoreController>(
                      builder: (storeController) {
                        return Column(mainAxisSize: MainAxisSize.min, children: [

                          Row(children: [
                            Expanded(
                              child: tobView(context:context, title: 'today'.tr, isSelected: state.selectedDateSlot == 0, onTap: (){
                                context.read<CheckoutBloc>().add(DateSlotSelected(index: 0, interval: Get.find<StoreController>().store!.orderPlaceToScheduleInterval));
                              }),
                            ),

                            Expanded(
                              child: tobView(context:context, title: 'tomorrow'.tr, isSelected: state.selectedDateSlot == 1, onTap: (){
                                context.read<CheckoutBloc>().add(DateSlotSelected(index: 1, interval: Get.find<StoreController>().store!.orderPlaceToScheduleInterval));
                              }),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          ((state.selectedDateSlot == 0 && todayClosed) || (state.selectedDateSlot == 1 && tomorrowClosed))
                            ? Center(child: Text(module!.showRestaurantText! ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr))
                              : state.timeSlots != null
                            ? state.timeSlots!.isNotEmpty ? GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: Dimensions.paddingSizeSmall,
                                crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
                                childAspectRatio: ResponsiveHelper.isDesktop(context) ? 4 : 3,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.timeSlots!.length,
                              itemBuilder: (context, index){
                                String time = (index == 0 && state.selectedDateSlot == 0
                                    && storeController.isStoreOpenNow(storeController.store!.active!, storeController.store!.schedules)
                                    && (Get.find<SplashController>().configModel!.moduleConfig!.module!.orderPlaceToScheduleInterval! ? storeController.store!.orderPlaceToScheduleInterval == 0 : true))
                                    ? 'instance'.tr : '${DateConverter.dateToTimeOnly(state.timeSlots![index].startTime!)} '
                                    '- ${DateConverter.dateToTimeOnly(state.timeSlots![index].endTime!)}';
                            return SlotWidget(
                              title: time,
                              isSelected: state.selectedTimeSlot == index,
                              onTap: () {
                                context.read<CheckoutBloc>().add(TimeSlotSelected(index: index));
                                context.read<CheckoutBloc>().add(PreferableTimeSet(time: time));
                              },
                            );
                          }) : Center(child: Text('no_slot_available'.tr)) : const Center(child: CircularProgressIndicator()),

                        ]);
                      }
                    );
                  }
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
              child: Row(children: [
                Expanded(
                  child: CustomButton(
                    radius: ResponsiveHelper.isDesktop(context) ?  Dimensions.radiusSmall : Dimensions.radiusDefault,
                    height: ResponsiveHelper.isDesktop(context) ? 50 : null,
                    isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                    buttonText: 'cancel'.tr,
                    color: Theme.of(context).disabledColor,
                    onPressed: () => Get.back(),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: CustomButton(
                    radius: ResponsiveHelper.isDesktop(context) ?  Dimensions.radiusSmall : Dimensions.radiusDefault,
                    height: ResponsiveHelper.isDesktop(context) ? 50 : null,
                    isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                    buttonText: 'schedule'.tr,
                    onPressed: () => Get.back(),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget tobView({required BuildContext context, required String title, required bool isSelected, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: isSelected ? robotoBold.copyWith(color: Theme.of(context).primaryColor) : robotoMedium),
          ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
          Divider(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, thickness: isSelected ? 2 : 1),
        ],
      ),
    );
  }
}
