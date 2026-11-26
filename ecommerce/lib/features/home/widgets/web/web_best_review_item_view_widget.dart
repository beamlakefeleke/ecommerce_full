import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/item/presentation/bloc/item_bloc.dart';
import 'package:ecommerce/features/item/presentation/helpers/item_helper.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/features/home/widgets/components/review_item_card_widget.dart';
import 'package:ecommerce/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/title_widget.dart';

class WebBestReviewItemViewWidget extends StatefulWidget {
  const WebBestReviewItemViewWidget({super.key});

  @override
  State<WebBestReviewItemViewWidget> createState() =>
      _WebBestReviewItemViewWidgetState();
}

class _WebBestReviewItemViewWidgetState
    extends State<WebBestReviewItemViewWidget> {
  ScrollController scrollController = ScrollController();
  bool showBackButton = false;
  bool showForwardButton = false;
  bool isFirstTime = true;

  @override
  void initState() {
    scrollController.addListener(_checkScrollPosition);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    setState(() {
      if (scrollController.position.pixels <= 0) {
        showBackButton = false;
      } else {
        showBackButton = true;
      }

      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        showForwardButton = false;
      } else {
        showForwardButton = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isShop =
        getIt<SplashBloc>().state.module != null &&
        getIt<SplashBloc>().state.module!.moduleType.toString() ==
            AppConstants.ecommerce;

    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        List<Item>? reviewItemList = state.reviewedItemList;

        if (reviewItemList != null &&
            reviewItemList.length > 5 &&
            isFirstTime) {
          showForwardButton = true;
          isFirstTime = false;
        }

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: TitleWidget(
                      title: isShop
                          ? 'best_reviewed_products'.tr
                          : 'best_reviewed_item'.tr,
                      onTap: () => Get.toNamed(
                        RouteHelper.getPopularItemRoute(false, false),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 285,
                    width: Get.width,
                    child: reviewItemList != null
                        ? ListView.builder(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            //padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                            itemCount: reviewItemList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeDefault,
                                  top: Dimensions.paddingSizeDefault,
                                  left: getIt<LanguageBloc>().state.isLtr
                                      ? 0
                                      : Dimensions.paddingSizeDefault,
                                  right: getIt<LanguageBloc>().state.isLtr
                                      ? Dimensions.paddingSizeDefault
                                      : 0,
                                ),
                                child: InkWell(
                                  hoverColor: Colors.transparent,
                                  onTap: () => ItemHelper.navigateToItemPage(
                                    reviewItemList[index],
                                    context,
                                  ),
                                  child: ReviewItemCard(
                                    item: state.reviewedItemList![index],
                                  ),
                                ),
                              );
                            },
                          )
                        : const WebBestReviewItemShimmer(),
                  ),
                ],
              ),
            ),

            if (showBackButton)
              Positioned(
                top: 185,
                left: 0,
                child: ArrowIconButton(
                  isRight: false,
                  onTap: () => scrollController.animateTo(
                    scrollController.offset - Dimensions.webMaxWidth,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),

            if (showForwardButton)
              Positioned(
                top: 185,
                right: 0,
                child: ArrowIconButton(
                  onTap: () => scrollController.animateTo(
                    scrollController.offset + Dimensions.webMaxWidth,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class WebBestReviewItemShimmer extends StatelessWidget {
  const WebBestReviewItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeDefault,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: Dimensions.paddingSizeDefault,
            top: Dimensions.paddingSizeDefault,
            left: getIt<LanguageBloc>().state.isLtr
                ? 0
                : Dimensions.paddingSizeDefault,
            right: getIt<LanguageBloc>().state.isLtr
                ? Dimensions.paddingSizeDefault
                : 0,
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              width: 210,
              height: 285,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Colors.grey[300],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.paddingSizeExtraSmall,
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(Dimensions.radiusSmall),
                            ),
                            child: Container(
                              color: Colors.grey[300],
                              width: 210,
                              height: 285,
                            ),
                          ),
                        ),

                        Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            Icons.favorite,
                            size: 20,
                            color: Theme.of(context).cardColor,
                          ),
                        ),

                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                      topRight: Radius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                    ),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 10,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      Container(
                                        width: 100,
                                        height: 10,
                                        color: Colors.grey[300],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
