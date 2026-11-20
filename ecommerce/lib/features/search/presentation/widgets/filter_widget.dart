
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/features/search/presentation/widgets/custom_check_box_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/search/presentation/bloc/search_bloc.dart';
import 'package:ecommerce/features/search/presentation/bloc/search_event.dart';
import 'package:ecommerce/features/search/presentation/bloc/search_state.dart';

class FilterWidget extends StatelessWidget {
  final double? maxValue;
  final bool isStore;
  const FilterWidget({
    super.key,
    required this.maxValue,
    required this.isStore,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, searchController) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      Text(
                        'filter'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                      CustomButton(
                        onPressed: () {
                          if (isStore) {
                            context.read<SearchBloc>().add(const SearchStoreFilterReset());
                          } else {
                            context.read<SearchBloc>().add(const SearchItemFilterReset());
                          }
                        },
                        buttonText: 'reset'.tr,
                        transparent: true,
                        width: 65,
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    'sort_by'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  GridView.builder(
                    itemCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context)
                          ? 3
                          : ResponsiveHelper.isTab(context)
                          ? 3
                          : 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (isStore) {
                            context.read<SearchBloc>().add(SearchStoreSortIndexSet(index));
                          } else {
                            context.read<SearchBloc>().add(SearchItemSortIndexSet(index));
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  (isStore
                                      ? searchController.storeSortIndex == index
                                      : searchController.sortIndex == index)
                                  ? Colors.transparent
                                  : Theme.of(context).disabledColor,
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            color:
                                (isStore
                                    ? searchController.storeSortIndex == index
                                    : searchController.sortIndex == index)
                                ? Theme.of(context).primaryColor
                                : Theme.of(
                                    context,
                                  ).disabledColor.withOpacity(0.1),
                          ),
                          child: Text(
                            index == 0 ? 'ascending'.tr : 'descending'.tr,
                            textAlign: TextAlign.center,
                            style: robotoMedium.copyWith(
                              color:
                                  (isStore
                                      ? searchController.storeSortIndex == index
                                      : searchController.sortIndex == index)
                                  ? Colors.white
                                  : Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    'filter_by'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  (Get.find<SplashController>().configModel!.toggleVegNonVeg! &&
                          Get.find<SplashController>()
                              .configModel!
                              .moduleConfig!
                              .module!
                              .vegNonVeg!)
                      ? CustomCheckBoxWidget(
                          title: 'veg'.tr,
                          value: isStore
                              ? searchController.storeVeg
                              : searchController.veg,
                          onClick: () => isStore
                              ? context.read<SearchBloc>().add(const SearchStoreVegToggled())
                              : context.read<SearchBloc>().add(const SearchVegToggled()),
                        )
                      : const SizedBox(),

                  (Get.find<SplashController>().configModel!.toggleVegNonVeg! &&
                          Get.find<SplashController>()
                              .configModel!
                              .moduleConfig!
                              .module!
                              .vegNonVeg!)
                      ? CustomCheckBoxWidget(
                          title: 'non_veg'.tr,
                          value: isStore
                              ? searchController.storeNonVeg
                              : searchController.nonVeg,
                          onClick: () => isStore
                              ? context.read<SearchBloc>().add(const SearchStoreNonVegToggled())
                              : context.read<SearchBloc>().add(const SearchNonVegToggled()),
                        )
                      : const SizedBox(),

                  CustomCheckBoxWidget(
                    title: isStore
                        ? Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
                              ? 'currently_opened_restaurants'.tr
                              : 'currently_opened_stores'.tr
                        : 'currently_available_items'.tr,
                    value: isStore
                        ? searchController.isAvailableStore
                        : searchController.isAvailableItems,
                    onClick: () {
                      if (isStore) {
                        context.read<SearchBloc>().add(const SearchAvailableStoreToggled());
                      } else {
                        context.read<SearchBloc>().add(const SearchAvailableItemsToggled());
                      }
                    },
                  ),

                  CustomCheckBoxWidget(
                    title: isStore
                        ? Get.find<SplashController>()
                                  .configModel!
                                  .moduleConfig!
                                  .module!
                                  .showRestaurantText!
                              ? 'discounted_restaurants'.tr
                              : 'discounted_stores'.tr
                        : 'discounted_items'.tr,
                    value: isStore
                        ? searchController.isDiscountedStore
                        : searchController.isDiscountedItems,
                    onClick: () {
                      if (isStore) {
                        context.read<SearchBloc>().add(const SearchDiscountedStoreToggled());
                      } else {
                        context.read<SearchBloc>().add(const SearchDiscountedItemsToggled());
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  isStore
                      ? const SizedBox()
                      : Column(
                          children: [
                            Text(
                              'price'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                            RangeSlider(
                              values: RangeValues(
                                searchController.lowerValue,
                                searchController.upperValue,
                              ),
                              max: maxValue!.toInt().toDouble(),
                              min: 0,
                              divisions: maxValue!.toInt(),
                              activeColor: Theme.of(context).primaryColor,
                              inactiveColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              labels: RangeLabels(
                                searchController.lowerValue.toString(),
                                searchController.upperValue.toString(),
                              ),
                              onChanged: (RangeValues rangeValues) {
                                context.read<SearchBloc>().add(SearchPriceRangeSet(
                                  rangeValues.start, rangeValues.end,
                                ));
                              },
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                          ],
                        ),

                  Text(
                    'rating'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),

                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: ListView.builder(
                      itemCount: 5,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => isStore
                              ? context.read<SearchBloc>().add(SearchStoreRatingSet(index + 1))
                              : context.read<SearchBloc>().add(SearchItemRatingSet(index + 1)),
                          child: Icon(
                            (isStore
                                    ? searchController.storeRating < (index + 1)
                                    : searchController.rating < (index + 1))
                                ? Icons.star_border
                                : Icons.star,
                            size: 30,
                            color:
                                (isStore
                                    ? searchController.storeRating < (index + 1)
                                    : searchController.rating < (index + 1))
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  CustomButton(
                    buttonText: 'apply_filters'.tr,
                    onPressed: () {
                      if (isStore) {
                        context.read<SearchBloc>().add(const SearchFiltersApplied());
                      } else {
                        context.read<SearchBloc>().add(const SearchFiltersApplied());
                      }
                      Get.back();
                    },
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
