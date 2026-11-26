import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/item/domain/models/basic_campaign_model.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/features/home/widgets/web/widgets/arrow_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebMostPopularItemBannerViewWidget extends StatelessWidget {
  const WebMostPopularItemBannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeLarge,
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(
                width: Dimensions.webMaxWidth,
                height: 220,
                child: state.basicCampaignList != null
                    ? Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: pageController,
                            itemCount: (state.basicCampaignList!.length / 2)
                                .ceil(),
                            itemBuilder: (context, index) {
                              int index1 = index * 2;
                              int index2 = (index * 2) + 1;
                              bool hasSecond =
                                  index2 < state.basicCampaignList!.length;

                              String? baseUrl1 = getIt<SplashBloc>()
                                  .state
                                  .configModel!
                                  .baseUrls!
                                  .campaignImageUrl;
                              String? baseUrl2 = hasSecond
                                  ? getIt<SplashBloc>()
                                        .state
                                        .configModel!
                                        .baseUrls!
                                        .campaignImageUrl
                                  : '';

                              return Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () =>
                                          _onTap(index1, context, state),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        child: CustomImage(
                                          image:
                                              '$baseUrl1/${state.basicCampaignList![index1].image}',
                                          fit: BoxFit.cover,
                                          height: 220,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: Dimensions.paddingSizeLarge,
                                  ),

                                  Expanded(
                                    child: hasSecond
                                        ? InkWell(
                                            onTap: () =>
                                                _onTap(index2, context, state),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Dimensions.radiusSmall,
                                                  ),
                                              child: CustomImage(
                                                image:
                                                    '$baseUrl2/${state.basicCampaignList![index2].image}',
                                                fit: BoxFit.cover,
                                                height: 220,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              );
                            },
                            onPageChanged: (int index) => getIt<CampaignBloc>()
                                .add(CampaignCurrentIndexChanged(index)),
                          ),

                          state.currentIndex != 0
                              ? Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  child: ArrowIconButton(
                                    isRight: false,
                                    onTap: () => pageController.previousPage(
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                )
                              : const SizedBox(),

                          state.currentIndex !=
                                  ((state.basicCampaignList!.length / 2)
                                          .ceil() -
                                      1)
                              ? Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  child: ArrowIconButton(
                                    onTap: () => pageController.nextPage(
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      )
                    : const WebBannerShimmer(),
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),
              state.basicCampaignList != null
                  ? Builder(
                      builder: (context) {
                        List finalBanner = [];
                        for (
                          int i = 0;
                          i < state.basicCampaignList!.length;
                          i++
                        ) {
                          if (i % 2 == 0) {
                            finalBanner.add(state.basicCampaignList![i]);
                          }
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: finalBanner.map((bnr) {
                            int index = finalBanner.indexOf(bnr);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: index == state.currentIndex
                                  ? Container(
                                      height: 5,
                                      width: 6,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 4,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusDefault,
                                        ),
                                      ),
                                    ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  void _onTap(int index, BuildContext context, CampaignState state) {
    BasicCampaignModel campaign = state.basicCampaignList![index];
    Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
  }
}

class WebBannerShimmer extends StatelessWidget {
  const WebBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Colors.grey[300],
              ),
            ),
          ),

          const SizedBox(width: Dimensions.paddingSizeLarge),

          Expanded(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
