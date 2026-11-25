import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/auth/presentation/bloc/registration_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';

class PassViewWidget extends StatelessWidget {
  final bool forStoreRegistration;
  const PassViewWidget({super.key, this.forStoreRegistration = true});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, regState) {
        return Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: Wrap(
            children: [
              view('8_or_more_character'.tr, regState.lengthCheck),
              view('1_number'.tr, regState.numberCheck),
              view('1_upper_case'.tr, regState.uppercaseCheck),
              view('1_lower_case'.tr, regState.lowercaseCheck),
              view('1_special_character'.tr, regState.spatialCheck),
            ],
          ),
        );
      },
    );
  }

  Widget view(String title, bool done) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check : Icons.clear,
            color: done ? Colors.green : Colors.red,
            size: 12,
          ),
          Text(
            title,
            style: robotoRegular.copyWith(
              color: done ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
