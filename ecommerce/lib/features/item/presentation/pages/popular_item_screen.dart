import 'package:ecommerce/features/item/presentation/bloc/item_bloc.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class PopularItemScreen extends StatefulWidget {
  final bool isPopular;
  final bool isSpecial;
  const PopularItemScreen({
    super.key,
    required this.isPopular,
    required this.isSpecial,
  });

  @override
  State<PopularItemScreen> createState() => _PopularItemScreenState();
}

class _PopularItemScreenState extends State<PopularItemScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    final itemBloc = context.read<ItemBloc>();
    if (widget.isPopular) {
      itemBloc.add(
        PopularItemsRequested(reload: true, type: itemBloc.state.popularType),
      );
    } else if (widget.isSpecial) {
      itemBloc.add(
        DiscountedItemsRequested(
          reload: true,
          type: itemBloc.state.discountedType,
        ),
      );
    } else {
      itemBloc.add(
        ReviewedItemsRequested(reload: true, type: itemBloc.state.reviewedType),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isShop =
        Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;

    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, itemController) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: CustomAppBar(
            key: scaffoldKey,
            title: widget.isPopular
                ? isShop
                      ? 'most_popular_products'.tr
                      : 'most_popular_items'.tr
                : widget.isSpecial
                ? 'special_offer'.tr
                : 'best_reviewed_item'.tr,
            showCart: true,
            type: widget.isPopular
                ? itemController.popularType
                : widget.isSpecial
                ? itemController.discountedType
                : itemController.reviewedType,
            onVegFilterTap: (String type) {
              if (widget.isPopular) {
                context.read<ItemBloc>().add(
                  PopularItemsRequested(reload: true, type: type),
                );
              } else if (widget.isSpecial) {
                context.read<ItemBloc>().add(
                  DiscountedItemsRequested(reload: true, type: type),
                );
              } else {
                context.read<ItemBloc>().add(
                  ReviewedItemsRequested(reload: true, type: type),
                );
              }
            },
          ),
        );
      },
    );
  }
}
