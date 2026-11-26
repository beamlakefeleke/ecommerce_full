import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:ecommerce/features/banner/presentation/bloc/banner_state.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';

class WebPromotionalBannerView extends StatelessWidget {
  const WebPromotionalBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerBloc, BannerState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeLarge,
          ),
          child: state.promotionalBanner != null
              ? Container(
                  height: 235,
                  width: context.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      Dimensions.paddingSizeExtraSmall,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      Dimensions.paddingSizeExtraSmall,
                    ),
                    child: CustomImage(
                      image:
                          '${state.promotionalBanner!.promotionalBannerUrl}/${state.promotionalBanner!.bottomSectionBanner}',
                      fit: BoxFit.cover,
                      height: 235,
                      width: double.infinity,
                    ),
                  ),
                )
              : const WebPromotionalBannerShimmerView(),
        );
      },
    );
  }
}

class WebPromotionalBannerShimmerView extends StatelessWidget {
  const WebPromotionalBannerShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: true,
      child: Container(
        height: 235,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
      ),
    );
  }
}
