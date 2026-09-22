import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';
import 'package:ecommerce/common/widgets/not_logged_in_screen.dart';
import 'package:ecommerce/features/favourite/widgets/fav_item_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      getIt<FavouriteBloc>().add(const FavouriteListFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'favourite'.tr, backButton: false),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: AuthHelper.isLoggedIn() ? SafeArea(child: Column(children: [

        Container(
          width: Dimensions.webMaxWidth,
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).disabledColor,
            unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
            tabs: [
              Tab(text: 'item'.tr),
              Tab(text: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                  ? 'restaurants'.tr : 'stores'.tr),
            ],
          ),
        ),

        Expanded(child: TabBarView(
          controller: _tabController,
          children: const [
            FavItemViewWidget(isStore: false),
            FavItemViewWidget(isStore: true),
          ],
        )),

      ])) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }
}
