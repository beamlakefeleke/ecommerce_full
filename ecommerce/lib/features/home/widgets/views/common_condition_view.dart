import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/item/presentation/bloc/item_bloc.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/home/widgets/web/web_basic_medicine_nearby_view_widget.dart';
import 'package:ecommerce/features/home/widgets/web/widgets/medicine_item_card.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';

class CommonConditionView extends StatelessWidget {
  const CommonConditionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        return state.commonConditions != null
            ? state.commonConditions!.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: Dimensions.paddingSizeDefault,
                                left: getIt<LanguageBloc>().state.isLtr
                                    ? Dimensions.paddingSizeDefault
                                    : 0,
                                right: getIt<LanguageBloc>().state.isLtr
                                    ? 0
                                    : Dimensions.paddingSizeDefault,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'common_condition'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeDefault,
                                  ),

                                  SizedBox(
                                    height: 35,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: state.commonConditions!.length,
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        bool isSelected =
                                            state.selectedCommonCondition ==
                                            index;
                                        double width =
                                            double.parse(
                                              state
                                                  .commonConditions![index]
                                                  .name!
                                                  .length
                                                  .toString(),
                                            ) *
                                            5;
                                        return InkWell(
                                          onTap: () => getIt<ItemBloc>().add(
                                            CommonConditionSelected(index),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right:
                                                  Dimensions.paddingSizeDefault,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${state.commonConditions![index].name}',
                                                  style: robotoMedium.copyWith(
                                                    color: isSelected
                                                        ? Theme.of(
                                                            context,
                                                          ).primaryColor
                                                        : Theme.of(
                                                            context,
                                                          ).disabledColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeExtraSmall,
                                                ),

                                                isSelected
                                                    ? Container(
                                                        margin: const EdgeInsets.only(
                                                          top: Dimensions
                                                              .paddingSizeExtraSmall,
                                                        ),
                                                        height: 2,
                                                        width: width,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            state.conditionWiseProduct != null &&
                                    state.conditionWiseProduct!.isNotEmpty
                                ? GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              ResponsiveHelper.isMobile(context)
                                              ? 2
                                              : 4,
                                          crossAxisSpacing:
                                              Dimensions.paddingSizeDefault,
                                          mainAxisSpacing:
                                              Dimensions.paddingSizeDefault,
                                          mainAxisExtent: 250,
                                        ),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeDefault,
                                    ),
                                    itemCount:
                                        state.conditionWiseProduct!.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return MedicineItemCard(
                                        item:
                                            state.conditionWiseProduct![index],
                                      );
                                    },
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault,
                                      ),
                                      child: Text('no_product_available'.tr),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox()
            : const MedicineCardShimmer();
      },
    );
  }
}
