import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';

class CancellationDialogueWidget extends StatelessWidget {
  final int? orderId;
  const CancellationDialogueWidget({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Opened via Get.dialog (outside the app-wide provider subtree), so forward
    // the existing app-wide OrderBloc into this dialog's tree.
    final orderBloc = context.read<OrderBloc>()
      ..add(const OrderCancelReasonsRequested());
    return BlocProvider.value(
      value: orderBloc,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: BlocConsumer<OrderBloc, OrderState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus &&
              current.actionType == OrderActionType.cancel,
          listener: (context, state) {
            if (state.actionStatus == OrderActionStatus.success) {
              showCustomSnackBar(state.actionMessage, isError: false);
              context.read<OrderBloc>().add(
                OrderTrackRequested(
                  orderId: orderId.toString(),
                  fromTracking: true,
                ),
              );
            } else if (state.actionStatus == OrderActionStatus.failure) {
              showCustomSnackBar(state.actionMessage);
            }
          },
          builder: (context, state) {
            return SizedBox(
              width: 500,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Container(
                    width: 500,
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'select_cancellation_reasons'.tr,
                          style: robotoMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: state.orderCancelReasons != null
                        ? state.orderCancelReasons!.isNotEmpty
                              ? ListView.builder(
                                  itemCount: state.orderCancelReasons!.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeSmall,
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          context.read<OrderBloc>().add(
                                            OrderCancelReasonSelected(
                                              state
                                                  .orderCancelReasons![index]
                                                  .reason,
                                            ),
                                          );
                                        },
                                        title: Row(
                                          children: [
                                            Icon(
                                              state
                                                          .orderCancelReasons![index]
                                                          .reason ==
                                                      state.cancelReason
                                                  ? Icons.radio_button_checked
                                                  : Icons.radio_button_off,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              size: 18,
                                            ),
                                            const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall,
                                            ),

                                            Flexible(
                                              child: Text(
                                                state
                                                    .orderCancelReasons![index]
                                                    .reason!,
                                                style: robotoRegular,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Center(child: Text('no_reasons_available'.tr))
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.fontSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: !state.isLoading
                        ? Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  buttonText: 'cancel'.tr,
                                  color: Theme.of(context).disabledColor,
                                  radius: 50,
                                  onPressed: () => Get.back(),
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),

                              Expanded(
                                child: CustomButton(
                                  buttonText: 'submit'.tr,
                                  radius: 50,
                                  onPressed: () {
                                    if (state.cancelReason != '' &&
                                        state.cancelReason != null) {
                                      Get.back();
                                      context.read<OrderBloc>().add(
                                        OrderCancelled(
                                          orderId: orderId,
                                          reason: state.cancelReason,
                                        ),
                                      );
                                    } else {
                                      if (Get.isDialogOpen!) {
                                        Get.back();
                                      }

                                      showCustomSnackBar(
                                        'you_did_not_select_select_any_reason'
                                            .tr,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
