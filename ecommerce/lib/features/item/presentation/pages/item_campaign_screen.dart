import 'package:ecommerce/features/item/presentation/bloc/campaign_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';
import 'package:ecommerce/common/widgets/item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/menu_drawer.dart';

class ItemCampaignScreen extends StatefulWidget {
  final bool isJustForYou;
  const ItemCampaignScreen({super.key, required this.isJustForYou});

  @override
  State<ItemCampaignScreen> createState() => _ItemCampaignScreenState();
}

class _ItemCampaignScreenState extends State<ItemCampaignScreen> {
  @override
  void initState() {
    super.initState();

    context.read<CampaignBloc>().add(const ItemCampaignListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isJustForYou ? 'just_for_you'.tr : 'campaigns'.tr,
      ),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        child: FooterView(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: BlocBuilder<CampaignBloc, CampaignState>(
              builder: (context, campController) {
                return ItemsView(
                  isStore: false,
                  items: campController.itemCampaignList,
                  stores: null,
                  isCampaign: true,
                  noDataText: 'no_campaign_found'.tr,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
