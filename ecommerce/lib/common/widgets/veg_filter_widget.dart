import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/item/presentation/bloc/item_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VegFilterWidget extends StatelessWidget {
  final String? type;
  final bool fromAppBar;
  final Function(String value)? onSelected;
  const VegFilterWidget({
    super.key,
    required this.type,
    required this.onSelected,
    this.fromAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool ltr = getIt<LanguageBloc>().state.isLtr;
    List<PopupMenuEntry> entryList = [];
    for (int i = 0; i < ItemState.itemTypeList.length; i++) {
      entryList.add(
        PopupMenuItem<int>(
          value: i,
          child: Row(
            children: [
              ItemState.itemTypeList[i] == type
                  ? Icon(
                      Icons.radio_button_checked_sharp,
                      color: Theme.of(context).primaryColor,
                    )
                  : Icon(
                      Icons.radio_button_off,
                      color: Theme.of(context).disabledColor,
                    ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Text(
                ItemState.itemTypeList[i].tr,
                style: robotoMedium.copyWith(
                  color: ItemState.itemTypeList[i] == type
                      ? Theme.of(context).textTheme.bodyMedium!.color
                      : Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return (getIt<SplashBloc>()
                .state
                .configModel!
                .moduleConfig!
                .module!
                .vegNonVeg! &&
            getIt<SplashBloc>().state.configModel!.toggleVegNonVeg!)
        ? Padding(
            padding: fromAppBar
                ? EdgeInsets.zero
                : EdgeInsets.only(
                    left: ltr ? Dimensions.paddingSizeSmall : 0,
                    right: ltr ? 0 : Dimensions.paddingSizeSmall,
                  ),
            child: PopupMenuButton<dynamic>(
              offset: const Offset(-20, 20),
              itemBuilder: (BuildContext context) => entryList,
              onSelected: (dynamic value) =>
                  onSelected!(ItemState.itemTypeList[value]),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(Dimensions.radiusDefault),
                ),
              ),
              child: Container(
                decoration: fromAppBar
                    ? const BoxDecoration()
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                      ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: Icon(
                  Icons.filter_list,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
