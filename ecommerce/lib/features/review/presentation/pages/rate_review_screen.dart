import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/review/presentation/bloc/review_bloc.dart';
import 'package:ecommerce/features/review/presentation/bloc/review_event.dart';
import 'package:ecommerce/features/review/presentation/widgets/deliver_man_review_widget.dart';
import 'package:ecommerce/features/review/presentation/widgets/item_review_widget.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';

class RateReviewScreen extends StatelessWidget {
  final List<OrderDetailsModel> orderDetailsList;
  final DeliveryMan? deliveryMan;
  final int? orderID;
  const RateReviewScreen({
    super.key,
    required this.orderDetailsList,
    required this.deliveryMan,
    required this.orderID,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ReviewBloc>()
            ..add(ReviewRatingDataInitialized(orderDetailsList)),
      child: _RateReviewView(
        orderDetailsList: orderDetailsList,
        deliveryMan: deliveryMan,
        orderID: orderID,
      ),
    );
  }
}

class _RateReviewView extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  final DeliveryMan? deliveryMan;
  final int? orderID;
  const _RateReviewView({
    required this.orderDetailsList,
    required this.deliveryMan,
    required this.orderID,
  });

  @override
  State<_RateReviewView> createState() => _RateReviewViewState();
}

class _RateReviewViewState extends State<_RateReviewView>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: (widget.deliveryMan == null || widget.orderDetailsList.isEmpty)
          ? 1
          : 2,
      initialIndex: 0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(title: 'rate_review'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: Column(
        children: [
          Center(
            child: Container(
              width: Dimensions.webMaxWidth,
              color: Theme.of(context).cardColor,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).textTheme.bodyLarge!.color,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 3,
                unselectedLabelStyle: robotoRegular.copyWith(
                  color: Theme.of(context).disabledColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
                labelStyle: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                ),
                tabs: widget.orderDetailsList.isNotEmpty
                    ? widget.deliveryMan != null
                          ? [
                              Tab(
                                text: widget.orderDetailsList.length > 1
                                    ? 'items'.tr
                                    : 'item'.tr,
                              ),
                              Tab(text: 'delivery_man'.tr),
                            ]
                          : [
                              Tab(
                                text: widget.orderDetailsList.length > 1
                                    ? 'items'.tr
                                    : 'item'.tr,
                              ),
                            ]
                    : [Tab(text: 'delivery_man'.tr)],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.orderDetailsList.isNotEmpty
                  ? widget.deliveryMan != null
                        ? [
                            ItemReviewWidget(
                              orderDetailsList: widget.orderDetailsList,
                            ),
                            DeliveryManReviewWidget(
                              deliveryMan: widget.deliveryMan,
                              orderID: widget.orderID.toString(),
                            ),
                          ]
                        : [
                            ItemReviewWidget(
                              orderDetailsList: widget.orderDetailsList,
                            ),
                          ]
                  : [
                      DeliveryManReviewWidget(
                        deliveryMan: widget.deliveryMan,
                        orderID: widget.orderID.toString(),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}
