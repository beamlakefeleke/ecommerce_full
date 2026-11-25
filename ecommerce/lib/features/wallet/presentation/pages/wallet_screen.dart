import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_event.dart';
import 'package:ecommerce/features/profile/presentation/bloc/profile_state.dart';
import 'package:ecommerce/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:ecommerce/features/wallet/presentation/widgets/bonus_banner_widget.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/common/widgets/web_page_title_widget.dart';
import 'package:ecommerce/features/wallet/presentation/widgets/wallet_card_widget.dart';
import 'package:ecommerce/features/wallet/presentation/widgets/wallet_history_widget.dart';
import 'package:ecommerce/features/wallet/presentation/widgets/web_bonus_banner_widget.dart';

class WalletScreen extends StatefulWidget {
  final String? fundStatus;
  final String? token;
  const WalletScreen({super.key, this.fundStatus, this.token});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();
  late WalletBloc _walletBloc;

  @override
  void initState() {
    super.initState();
    _walletBloc = getIt<WalletBloc>();
    initCall();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      _walletBloc.add(const WalletInitialized());
      _walletBloc.add(const WalletFilterTypeChanged('all'));

      if ((widget.fundStatus == 'success' ||
              widget.fundStatus == 'fail' ||
              widget.fundStatus == 'cancel') &&
          getIt<WalletRepository>().getWalletAccessToken() != widget.token) {
        Future.delayed(const Duration(seconds: 2), () {
          Get.showSnackbar(
            GetSnackBar(
              backgroundColor:
                  widget.fundStatus == 'fail' || widget.fundStatus == 'cancel'
                  ? Colors.red
                  : Colors.green,
              message: widget.fundStatus == 'success'
                  ? 'fund_successfully_added_to_wallet'.tr
                  : 'fund_not_added_to_wallet'.tr,
              maxWidth: 500,
              duration: const Duration(seconds: 3),
              snackStyle: SnackStyle.FLOATING,
              margin: const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge),
              borderRadius: Dimensions.radiusExtraLarge,
              isDismissible: true,
              dismissDirection: DismissDirection.horizontal,
            ),
          );
        }).then((value) {
          getIt<WalletRepository>().setWalletAccessToken(widget.token ?? '');
        });
      }
      getIt<ProfileBloc>().add(const ProfileInfoRequested());

      _walletBloc.add(const WalletBonusListRequested());
      _walletBloc.add(const WalletTransactionListRequested(
        offset: 1,
        walletType: 'all',
      ));
      _walletBloc.add(const WalletOffsetSet(1));

      scrollController.addListener(() {
        final state = _walletBloc.state;
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            state.transactionList != null &&
            !state.isLoading) {
          int pageSize = (state.pageSize! / 10).ceil();
          if (state.offset < pageSize) {
            _walletBloc.add(WalletOffsetSet(state.offset + 1));
            if (kDebugMode) {
              print('end of the page');
            }
            _walletBloc.add(const WalletBottomLoaderShown());
            _walletBloc.add(WalletTransactionListRequested(
              offset: state.offset + 1,
              walletType: state.type,
            ));
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();

    return BlocProvider.value(
      value: _walletBloc,
      child: BlocBuilder<ProfileBloc, ProfileState>(
        bloc: getIt<ProfileBloc>(),
        builder: (context, profileState) {
          return Scaffold(
            backgroundColor: Theme.of(context).cardColor,
            endDrawer: const MenuDrawer(),
            endDrawerEnableOpenDragGesture: false,
            appBar: CustomAppBar(title: 'wallet'.tr, backButton: true),
            body: isLoggedIn
                ? profileState.userInfoModel != null
                    ? SafeArea(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _walletBloc
                                .add(const WalletFilterTypeChanged('all'));
                            _walletBloc.add(
                              const WalletTransactionListRequested(
                                offset: 1,
                                reload: true,
                                walletType: 'all',
                              ),
                            );
                            getIt<ProfileBloc>()
                                .add(const ProfileInfoRequested());
                          },
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                WebScreenTitleWidget(title: 'wallet'.tr),
                                FooterView(
                                  child: SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    child: BlocBuilder<WalletBloc, WalletState>(
                                      bloc: _walletBloc,
                                      builder: (context, walletState) {
                                        return ResponsiveHelper.isDesktop(context)
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
                                                                ResponsiveHelper
                                                                        .isDesktop(
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
                                                            child: WalletCardWidget(
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
                                                          const WebBonusBannerWidget(),
                                                          Container(
                                                            decoration:
                                                                ResponsiveHelper
                                                                        .isDesktop(
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
                                                                const WalletHistoryWidget(),
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
                                                    child: WalletCardWidget(
                                                      tooltipController:
                                                          tooltipController,
                                                    ),
                                                  ),
                                                  const BonusBannerWidget(),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeLarge,
                                                        ),
                                                    child:
                                                        WalletHistoryWidget(),
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
                  ),
          );
        },
      ),
    );
  }
}
