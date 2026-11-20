import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/search/presentation/bloc/search_bloc.dart';
import 'package:ecommerce/features/search/presentation/bloc/search_state.dart';
import 'package:ecommerce/common/widgets/item_view.dart';
import 'package:ecommerce/common/widgets/web_item_view.dart';

class ItemViewWidget extends StatelessWidget {
  final bool isItem;
  const ItemViewWidget({super.key, required this.isItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, searchController) {
          return SingleChildScrollView(
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: ResponsiveHelper.isDesktop(context)
                    ? WebItemsView(
                        isStore: isItem,
                        items: searchController.searchItemList,
                        stores: searchController.searchStoreList,
                      )
                    : ItemsView(
                        isStore: isItem,
                        items: searchController.searchItemList,
                        stores: searchController.searchStoreList,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
