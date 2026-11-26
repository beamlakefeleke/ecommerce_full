import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_state.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';

class FilterCarSortingWidget extends StatelessWidget {
  const FilterCarSortingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarSelectionBloc, CarSelectionState>(
      builder: (context, state) {
        return Column(
          children: [
            _myRadioButton(
              context: context,
              sortByIndex: state.sortByIndex,
              title: 'top_rated'.tr,
              value: 0,
              onChanged: () {
                context.read<CarSelectionBloc>().add(const SortBySelected(0));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _myRadioButton({
    required BuildContext context,
    required int sortByIndex,
    required String title,
    int? value,
    Function? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: InkWell(
        onTap: onChanged as void Function()?,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: sortByIndex == value
                  ? robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)
                  : robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
            ),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sortByIndex == value
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
