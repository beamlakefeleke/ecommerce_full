import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_bloc.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_event.dart';
import 'package:ecommerce/features/category/presentation/bloc/category_state.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_image.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:get/get.dart';

class InterestScreen extends StatelessWidget {
  const InterestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CategoryBloc>().add(
      const CategoryListRequested(reload: true, allCategory: true),
    );

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: BlocConsumer<CategoryBloc, CategoryState>(
          listenWhen: (p, c) =>
              p.actionStatus != c.actionStatus &&
              c.actionStatus == CategoryActionStatus.success,
          listener: (_, __) => Get.offAllNamed(RouteHelper.getInitialRoute()),
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.categories != c.categories ||
              p.interestSelected != c.interestSelected ||
              p.actionStatus != c.actionStatus,
          builder: (context, state) {
            if (state.status == CategoryStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.categories.isEmpty) {
              return NoDataScreen(text: 'no_category_found'.tr);
            }
            return Center(
              child: Container(
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Text(
                      'choose_your_interests'.tr,
                      style: robotoMedium.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'get_personalized_recommendations'.tr,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.categories.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isDesktop(context)
                              ? 4
                              : ResponsiveHelper.isTab(context)
                              ? 3
                              : 2,
                          childAspectRatio: 1 / 0.35,
                        ),
                        itemBuilder: (context, index) {
                          final cat = state.categories[index];
                          final selected = state.interestSelected.length > index
                              ? state.interestSelected[index]
                              : false;
                          return InkWell(
                            onTap: () => context.read<CategoryBloc>().add(
                              CategoryInterestSelectionToggled(index),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall,
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .grey[Get.isDarkMode ? 800 : 200]!,
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault,
                                    ),
                                    child: CustomImage(
                                      image:
                                          '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}'
                                          '/${cat.image}',
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Flexible(
                                    child: Text(
                                      cat.name ?? '',
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: selected
                                            ? Theme.of(context).cardColor
                                            : Theme.of(
                                                context,
                                              ).textTheme.bodyLarge!.color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    CustomButton(
                      buttonText: 'save_and_continue'.tr,
                      isLoading:
                          state.actionStatus == CategoryActionStatus.inProgress,
                      onPressed: () {
                        final List<int?> interests = [];
                        for (int i = 0; i < state.categories.length; i++) {
                          if (state.interestSelected.length > i &&
                              state.interestSelected[i]) {
                            interests.add(state.categories[i].id);
                          }
                        }
                        context.read<CategoryBloc>().add(
                          CategoryInterestSaved(interests),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
