import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/checkout_balance_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/tips_widget.dart';

class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final double totalPrice;
  final Function(double x) onTotalChange;
  final int? storeId;
  final TextEditingController tipController;
  const DeliveryManTipsSection({
    super.key,
    required this.takeAway,
    required this.tooltipController3,
    required this.totalPrice,
    required this.onTotalChange,
    required this.tipController,
    this.storeId,
  });

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  bool canCheckSmall = false;

  @override
  Widget build(BuildContext context) {
    double total = widget.totalPrice;
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, checkoutController) {
        return Column(
          children: [
            (!widget.takeAway &&
                    Get.find<SplashController>().configModel!.dmTipsStatus == 1)
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeLarge,
                      horizontal: Dimensions.paddingSizeLarge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('delivery_man_tips'.tr, style: robotoMedium),

                            JustTheTooltip(
                              backgroundColor: Colors.black87,
                              controller: widget.tooltipController3,
                              preferredDirection: AxisDirection.right,
                              tailLength: 14,
                              tailBaseWidth: 20,
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'
                                      .tr,
                                  style: robotoRegular.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              child: InkWell(
                                onTap: () =>
                                    widget.tooltipController3.showTooltip(),
                                child: const Icon(Icons.info_outline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(
                          height:
                              (checkoutController.selectedTips ==
                                      AppConstants.tips.length - 1) &&
                                  checkoutController.canShowTipsField
                              ? 0
                              : ResponsiveHelper.isDesktop(context)
                              ? 80
                              : 60,
                          child:
                              (checkoutController.selectedTips ==
                                      AppConstants.tips.length - 1) &&
                                  checkoutController.canShowTipsField
                              ? const SizedBox()
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: AppConstants.tips.length,
                                  itemBuilder: (context, index) {
                                    return TipsWidget(
                                      title: AppConstants.tips[index] == '0'
                                          ? 'not_now'.tr
                                          : (index !=
                                                AppConstants.tips.length - 1)
                                          ? PriceConverter.convertPrice(
                                              double.parse(
                                                AppConstants.tips[index]
                                                    .toString(),
                                              ),
                                              forDM: true,
                                            )
                                          : AppConstants.tips[index].tr,
                                      isSelected:
                                          checkoutController.selectedTips ==
                                          index,
                                      isSuggested:
                                          index != 0 &&
                                          AppConstants.tips[index] ==
                                              checkoutController.mostDmTipAmount
                                                  .toString(),
                                      onTap: () async {
                                        final bool isLast =
                                            index ==
                                            AppConstants.tips.length - 1;
                                        final double newTip =
                                            (index == 0 || isLast)
                                            ? 0
                                            : double.parse(
                                                AppConstants.tips[index],
                                              );
                                        total = total - checkoutController.tips;
                                        context.read<CheckoutBloc>().add(
                                          CheckoutTipsIndexUpdated(index),
                                        );
                                        if (!isLast) {
                                          context.read<CheckoutBloc>().add(
                                            CheckoutTipsAmountChanged(
                                              double.parse(
                                                AppConstants.tips[index],
                                              ),
                                            ),
                                          );
                                        }
                                        if (isLast) {
                                          context.read<CheckoutBloc>().add(
                                            const CheckoutTipsFieldToggled(),
                                          );
                                        }
                                        widget.tipController.text = newTip
                                            .toString();

                                        if (checkoutController.isPartialPay ||
                                            checkoutController
                                                    .paymentMethodIndex ==
                                                1) {
                                          checkoutCheckBalanceStatus(
                                            context,
                                            (total + newTip),
                                            0,
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                        ),
                        SizedBox(
                          height:
                              (checkoutController.selectedTips ==
                                      AppConstants.tips.length - 1) &&
                                  checkoutController.canShowTipsField
                              ? Dimensions.paddingSizeExtraSmall
                              : 0,
                        ),

                        checkoutController.selectedTips ==
                                AppConstants.tips.length - 1
                            ? const SizedBox()
                            : ListTile(
                                onTap: () => context.read<CheckoutBloc>().add(
                                  const CheckoutDmTipSaveToggled(),
                                ),
                                leading: Checkbox(
                                  visualDensity: const VisualDensity(
                                    horizontal: -4,
                                    vertical: -4,
                                  ),
                                  activeColor: Theme.of(context).primaryColor,
                                  value: checkoutController.isDmTipSave,
                                  onChanged: (bool? isChecked) => context
                                      .read<CheckoutBloc>()
                                      .add(const CheckoutDmTipSaveToggled()),
                                ),
                                title: Text(
                                  'save_for_later'.tr,
                                  style: robotoMedium.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                dense: true,
                                horizontalTitleGap: 0,
                              ),
                        SizedBox(
                          height:
                              checkoutController.selectedTips ==
                                  AppConstants.tips.length - 1
                              ? Dimensions.paddingSizeDefault
                              : 0,
                        ),

                        checkoutController.selectedTips ==
                                AppConstants.tips.length - 1
                            ? Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      titleText: 'enter_amount'.tr,
                                      controller: widget.tipController,
                                      inputAction: TextInputAction.done,
                                      inputType: TextInputType.number,
                                      onChanged: (String value) async {
                                        if (value.isNotEmpty) {
                                          try {
                                            if (double.parse(value) >= 0) {
                                              if (AuthHelper.isLoggedIn()) {
                                                final double newTip =
                                                    double.parse(value);
                                                total =
                                                    total -
                                                    checkoutController.tips +
                                                    newTip;
                                                context
                                                    .read<CheckoutBloc>()
                                                    .add(
                                                      CheckoutTipsAmountChanged(
                                                        newTip,
                                                      ),
                                                    );
                                                widget.onTotalChange(total);
                                                if (Get.find<
                                                              ProfileController
                                                            >()
                                                            .userInfoModel!
                                                            .walletBalance! <
                                                        total &&
                                                    checkoutController
                                                            .paymentMethodIndex ==
                                                        1) {
                                                  checkoutCheckBalanceStatus(
                                                    context,
                                                    total,
                                                    0,
                                                  );
                                                  canCheckSmall = true;
                                                } else if (Get.find<
                                                              ProfileController
                                                            >()
                                                            .userInfoModel!
                                                            .walletBalance! >
                                                        total &&
                                                    canCheckSmall &&
                                                    checkoutController
                                                        .isPartialPay) {
                                                  checkoutCheckBalanceStatus(
                                                    context,
                                                    total,
                                                    0,
                                                  );
                                                }
                                              } else {
                                                context
                                                    .read<CheckoutBloc>()
                                                    .add(
                                                      CheckoutTipsAmountChanged(
                                                        double.parse(value),
                                                      ),
                                                    );
                                              }
                                            } else {
                                              showCustomSnackBar(
                                                'tips_can_not_be_negative'.tr,
                                              );
                                            }
                                          } catch (e) {
                                            showCustomSnackBar(
                                              'invalid_input'.tr,
                                            );
                                            context.read<CheckoutBloc>().add(
                                              const CheckoutTipsAmountChanged(
                                                0,
                                              ),
                                            );
                                            widget.tipController.text = widget
                                                .tipController
                                                .text
                                                .substring(
                                                  0,
                                                  widget
                                                          .tipController
                                                          .text
                                                          .length -
                                                      1,
                                                );
                                            widget.tipController.selection =
                                                TextSelection.collapsed(
                                                  offset: widget
                                                      .tipController
                                                      .text
                                                      .length,
                                                );
                                          }
                                        } else {
                                          context.read<CheckoutBloc>().add(
                                            const CheckoutTipsAmountChanged(0),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),

                                  InkWell(
                                    onTap: () {
                                      context.read<CheckoutBloc>().add(
                                        const CheckoutTipsIndexUpdated(0),
                                      );
                                      context.read<CheckoutBloc>().add(
                                        const CheckoutTipsFieldToggled(),
                                      );
                                      if (checkoutController.isPartialPay) {
                                        context.read<CheckoutBloc>().add(
                                          const CheckoutPartialPaymentToggled(),
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.5),
                                      ),
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeSmall,
                                      ),
                                      child: const Icon(Icons.clear),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),

            SizedBox(
              height:
                  (!widget.takeAway &&
                      widget.storeId == null &&
                      Get.find<SplashController>().configModel!.dmTipsStatus ==
                          1)
                  ? Dimensions.paddingSizeSmall
                  : 0,
            ),
          ],
        );
      },
    );
  }
}
