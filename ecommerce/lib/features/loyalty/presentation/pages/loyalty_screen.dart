import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_bloc.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_event.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_state.dart';
import 'package:ecommerce/features/loyalty/presentation/widgets/loyalty_card_widget.dart';
import 'package:ecommerce/features/loyalty/presentation/widgets/loyalty_history_widget.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/common/widgets/web_page_title_widget.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoyaltyBloc>(
      create: (_) => getIt<LoyaltyBloc>(),
      child: const _LoyaltyView(),
    );
  }
}

class _LoyaltyView extends StatefulWidget {
  const _LoyaltyView();

  @override
  State<_LoyaltyView> createState() => _LoyaltyViewState();
}

class _LoyaltyViewState extends State<_LoyaltyView> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      context.read<ProfileBloc>().add(const ProfileInfoRequested());

      context.read<LoyaltyBloc>().add(
        const LoyaltyTransactionsRequested(offset: 1),
      );

      scrollController.addListener(() {
        final bloc = context.read<LoyaltyBloc>();
        final state = bloc.state;
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            state.transactions != null &&
            !state.isLoadingMore) {
          if (state.offset < state.pageSize) {
            final nextOffset = state.offset + 1;
            if (kDebugMode) {
              print('end of the page');
            }
            bloc.add(LoyaltyTransactionsRequested(offset: nextOffset));
          }
        }
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: 'loyalty_points'.tr, backButton: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoggedIn && !ResponsiveHelper.isDesktop(context)
          ? FloatingActionButton.extended(
              backgroundColor: Theme.of(context).primaryColor,
              label: Text(
                'convert_to_wallet_money'.tr,
                style: robotoBold.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              onPressed: () => showLoyaltyConvertDialog(context),
            )
          : null,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          return isLoggedIn
              ? profileState.userInfoModel != null
                    ? SafeArea(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<LoyaltyBloc>().add(
                              const LoyaltyTransactionsRequested(
                                offset: 1,
                                reload: true,
                              ),
                            );
                            context.read<ProfileBloc>().add(
                              const ProfileInfoRequested(),
                            );
                          },
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                WebScreenTitleWidget(
                                  title: 'loyalty_points'.tr,
                                ),
                                FooterView(
                                  child: SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    child: BlocBuilder<LoyaltyBloc, LoyaltyState>(
                                      builder: (context, state) {
                                        return ResponsiveHelper.isDesktop(
                                              context,
                                            )
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                  top: Dimensions
                                                      .paddingSizeDefault,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                ResponsiveHelper.isDesktop(
                                                                  context,
                                                                )
                                                                ? BoxDecoration(
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).cardColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusSmall,
                                                                        ),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black12,
                                                                        blurRadius:
                                                                            5,
                                                                        spreadRadius:
                                                                            1,
                                                                      ),
                                                                    ],
                                                                  )
                                                                : null,
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  Dimensions
                                                                      .paddingSizeLarge,
                                                                ),
                                                            child: LoyaltyCardWidget(
                                                              tooltipController:
                                                                  tooltipController,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeDefault,
                                                    ),

                                                    Expanded(
                                                      flex: 6,
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                ResponsiveHelper.isDesktop(
                                                                  context,
                                                                )
                                                                ? BoxDecoration(
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).cardColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusSmall,
                                                                        ),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black12,
                                                                        blurRadius:
                                                                            5,
                                                                        spreadRadius:
                                                                            1,
                                                                      ),
                                                                    ],
                                                                  )
                                                                : null,
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  Dimensions
                                                                      .paddingSizeLarge,
                                                                ),
                                                            child:
                                                                const LoyaltyHistoryWidget(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                        ),
                                                    child: LoyaltyCardWidget(
                                                      tooltipController:
                                                          tooltipController,
                                                    ),
                                                  ),

                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                        ),
                                                    child:
                                                        LoyaltyHistoryWidget(),
                                                  ),
                                                ],
                                              );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator())
              : NotLoggedInScreen(
                  callBack: (value) {
                    initCall();
                    setState(() {});
                  },
                );
        },
      ),
    );
  }
}
