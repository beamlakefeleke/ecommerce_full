import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';

class FilterView extends StatelessWidget {
  final StoreState storeState;
  const FilterView({super.key, required this.storeState});

  @override
  Widget build(BuildContext context) {
    return storeState.storeModel != null
        ? PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'all',
                  child: Text(
                    'all'.tr,
                    style: robotoMedium.copyWith(
                      color: storeState.storeType == 'all'
                          ? Theme.of(context).textTheme.bodyLarge!.color
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'take_away',
                  child: Text(
                    'take_away'.tr,
                    style: robotoMedium.copyWith(
                      color: storeState.storeType == 'take_away'
                          ? Theme.of(context).textTheme.bodyLarge!.color
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'delivery',
                  child: Text(
                    'delivery'.tr,
                    style: robotoMedium.copyWith(
                      color: storeState.storeType == 'delivery'
                          ? Theme.of(context).textTheme.bodyLarge!.color
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ),
              ];
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
              ),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            onSelected: (dynamic value) =>
                getIt<StoreBloc>().add(StoreTypeChanged(value)),
          )
        : const SizedBox();
  }
}
