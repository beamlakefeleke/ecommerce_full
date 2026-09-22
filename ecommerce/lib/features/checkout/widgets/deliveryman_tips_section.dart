import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/features/checkout/widgets/tips_widget.dart';

class DeliveryManTipsSection extends StatefulWidget {
  final bool takeAway;
  final JustTheController tooltipController3;
  final double totalPrice;
  final Function(double x) onTotalChange;
  final int? storeId;
  final TextEditingController tipController;
  final Function(double, double)? onCheckBalanceStatus;
  const DeliveryManTipsSection({ super.key, required this.takeAway, required this.tooltipController3, required this.totalPrice, required this.onTotalChange, this.storeId, required this.tipController, this.onCheckBalanceStatus});

  @override
  State<DeliveryManTipsSection> createState() => _DeliveryManTipsSectionState();
}

class _DeliveryManTipsSectionState extends State<DeliveryManTipsSection> {
  bool canCheckSmall = false;

  @override
  Widget build(BuildContext context) {
    double total = widget.totalPrice;
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return Column(
          children: [
            (!widget.takeAway && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
              ),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge, horizontal: Dimensions.paddingSizeLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(children: [
                  Text('delivery_man_tips'.tr, style: robotoMedium),

                  JustTheTooltip(
                    backgroundColor: Colors.black87,
                    controller: widget.tooltipController3,
                    preferredDirection: AxisDirection.right,
                    tailLength: 14,
                    tailBaseWidth: 20,
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'.tr,style: robotoRegular.copyWith(color: Colors.white)),
                    ),
                    child: InkWell(
                      onTap: () => widget.tooltipController3.showTooltip(),
                      child: const Icon(Icons.info_outline),
                    ),
                  ),

                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                SizedBox(
                  height: (state.selectedTips == AppConstants.tips.length-1) && state.canShowTipsField
                      ? 0 : ResponsiveHelper.isDesktop(context) ? 80 : 60,
                  child: (state.selectedTips == AppConstants.tips.length-1) && state.canShowTipsField
                  ? const SizedBox() : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppConstants.tips.length,
                    itemBuilder: (context, index) {
                      return TipsWidget(
                        title: AppConstants.tips[index] == '0' ? 'not_now'.tr : (index != AppConstants.tips.length -1) ? PriceConverter.convertPrice(double.parse(AppConstants.tips[index].toString()), forDM: true) : AppConstants.tips[index].tr,
                        isSelected: state.selectedTips == index,
                        isSuggested: index != 0 && AppConstants.tips[index] == state.mostDmTipAmount.toString(),
                        onTap: () async {
                          total = total - state.tips;
                          context.read<CheckoutBloc>().add(TipUpdated(tipIndex: index));
                          if(state.selectedTips != AppConstants.tips.length-1) {
                            context.read<CheckoutBloc>().add(CustomTipSet(amount: double.parse(AppConstants.tips[index])));
                          }
                          if(state.selectedTips == AppConstants.tips.length-1) {
                            context.read<CheckoutBloc>().add(const TipsFieldToggled());
                          }
                          widget.tipController.text = state.tips.toString();

                          if(state.isPartialPay || state.paymentMethodIndex == 1) {

                            widget.onCheckBalanceStatus?.call((total + state.tips), 0);
                          }

                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: (state.selectedTips == AppConstants.tips.length-1) && state.canShowTipsField ? Dimensions.paddingSizeExtraSmall : 0),

                state.selectedTips == AppConstants.tips.length-1 ? const SizedBox() : ListTile(
                  onTap: () => context.read<CheckoutBloc>().add(const DmTipSaveToggled()),
                  leading: Checkbox(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    activeColor: Theme.of(context).primaryColor,
                    value: state.isDmTipSave,
                    onChanged: (bool? isChecked) => context.read<CheckoutBloc>().add(const DmTipSaveToggled()),
                  ),
                  title: Text('save_for_later'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  dense: true,
                  horizontalTitleGap: 0,
                ),
                SizedBox(height: state.selectedTips == AppConstants.tips.length-1 ? Dimensions.paddingSizeDefault : 0),

                state.selectedTips == AppConstants.tips.length-1 ? Row(children: [
                  Expanded(
                    child: CustomTextField(
                      titleText: 'enter_amount'.tr,
                      controller: widget.tipController,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.number,
                      onChanged: (String value) async {
                        if(value.isNotEmpty) {
                          try {
                            if(double.parse(value) >= 0){
                              if(AuthHelper.isLoggedIn()) {
                                total = total - state.tips;
                                context.read<CheckoutBloc>().add(CustomTipSet(amount: double.parse(value)));
                                total = total + state.tips; // Wait, state.tips will be updated eventually, maybe not immediately since add() is async.
                                widget.onTotalChange(total);
                                if(Get.find<ProfileController>().userInfoModel!.walletBalance! < total && state.paymentMethodIndex == 1){
                                  widget.onCheckBalanceStatus?.call(total, 0);
                                  canCheckSmall = true;
                                } else if(Get.find<ProfileController>().userInfoModel!.walletBalance! > total && canCheckSmall && state.isPartialPay){
                                  widget.onCheckBalanceStatus?.call(total, 0);
                                }
                              } else {
                                context.read<CheckoutBloc>().add(CustomTipSet(amount: double.parse(value)));
                              }

                            }else{
                              showCustomSnackBar('tips_can_not_be_negative'.tr);
                            }
                          }catch(e) {
                            showCustomSnackBar('invalid_input'.tr);
                            context.read<CheckoutBloc>().add(const CustomTipSet(amount: 0.0));
                            widget.tipController.text = widget.tipController.text.substring(0, widget.tipController.text.length-1);
                            widget.tipController.selection = TextSelection.collapsed(offset: widget.tipController.text.length);
                          }
                        }else {
                          context.read<CheckoutBloc>().add(const CustomTipSet(amount: 0.0));
                        }
                      },

                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  InkWell(
                    onTap: () {
                      context.read<CheckoutBloc>().add(const TipUpdated(tipIndex: 0));
                      context.read<CheckoutBloc>().add(const TipsFieldToggled());
                      if(state.isPartialPay) {
                        context.read<CheckoutBloc>().add(const PartialPaymentToggled());
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: const Icon(Icons.clear),
                    ),
                  ),

                ]) : const SizedBox(),

              ]),
            ) : const SizedBox.shrink(),

            SizedBox(height: (!widget.takeAway && widget.storeId == null && Get.find<SplashController>().configModel!.dmTipsStatus == 1)
                ? Dimensions.paddingSizeSmall : 0),
          ],
        );
      }
    );
  }
}
