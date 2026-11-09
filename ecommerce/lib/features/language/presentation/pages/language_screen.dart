import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_event.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_state.dart';
import 'package:ecommerce/features/language/presentation/widgets/web_language_widget.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/web_page_title_widget.dart';
import 'package:ecommerce/features/language/presentation/widgets/language_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const ChooseLanguageScreen({super.key, this.fromMenu = false});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh the selectable list + highlighted index for the current locale.
    context.read<LanguageBloc>().add(const LanguageInitialized());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context))
          ? CustomAppBar(title: 'language'.tr, backButton: true)
          : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, state) {
            return Column(
              children: [
                WebScreenTitleWidget(title: 'language'.tr),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: ResponsiveHelper.isDesktop(context)
                          ? EdgeInsets.zero
                          : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Center(
                        child: FooterView(
                          minHeight: 0.615,
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                !ResponsiveHelper.isDesktop(context)
                                    ? Center(
                                        child: Image.asset(
                                          Images.logo,
                                          width: 200,
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                SizedBox(height: state.isLtr ? 30 : 25),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                  ),
                                  child: Text(
                                    'select_language'.tr,
                                    style: robotoMedium,
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),

                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                              ? 2
                                              : ResponsiveHelper.isTab(context)
                                              ? 3
                                              : 2,
                                          childAspectRatio:
                                              ResponsiveHelper.isDesktop(
                                                context,
                                              )
                                              ? 6
                                              : (1 / 1),
                                          mainAxisSpacing:
                                              Dimensions.paddingSizeDefault,
                                          crossAxisSpacing:
                                              Dimensions.paddingSizeDefault,
                                        ),
                                    itemCount: state.languages.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                    ),
                                    itemBuilder: (context, index) =>
                                        ResponsiveHelper.isDesktop(context)
                                        ? WebLanguageWidget(
                                            languageModel:
                                                state.languages[index],
                                            index: index,
                                            isSelected:
                                                state.selectedIndex == index,
                                          )
                                        : LanguageWidget(
                                            languageModel:
                                                state.languages[index],
                                            index: index,
                                            isSelected:
                                                state.selectedIndex == index,
                                          ),
                                  ),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeExtremeLarge,
                                ),

                                !ResponsiveHelper.isDesktop(context)
                                    ? Center(
                                        child: Text(
                                          'you_can_change_language'.tr,
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ResponsiveHelper.isDesktop(context)
                    ? const SizedBox.shrink()
                    : LanguageSaveButton(
                        state: state,
                        fromMenu: widget.fromMenu,
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LanguageSaveButton extends StatelessWidget {
  final LanguageState state;
  final bool? fromMenu;
  const LanguageSaveButton({super.key, required this.state, this.fromMenu});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomButton(
          buttonText: 'save'.tr,
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          onPressed: () {
            if (state.languages.isNotEmpty && state.selectedIndex != -1) {
              context.read<LanguageBloc>().add(
                LanguageChanged(
                  Locale(
                    AppConstants.languages[state.selectedIndex].languageCode!,
                    AppConstants.languages[state.selectedIndex].countryCode,
                  ),
                ),
              );
              if (fromMenu!) {
                Navigator.pop(context);
              } else {
                Get.offNamed(RouteHelper.getOnBoardingRoute());
              }
            } else {
              showCustomSnackBar('select_a_language'.tr);
            }
          },
        ),
      ],
    );
  }
}
