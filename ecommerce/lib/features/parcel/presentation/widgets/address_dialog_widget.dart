import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/address_widget.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_state.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_bloc.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_event.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/no_data_screen.dart';

class AddressDialogWidget extends StatelessWidget {
  final Function(AddressModel address) onTap;
  const AddressDialogWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      insetPadding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: context.width * 0.8,
        height: context.height * 0.7,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => Get.back(),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, addressState) {
                    final bool loaded =
                        addressState.status == AddressStatus.loaded;
                    final List<AddressModel> addressList = addressState
                        .addresses
                        .map((e) => AddressModel.fromEntity(e))
                        .toList();
                    return AuthHelper.isLoggedIn()
                        ? loaded
                              ? addressList.isNotEmpty
                                    ? ListView.builder(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemCount: addressList.length,
                                        itemBuilder: (context, index) {
                                          if (AddressHelper.getUserAddressFromSharedPref()!
                                              .zoneIds!
                                              .contains(
                                                addressList[index].zoneId,
                                              )) {
                                            return Center(
                                              child: SizedBox(
                                                width: 700,
                                                child: AddressWidget(
                                                  address: addressList[index],
                                                  fromAddress: false,
                                                  onTap: () {
                                                    onTap(addressList[index]);

                                                    final AddressModel
                                                    address = AddressModel(
                                                      address:
                                                          addressList[index]
                                                              .address,
                                                      additionalAddress:
                                                          addressList[index]
                                                              .additionalAddress,
                                                      addressType:
                                                          addressList[index]
                                                              .addressType,
                                                      contactPersonName:
                                                          addressList[index]
                                                              .contactPersonName,
                                                      contactPersonNumber:
                                                          addressList[index]
                                                              .contactPersonNumber,
                                                      latitude:
                                                          addressList[index]
                                                              .latitude,
                                                      longitude:
                                                          addressList[index]
                                                              .longitude,
                                                      method: addressList[index]
                                                          .method,
                                                      zoneId: addressList[index]
                                                          .zoneId,
                                                      id: addressList[index].id,
                                                    );
                                                    if (context
                                                        .read<ParcelBloc>()
                                                        .state
                                                        .isSender) {
                                                      context
                                                          .read<ParcelBloc>()
                                                          .add(
                                                            PickupAddressSet(
                                                              address,
                                                            ),
                                                          );
                                                    } else {
                                                      context
                                                          .read<ParcelBloc>()
                                                          .add(
                                                            DestinationAddressSet(
                                                              address,
                                                            ),
                                                          );
                                                    }
                                                    Get.back();
                                                  },
                                                ),
                                              ),
                                            );
                                          } else {
                                            return const SizedBox();
                                          }
                                        },
                                      )
                                    : NoDataScreen(
                                        text: 'no_saved_address_found'.tr,
                                      )
                              : const Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                        : const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
