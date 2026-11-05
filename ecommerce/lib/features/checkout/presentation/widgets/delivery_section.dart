import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/common/widgets/address_widget.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_dropdown.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/features/checkout/presentation/widgets/guest_delivery_address.dart';

class DeliverySection extends StatelessWidget {
  final CheckoutState checkoutController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final TextEditingController streetNumberController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final FocusNode streetNode;
  final FocusNode houseNode;
  final FocusNode floorNode;
  const DeliverySection({
    super.key,
    required this.checkoutController,
    required this.address,
    required this.addressList,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
    required this.streetNumberController,
    required this.houseController,
    required this.floorController,
    required this.streetNode,
    required this.houseNode,
    required this.floorNode,
  });

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Column(
      children: [
        isGuestLoggedIn
            ? GuestDeliveryAddress(
                checkoutController: checkoutController,
                guestNumberNode: guestNumberNode,
                guestNameTextEditingController: guestNameTextEditingController,
                guestNumberTextEditingController:
                    guestNumberTextEditingController,
                guestEmailController: guestEmailController,
                guestEmailNode: guestEmailNode,
              )
            : !takeAway
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('deliver_to'.tr, style: robotoMedium),
                        TextButton.icon(
                          onPressed: () async {
                            var address = await Get.toNamed(
                              RouteHelper.getAddAddressRoute(
                                true,
                                false,
                                checkoutController.store!.zoneId,
                              ),
                            );
                            if (address != null) {
                              context.read<CheckoutBloc>().add(
                                CheckoutDistanceRequested(
                                  origin: LatLng(
                                    double.parse(address.latitude),
                                    double.parse(address.longitude),
                                  ),
                                  destination: LatLng(
                                    double.parse(
                                      checkoutController.store!.latitude!,
                                    ),
                                    double.parse(
                                      checkoutController.store!.longitude!,
                                    ),
                                  ),
                                ),
                              );
                              streetNumberController.text =
                                  address.streetNumber ?? '';
                              houseController.text = address.house ?? '';
                              floorController.text = address.floor ?? '';
                            }
                          },
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(
                            'add_new'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      ],
                    ),

                    isDesktop
                        ? Stack(
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  minHeight: 90,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                ),
                                child: Container(
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: AddressWidget(
                                    address:
                                        address[checkoutController
                                            .addressIndex!],
                                    fromAddress: false,
                                    fromCheckout: true,
                                  ),
                                ),
                              ),

                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: PopupMenuButton(
                                    position: PopupMenuPosition.under,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    onSelected: (value) {},
                                    itemBuilder: (context) => List.generate(
                                      address.length,
                                      (index) => PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            context.read<CheckoutBloc>().add(
                                              CheckoutDistanceRequested(
                                                origin: LatLng(
                                                  double.parse(
                                                    address[index].latitude!,
                                                  ),
                                                  double.parse(
                                                    address[index].longitude!,
                                                  ),
                                                ),
                                                destination: LatLng(
                                                  double.parse(
                                                    checkoutController
                                                        .store!
                                                        .latitude!,
                                                  ),
                                                  double.parse(
                                                    checkoutController
                                                        .store!
                                                        .longitude!,
                                                  ),
                                                ),
                                              ),
                                            );
                                            context.read<CheckoutBloc>().add(
                                              CheckoutAddressIndexSet(index),
                                            );
                                            streetNumberController.text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .streetNumber ??
                                                '';
                                            houseController.text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .house ??
                                                '';
                                            floorController.text =
                                                address[checkoutController
                                                        .addressIndex!]
                                                    .floor ??
                                                '';
                                            Navigator.pop(context);
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 20,
                                                width: 20,
                                                padding: const EdgeInsets.all(
                                                  3,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        checkoutController
                                                                .addressIndex ==
                                                            index
                                                        ? Theme.of(
                                                            context,
                                                          ).primaryColor
                                                        : Theme.of(
                                                            context,
                                                          ).disabledColor,
                                                  ),
                                                ),
                                                child:
                                                    checkoutController
                                                            .addressIndex ==
                                                        index
                                                    ? Container(
                                                        height: 15,
                                                        width: 15,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                            ),
                                                      )
                                                    : const SizedBox(),
                                              ),

                                              const SizedBox(
                                                width:
                                                    Dimensions.paddingSizeSmall,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      address[index]
                                                          .addressType!
                                                          .tr,
                                                      style: robotoMedium
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                    ),
                                                    const SizedBox(
                                                      height: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),

                                                    Text(
                                                      address[index].address!,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: robotoRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeExtraSmall,
                                                        color: Theme.of(
                                                          context,
                                                        ).disabledColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            constraints: BoxConstraints(
                              minHeight: ResponsiveHelper.isDesktop(context)
                                  ? 90
                                  : 75,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                            ),
                            child: CustomDropdown<int>(
                              onChange: (int? value, int index) {
                                context.read<CheckoutBloc>().add(
                                  CheckoutDistanceRequested(
                                    origin: LatLng(
                                      double.parse(address[index].latitude!),
                                      double.parse(address[index].longitude!),
                                    ),
                                    destination: LatLng(
                                      double.parse(
                                        checkoutController.store!.latitude!,
                                      ),
                                      double.parse(
                                        checkoutController.store!.longitude!,
                                      ),
                                    ),
                                  ),
                                );
                                context.read<CheckoutBloc>().add(
                                  CheckoutAddressIndexSet(index),
                                );

                                streetNumberController.text =
                                    address[checkoutController.addressIndex!]
                                        .streetNumber ??
                                    '';
                                houseController.text =
                                    address[checkoutController.addressIndex!]
                                        .house ??
                                    '';
                                floorController.text =
                                    address[checkoutController.addressIndex!]
                                        .floor ??
                                    '';
                              },
                              dropdownButtonStyle: DropdownButtonStyle(
                                height: 45,
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                  horizontal: Dimensions.paddingSizeExtraSmall,
                                ),
                                primaryColor: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color,
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
                              items: addressList,
                              child: AddressWidget(
                                address:
                                    address[checkoutController.addressIndex!],
                                fromAddress: false,
                                fromCheckout: true,
                              ),
                            ),
                          ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    !isDesktop
                        ? CustomTextField(
                            hintText: ' ',
                            titleText: 'street_number'.tr,
                            inputType: TextInputType.streetAddress,
                            focusNode: streetNode,
                            nextFocus: houseNode,
                            controller: streetNumberController,
                          )
                        : const SizedBox(),
                    SizedBox(
                      height: !isDesktop ? Dimensions.paddingSizeLarge : 0,
                    ),

                    Row(
                      children: [
                        isDesktop
                            ? Expanded(
                                child: CustomTextField(
                                  showTitle: true,
                                  hintText: ' ',
                                  titleText: 'street_number'.tr,
                                  inputType: TextInputType.streetAddress,
                                  focusNode: streetNode,
                                  nextFocus: houseNode,
                                  controller: streetNumberController,
                                ),
                              )
                            : const SizedBox(),
                        SizedBox(
                          width: isDesktop ? Dimensions.paddingSizeSmall : 0,
                        ),

                        Expanded(
                          child: CustomTextField(
                            showTitle: isDesktop,
                            hintText: ' ',
                            titleText: 'house'.tr,
                            inputType: TextInputType.text,
                            focusNode: houseNode,
                            nextFocus: floorNode,
                            controller: houseController,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: CustomTextField(
                            showTitle: isDesktop,
                            hintText: ' ',
                            titleText: 'floor'.tr,
                            inputType: TextInputType.text,
                            focusNode: floorNode,
                            inputAction: TextInputAction.done,
                            controller: floorController,
                          ),
                        ),
                        //const SizedBox(height: Dimensions.paddingSizeLarge),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
