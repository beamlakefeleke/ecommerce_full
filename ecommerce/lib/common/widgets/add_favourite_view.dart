import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_bloc.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_event.dart';
import 'package:ecommerce/features/favourite/presentation/bloc/favourite_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/item/domain/models/item_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';

class AddFavouriteView extends StatelessWidget {
  final Item item;
  final double? top, right;
  final double? left;
  const AddFavouriteView({super.key, required this.item, this.top = 15, this.right = 15, this.left});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, right: right, left: left,
      child: BlocBuilder<FavouriteBloc, FavouriteState>(builder: (context, state) {
        bool isWished = state.wishItemIdList.contains(item.id);
        return InkWell(
          onTap: () {
            if(AuthHelper.isLoggedIn()) {
              isWished ? getIt<FavouriteBloc>().add(FavouriteRemoved(id: item.id, isStore: false))
                  : getIt<FavouriteBloc>().add(FavouriteAdded(item: item, store: null, isStore: false));
            }else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
          },
          child: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).primaryColor, size: 20),
        );
      }),
    );
  }
}
