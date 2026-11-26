import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/taxi_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/taxi_state.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'price_stack_tag.dart';

class TopRatedCars extends StatelessWidget {
  const TopRatedCars({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text(
          'top_rated_cars'.tr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        BlocBuilder<TaxiBloc, TaxiState>(
          builder: (context, taxiState) {
            final topRatedVehicleModel = taxiState.topRatedVehicles;
            return topRatedVehicleModel != null &&
                    topRatedVehicleModel.vehicles!.isNotEmpty
                ? SizedBox(
                    height: 177,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topRatedVehicleModel.vehicles!.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeExtraSmall,
                            vertical: 5,
                          ),
                          child: InkWell(
                            onTap: () => Get.toNamed(
                              RouteHelper.getSelectRideMapLocationRoute(
                                "initial",
                                null,
                                topRatedVehicleModel
                                    .vehicles![index],
                              ),
                            ),
                            child: Container(
                              width: Get.width / 2.6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .grey[Get.isDarkMode ? 700 : 200]!,
                                    offset: const Offset(0, 3.75),
                                    blurRadius: 9.29,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Stack(
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                child: CustomImage(
                                                  image:
                                                      '${getIt<SplashBloc>().state.configModel!.baseUrls!.vehicleImageUrl}/${topRatedVehicleModel.vehicles![index].carImages!.isNotEmpty ? topRatedVehicleModel.vehicles![index].carImages![0] : ''}',
                                                  height: 130,
                                                  width: Get.width,
                                                ),
                                              ),
                                              ReviewStackTag(
                                                value:
                                                    "${topRatedVehicleModel.vehicles![index].avgRating}, (${topRatedVehicleModel.vehicles![index].ratingCount} ${'review'.tr})",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        topRatedVehicleModel
                                            .vehicles![index]
                                            .name!,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall,
                                    ),

                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(3),
                                          ),
                                          child: CustomImage(
                                            height: 18,
                                            width: 18,
                                            image:
                                                '${getIt<SplashBloc>().state.configModel!.baseUrls!.vehicleImageUrl}/'
                                                '${topRatedVehicleModel.vehicles![index].provider != null ? topRatedVehicleModel.vehicles![index].provider!.logo : ''}',
                                          ),
                                        ),
                                        const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall,
                                        ),

                                        Text(
                                          topRatedVehicleModel
                                                      .vehicles![index]
                                                      .provider !=
                                                  null
                                              ? topRatedVehicleModel
                                                    .vehicles![index]
                                                    .provider!
                                                    .name!
                                              : '',
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox();
          },
        ),
      ],
    );
  }
}
