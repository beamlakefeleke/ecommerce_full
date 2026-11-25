import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/features/auth/presentation/bloc/registration_bloc.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_dropdown.dart';

class ModuleViewWidget extends StatelessWidget {
  const ModuleViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, storeRegController) {
        List<int> moduleIndexList = [];
        List<DropdownItem<int>> moduleList = [];
        if (storeRegController.moduleList != null &&
            storeRegController.moduleList!.isNotEmpty) {
          for (
            int index = 0;
            index < storeRegController.moduleList!.length;
            index++
          ) {
            if (storeRegController.moduleList![index].moduleType != 'parcel') {
              moduleIndexList.add(index);
              moduleList.add(
                DropdownItem<int>(
                  value: index,
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${storeRegController.moduleList![index].moduleName}',
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        }
        return storeRegController.moduleList != null
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 0.3,
                  ),
                ),
                child: CustomDropdown<int>(
                  onChange: (int? value, int index) {
                    context.read<RegistrationBloc>().add(
                      RegistrationModuleIndexSelected(value),
                    );
                  },
                  dropdownButtonStyle: DropdownButtonStyle(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall,
                      horizontal: Dimensions.paddingSizeExtraSmall,
                    ),
                    primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  dropdownStyle: DropdownStyle(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeExtraSmall,
                    ),
                  ),
                  items: moduleList,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text('select_module_type'.tr),
                  ),
                ),
              )
            : Center(child: Text('not_available_module'.tr));
      },
    );
  }
}
