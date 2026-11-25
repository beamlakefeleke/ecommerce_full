import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/review/presentation/bloc/review_bloc.dart';
import 'package:ecommerce/features/review/presentation/bloc/review_event.dart';
import 'package:ecommerce/features/review/presentation/bloc/review_state.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';
import 'package:ecommerce/features/store/presentation/widgets/review_widget.dart';

class ReviewScreen extends StatelessWidget {
  final String? storeID;
  const ReviewScreen({super.key, required this.storeID});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ReviewBloc>()..add(StoreReviewListRequested(storeID)),
      child: _ReviewView(storeID: storeID),
    );
  }
}

class _ReviewView extends StatelessWidget {
  final String? storeID;
  const _ReviewView({required this.storeID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            getIt<SplashBloc>().state
                .configModel!
                .moduleConfig!
                .module!
                .showRestaurantText!
            ? 'restaurant_reviews'.tr
            : 'store_reviews'.tr,
      ),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          if (state.storeReviewStatus == StoreReviewStatus.loading ||
              state.storeReviewStatus == StoreReviewStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.storeReviewList.isEmpty) {
            return Center(
              child: NoDataScreen(text: 'no_review_found'.tr, showFooter: true),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReviewBloc>().add(StoreReviewListRequested(storeID));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isMobile(context)
                          ? 1
                          : 2,
                      childAspectRatio: (1 / 0.2),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: state.storeReviewList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return ReviewWidget(
                        review: state.storeReviewList[index],
                        hasDivider: index != state.storeReviewList.length - 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
