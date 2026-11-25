import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/store/data/models/store_banner_model.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StoreBannerWidget extends StatelessWidget {
  final List<StoreBannerModel>? storeBanners;
  const StoreBannerWidget({super.key, required this.storeBanners});

  @override
  Widget build(BuildContext context) {
    return (storeBanners != null && storeBanners!.isNotEmpty)
        ? Container(
            height: context.width * 0.3,
            width: double.infinity,
            margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            child: CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                disableCenter: true,
                viewportFraction: 1,
                autoPlayInterval: const Duration(seconds: 4),
              ),
              itemCount: storeBanners!.length,
              itemBuilder: (context, index, _) {
                return InkWell(
                  onTap: () async {
                    final String url = storeBanners![index].defaultLink!;
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      showCustomSnackBar('unable_to_found_url'.tr);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImage(
                      image:
                          '${getIt<SplashBloc>().state.configModel!.baseUrls!.bannerImageUrl}/${storeBanners![index].image}',
                    ),
                  ),
                );
              },
            ),
          )
        : const SizedBox();
  }
}
