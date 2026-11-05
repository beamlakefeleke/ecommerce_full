import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class FavItemViewWidget extends StatelessWidget {
  final bool isStore;
  final bool isSearch;
  const FavItemViewWidget({
    super.key,
    required this.isStore,
    this.isSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FavouriteBloc, FavouriteState>(
        builder: (context, favouriteController) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<FavouriteBloc>().add(const FavouriteListRequested());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveHelper.isDesktop(context) ? 0 : 80.0,
                    ),
                    child: ItemsView(
                      isStore: isStore,
                      items: favouriteController.wishItemList,
                      stores: favouriteController.wishStoreList,
                      noDataText: 'no_wish_data_found'.tr,
                      isFeatured: true,
                    ),
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
