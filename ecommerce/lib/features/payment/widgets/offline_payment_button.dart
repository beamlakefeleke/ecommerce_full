import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ecommerce/common/widgets/custom_ink_well.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';

class OfflinePaymentButton extends StatelessWidget {
  final bool isSelected;
  final List<OfflineMethodModel>? offlineMethodList;
  final bool isOfflinePaymentActive;
  final Function onTap;
  final int? selectedOfflineBankIndex;
  final Function(int)? onSelectOfflineBank;
  final JustTheController tooltipController;
  final bool forParcel;
  const OfflinePaymentButton({
    super.key,
    required this.isSelected,
    required this.offlineMethodList,
    required this.isOfflinePaymentActive,
    required this.onTap,
    this.selectedOfflineBankIndex,
    this.onSelectOfflineBank,
    required this.tooltipController,
    this.forParcel = false,
  });

  @override
  Widget build(BuildContext context) {
    return (isOfflinePaymentActive &&
            offlineMethodList != null &&
            offlineMethodList!.isNotEmpty)
        ? InkWell(
            onTap: onTap as void Function()?,
            child: Container(
              width: Dimensions.webMaxWidth,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: forParcel
                      ? Colors.transparent
                      : Theme.of(context).disabledColor,
                  width: 0.3,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeLarge,
              ),
              margin: const EdgeInsets.only(
                bottom: Dimensions.paddingSizeSmall,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).cardColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      Expanded(
                        child: Text(
                          'pay_offline'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),

                      JustTheTooltip(
                        backgroundColor: Colors.black87,
                        controller: tooltipController,
                        preferredDirection: AxisDirection.up,
                        tailLength: 14,
                        tailBaseWidth: 20,
                        content: Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeSmall,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'note'.tr,
                                style: robotoMedium.copyWith(
                                  color: const Color(0xff90D0FF),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              OfflinePaymentTooltipNoteWidget(
                                note: 'offline_payment_note_line_one'.tr,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              OfflinePaymentTooltipNoteWidget(
                                note: 'offline_payment_note_line_two'.tr,
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              OfflinePaymentTooltipNoteWidget(
                                note: 'offline_payment_note_line_three'.tr,
                              ),
                            ],
                          ),
                        ),
                        child: InkWell(
                          onTap: () => tooltipController.showTooltip(),
                          child: isSelected
                              ? Icon(
                                  Icons.info_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 18,
                                )
                              : const SizedBox(),
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),
                    ],
                  ),
                  SizedBox(
                    height: isSelected ? Dimensions.paddingSizeLarge : 0,
                  ),

                  isSelected
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: Dimensions.paddingSizeDefault,
                                mainAxisSpacing: Dimensions.paddingSizeDefault,
                                mainAxisExtent: 50,
                                crossAxisCount:
                                    ResponsiveHelper.isDesktop(context) ? 4 : 3,
                              ),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: offlineMethodList!.length,
                          itemBuilder: (context, index) {
                            bool isBankSelected =
                                selectedOfflineBankIndex == index;
                            return Container(
                              decoration: BoxDecoration(
                                color: isBankSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusLarge,
                                ),
                              ),
                              child: CustomInkWell(
                                onTap: () {
                                  onSelectOfflineBank?.call(index);
                                },
                                radius: Dimensions.radiusLarge,
                                child: Center(
                                  child: Text(
                                    offlineMethodList![index].methodName!,
                                    style: robotoMedium.copyWith(
                                      color: isBankSelected
                                          ? Theme.of(context).cardColor
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color!,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          )
        : const SizedBox();
  }
}

class OfflinePaymentTooltipNoteWidget extends StatelessWidget {
  final String note;
  const OfflinePaymentTooltipNoteWidget({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          flex: 0,
          child: Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Text(
            note,
            style: robotoRegular.copyWith(color: Theme.of(context).cardColor),
          ),
        ),
      ],
    );
  }
}
