import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_state.dart';
import 'package:ecommerce/features/category/domain/entities/category.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/features/home/widgets/category_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return BlocBuilder<SplashBloc, SplashState>(
      builder: (context, splashController) {
        bool isPharmacy =
            splashController.module != null &&
            splashController.module!.moduleType.toString() == 'pharmacy';
        bool isFood =
            splashController.module != null &&
            splashController.module!.moduleType.toString() == 'food';

        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            final List<Category>? categoryList =
                categoryState.status == CategoryStatus.loaded
                ? categoryState.categories
                : null;
            return (categoryList != null && categoryList.isEmpty)
                ? const SizedBox()
                : isPharmacy
                ? PharmacyCategoryView(categoryList: categoryList)
                : isFood
                ? FoodCategoryView(categoryList: categoryList)
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 130,
                              child: categoryList != null
                                  ? ListView.builder(
                                      controller: scrollController,
                                      itemCount: categoryList.length > 15
                                          ? 15
                                          : categoryList.length,
                                      padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeSmall,
                                        top: Dimensions.paddingSizeDefault,
                                      ),
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 1,
                                            vertical:
                                                Dimensions.paddingSizeDefault,
                                          ),
                                          child: InkWell(
                                            onTap: () => Get.toNamed(
                                              RouteHelper.getCategoryItemRoute(
                                                categoryList[index].id,
                                                categoryList[index].name!,
                                              ),
                                            ),
                                            child: SizedBox(
                                              width: 60,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    margin: EdgeInsets.only(
                                                      left: index == 0
                                                          ? 0
                                                          : Dimensions
                                                                .paddingSizeExtraSmall,
                                                      right: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusSmall,
                                                              ),
                                                          child: CustomImage(
                                                            image:
                                                                '${getIt<SplashBloc>().state.configModel!.baseUrls!.categoryImageUrl}/${categoryList[index].image}',
                                                            height: 50,
                                                            width: 50,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),

                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right: index == 0
                                                          ? Dimensions
                                                                .paddingSizeExtraSmall
                                                          : 0,
                                                    ),
                                                    child: Text(
                                                      categoryList[index].name!,
                                                      style: robotoMedium
                                                          .copyWith(
                                                            fontSize: 11,
                                                          ),
                                                      maxLines:
                                                          getIt<LanguageBloc>()
                                                              .state
                                                              .isLtr
                                                          ? 2
                                                          : 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const CategoryShimmer(),
                            ),
                          ),

                          ResponsiveHelper.isMobile(context)
                              ? const SizedBox()
                              : categoryList != null
                              ? Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (con) => Dialog(
                                            child: SizedBox(
                                              height: 550,
                                              width: 600,
                                              child: CategoryPopUp(
                                                categoryList: categoryList,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: Dimensions.paddingSizeSmall,
                                        ),
                                        child: CircleAvatar(
                                          radius: 35,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                          child: Text(
                                            'view_all'.tr,
                                            style: TextStyle(
                                              fontSize:
                                                  Dimensions.paddingSizeDefault,
                                              color: Theme.of(
                                                context,
                                              ).cardColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : const CategoryAllShimmer(),
                        ],
                      ),
                    ],
                  );
          },
        );
      },
    );
  }
}

class PharmacyCategoryView extends StatelessWidget {
  final List<Category>? categoryList;
  const PharmacyCategoryView({super.key, required this.categoryList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: categoryList != null
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  itemCount: categoryList!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault,
                        left: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeDefault,
                        right: index == categoryList!.length - 1
                            ? Dimensions.paddingSizeDefault
                            : 0,
                      ),
                      child: InkWell(
                        onTap: () => Get.toNamed(
                          RouteHelper.getCategoryItemRoute(
                            categoryList![index].id,
                            categoryList![index].name!,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        child: Container(
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(100),
                              topRight: Radius.circular(100),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.3),
                                Theme.of(context).cardColor.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  topRight: Radius.circular(100),
                                ),
                                child: CustomImage(
                                  image:
                                      '${getIt<SplashBloc>().state.configModel!.baseUrls!.categoryImageUrl}/${categoryList![index].image}',
                                  height: 60,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),

                              Expanded(
                                child: Text(
                                  categoryList![index].name!,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium!.color,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const CategoryShimmer(),
        ),
      ],
    );
  }
}

class FoodCategoryView extends StatelessWidget {
  final List<Category>? categoryList;
  const FoodCategoryView({super.key, required this.categoryList});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: categoryList != null
                  ? ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                      ),
                      itemCount: categoryList!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault,
                            left: Dimensions.paddingSizeDefault,
                            top: Dimensions.paddingSizeDefault,
                          ),
                          child: InkWell(
                            onTap: () => Get.toNamed(
                              RouteHelper.getCategoryItemRoute(
                                categoryList![index].id,
                                categoryList![index].name!,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            child: SizedBox(
                              width: 60,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                    child: CustomImage(
                                      image:
                                          '${getIt<SplashBloc>().state.configModel!.baseUrls!.categoryImageUrl}/${categoryList![index].image}',
                                      height: 60,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),

                                  Expanded(
                                    child: Text(
                                      categoryList![index].name!,
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const CategoryShimmer(),
            ),
          ],
        ),
      ],
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: ListView.builder(
        itemCount: 14,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusSmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(height: 10, width: 50, color: Colors.grey[300]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryAllShimmer extends StatelessWidget {
  const CategoryAllShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Padding(
        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        child: Shimmer(
          duration: const Duration(seconds: 2),
          child: Column(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
              const SizedBox(height: 5),
              Container(height: 10, width: 50, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }
}
