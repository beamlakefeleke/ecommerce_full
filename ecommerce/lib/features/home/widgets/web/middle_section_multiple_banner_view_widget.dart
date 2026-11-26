import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';

class MiddleSectionMultipleBannerViewWidget extends StatelessWidget {
  const MiddleSectionMultipleBannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        return state.basicCampaignList != null
            ? state.basicCampaignList!.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeExtremeLarge,
                        bottom: Dimensions.paddingSizeDefault,
                      ),
                      child: GridView.builder(
                        itemCount: state.basicCampaignList!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing:
                                  Dimensions.paddingSizeExtremeLarge,
                              mainAxisSpacing:
                                  Dimensions.paddingSizeExtremeLarge,
                              mainAxisExtent: 230,
                            ),
                        itemBuilder: (context, index) {
                          return InkWell(
                            hoverColor: Colors.transparent,
                            onTap: () => Get.toNamed(
                              RouteHelper.getBasicCampaignRoute(
                                state.basicCampaignList![index],
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(Dimensions.radiusDefault),
                                ),
                                color: Theme.of(context).cardColor,
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(Dimensions.radiusDefault),
                                ),
                                child: CustomImage(
                                  image:
                                      '${getIt<SplashBloc>().state.configModel!.baseUrls!.campaignImageUrl}'
                                      '/${state.basicCampaignList![index].image}',
                                  fit: BoxFit.cover,
                                  height: 230,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox()
            : const MiddleSectionMultipleBannerShimmer();
      },
    );
  }
}

class MiddleSectionMultipleBannerShimmer extends StatelessWidget {
  const MiddleSectionMultipleBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: Dimensions.paddingSizeExtremeLarge,
        mainAxisSpacing: Dimensions.paddingSizeExtremeLarge,
        mainAxisExtent: 230,
      ),
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(Dimensions.radiusDefault),
              ),
              color: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }
}
