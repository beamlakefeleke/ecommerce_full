import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/onboard/presentation/bloc/onboard_bloc.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardBloc>(
      create: (_) => getIt<OnboardBloc>()..add(const OnBoardingListRequested()),
      child: const _OnBoardingView(),
    );
  }
}

class _OnBoardingView extends StatefulWidget {
  const _OnBoardingView();

  @override
  State<_OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<_OnBoardingView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: SafeArea(
        child: BlocBuilder<OnboardBloc, OnboardState>(
          builder: (context, state) => state.onBoardingList.isNotEmpty
              ? SafeArea(
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              itemCount: state.onBoardingList.length,
                              controller: _pageController,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(
                                        context.height * 0.05,
                                      ),
                                      child: Image.asset(
                                        state.onBoardingList[index].imageUrl,
                                        height: context.height * 0.4,
                                      ),
                                    ),

                                    Text(
                                      state.onBoardingList[index].title,
                                      style: robotoMedium.copyWith(
                                        fontSize: context.height * 0.022,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: context.height * 0.025),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeLarge,
                                      ),
                                      child: Text(
                                        state.onBoardingList[index].description,
                                        style: robotoRegular.copyWith(
                                          fontSize: context.height * 0.015,
                                          color: Theme.of(
                                            context,
                                          ).disabledColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              onPageChanged: (index) {
                                context.read<OnboardBloc>().add(
                                  OnBoardingIndexChanged(index),
                                );
                              },
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _pageIndicators(state, context),
                          ),
                          SizedBox(height: context.height * 0.05),

                          Padding(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSmall,
                            ),
                            child: Row(
                              children: [
                                state.selectedIndex == 2
                                    ? const SizedBox()
                                    : Expanded(
                                        child: CustomButton(
                                          transparent: true,
                                          onPressed: () {
                                            Get.find<SplashController>()
                                                .disableIntro();
                                            Get.offNamed(
                                              RouteHelper.getSignInRoute(
                                                RouteHelper.onBoarding,
                                              ),
                                            );
                                          },
                                          buttonText: 'skip'.tr,
                                        ),
                                      ),
                                Expanded(
                                  child: CustomButton(
                                    buttonText: state.selectedIndex != 2
                                        ? 'next'.tr
                                        : 'get_started'.tr,
                                    onPressed: () {
                                      if (state.selectedIndex != 2) {
                                        _pageController.nextPage(
                                          duration: const Duration(seconds: 1),
                                          curve: Curves.ease,
                                        );
                                      } else {
                                        Get.find<SplashController>()
                                            .disableIntro();
                                        Get.offNamed(
                                          RouteHelper.getSignInRoute(
                                            RouteHelper.onBoarding,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  List<Widget> _pageIndicators(OnboardState state, BuildContext context) {
    List<Container> indicators = [];

    for (int i = 0; i < state.onBoardingList.length; i++) {
      indicators.add(
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: i == state.selectedIndex
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
            borderRadius: i == state.selectedIndex
                ? BorderRadius.circular(50)
                : BorderRadius.circular(25),
          ),
        ),
      );
    }
    return indicators;
  }
}
