import 'package:ecommerce/features/store/presentation/bloc/store_bloc.dart';
import 'package:ecommerce/features/store/presentation/bloc/store_state.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreSortingButton extends StatelessWidget {
  final String storeType;
  final String storeTypeText;
  const StoreSortingButton({
    super.key,
    required this.storeType,
    required this.storeTypeText,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraSmall,
            vertical: Dimensions.paddingSizeExtraSmall,
          ),
          decoration: BoxDecoration(
            color: state.storeType == storeType
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(
              color: state.storeType == storeType
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                state.storeType == storeType
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: state.storeType == storeType
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                size: 16,
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                storeTypeText,
                style: robotoMedium.copyWith(
                  color: state.storeType == storeType
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

