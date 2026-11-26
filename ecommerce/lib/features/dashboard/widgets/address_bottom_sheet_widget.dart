import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/address_widget.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_event.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_bloc.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_event.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_state.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_bloc.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_event.dart';
import 'package:ecommerce/features/location/presentation/bloc/location_state.dart';
import 'package:ecommerce/features/location/presentation/helper/location_helper.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_loader.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/location/presentation/pages/pick_map_screen.dart';

class AddressBottomSheetWidget extends StatefulWidget {
  final bool fromDialog;
  const AddressBottomSheetWidget({super.key, this.fromDialog = false});

  @override
  State<AddressBottomSheetWidget> createState() =>
      _AddressBottomSheetWidgetState();
}

class _AddressBottomSheetWidgetState extends State<AddressBottomSheetWidget> {
  @override
  void initState() {
    super.initState();
    if (AuthHelper.isLoggedIn()) {
      context.read<AddressBloc>().add(const AddressListRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool fromDialog = widget.fromDialog;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            fromDialog
                ? Dimensions.paddingSizeDefault
                : Dimensions.paddingSizeExtraLarge,
          ),
          topRight: Radius.circular(
            fromDialog
                ? Dimensions.paddingSizeDefault
                : Dimensions.paddingSizeExtraLarge,
          ),
          bottomLeft: Radius.circular(
            fromDialog ? Dimensions.paddingSizeDefault : 0,
          ),
          bottomRight: Radius.circular(
            fromDialog ? Dimensions.paddingSizeDefault : 0,
          ),
        ),
      ),
      child: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, addressState) {
          AddressModel? selectedAddress =
              AddressHelper.getUserAddressFromSharedPref();
          final List<Address> addressList = addressState.addresses;
          final bool addressLoaded =
              addressState.status == AddressStatus.loaded ||
              addressState.status == AddressStatus.error;
          final bool addressListEmpty = addressLoaded && addressList.isEmpty;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              fromDialog
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            getIt<SplashBloc>().add(
                              const SplashWebSuggestedLocationSaved(true),
                            );
                            Get.back();
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    )
                  : const SizedBox(),

              fromDialog
                  ? const SizedBox()
                  : Center(
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          bottom: Dimensions.paddingSizeDefault,
                        ),
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).highlightColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeExtraSmall,
                          ),
                        ),
                      ),
                    ),

              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: fromDialog ? 50 : Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${'hey_welcome_back'.tr}\n${'which_location_do_you_want_to_select'.tr}',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Center(
                        child: addressListEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    Images.noAddress,
                                    width: fromDialog ? 180 : 150,
                                  ),

                                  fromDialog
                                      ? const SizedBox(
                                          height: Dimensions.paddingSizeDefault,
                                        )
                                      : const SizedBox(),
                                  SizedBox(
                                    width: 280,
                                    child: Text(
                                      'you_dont_have_any_saved_address_yet'.tr,
                                      textAlign: TextAlign.center,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),

                      addressListEmpty
                          ? const SizedBox(height: Dimensions.paddingSizeLarge)
                          : const SizedBox(),

                      (addressLoaded && fromDialog)
                          ? const SizedBox(
                              height: Dimensions.paddingSizeDefault,
                            )
                          : const SizedBox(),
                      Align(
                        alignment: addressListEmpty && !fromDialog
                            ? Alignment.center
                            : Alignment.topCenter,
                        child: TextButton.icon(
                          onPressed: () {
                            LocationHelper.checkPermission(() async {
                              Get.dialog(
                                const CustomLoader(),
                                barrierDismissible: false,
                              );
                              final locationBloc = getIt<LocationBloc>();
                              locationBloc.add(
                                const CurrentLocationRequested(
                                  fromAddress: true,
                                ),
                              );
                              await locationBloc.stream.firstWhere(
                                (s) => !s.loading,
                              );
                              final LocationState state = locationBloc.state;
                              final AddressModel address = locationBloc
                                  .buildAddressModel(fromAddress: true);
                              final bool isSuccess =
                                  state.lastZoneResult?.isSuccess ?? false;

                              if (isSuccess) {
                                if (ResponsiveHelper.isDesktop(Get.context)) {
                                  getIt<SplashBloc>().add(
                                    const SplashWebSuggestedLocationSaved(true),
                                  );
                                }
                                LocationHelper.saveAddressAndNavigate(
                                  address,
                                  false,
                                  '',
                                  false,
                                  ResponsiveHelper.isDesktop(Get.context),
                                );
                              } else {
                                Get.back();
                                if (ResponsiveHelper.isDesktop(Get.context)) {
                                  getIt<SplashBloc>().add(
                                    const SplashWebSuggestedLocationSaved(true),
                                  );
                                  showGeneralDialog(
                                    context: Get.context!,
                                    pageBuilder: (_, _, _) {
                                      return const SizedBox(
                                        height: 300,
                                        width: 300,
                                        child: PickMapScreen(
                                          fromSignUp: false,
                                          canRoute: false,
                                          fromAddAddress: true,
                                          route: null,
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  Get.toNamed(
                                    RouteHelper.getPickMapRoute(
                                      RouteHelper.accessLocation,
                                      false,
                                    ),
                                  );
                                }
                                showCustomSnackBar(
                                  'service_not_available_in_current_location'
                                      .tr,
                                );
                              }
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Dimensions.radiusDefault),
                              ),
                            ),
                            fixedSize: const Size(200, 40),
                            backgroundColor: addressListEmpty
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                          ),
                          icon: Icon(
                            Icons.my_location,
                            color: addressListEmpty
                                ? Theme.of(context).cardColor
                                : Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            'use_current_location'.tr,
                            style: fromDialog
                                ? robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: addressListEmpty
                                        ? Theme.of(context).cardColor
                                        : Theme.of(context).primaryColor,
                                  )
                                : robotoMedium.copyWith(
                                    color: addressListEmpty
                                        ? Theme.of(context).cardColor
                                        : Theme.of(context).primaryColor,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      addressLoaded
                          ? addressList.isNotEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: Dimensions.paddingSizeSmall,
                                    ),
                                    child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: addressList.length > 5
                                          ? 5
                                          : addressList.length,
                                      itemBuilder: (context, index) {
                                        final AddressModel address =
                                            AddressModel.fromEntity(
                                              addressList[index],
                                            );
                                        bool selected = false;
                                        if (selectedAddress != null &&
                                            selectedAddress.id == address.id) {
                                          selected = true;
                                        }
                                        return Center(
                                          child: SizedBox(
                                            width: 700,
                                            child: AddressWidget(
                                              address: address,
                                              fromAddress: false,
                                              isSelected: selected,
                                              fromDashBoard: true,
                                              onTap: () {
                                                Get.dialog(
                                                  const CustomLoader(),
                                                  barrierDismissible: false,
                                                );
                                                LocationHelper.saveAddressAndNavigate(
                                                  address,
                                                  false,
                                                  null,
                                                  false,
                                                  ResponsiveHelper.isDesktop(
                                                    context,
                                                  ),
                                                );

                                                getIt<SplashBloc>().add(
                                                  const SplashWebSuggestedLocationSaved(
                                                    true,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const SizedBox()
                          : const Center(child: CircularProgressIndicator()),

                      SizedBox(
                        height: addressListEmpty
                            ? 0
                            : Dimensions.paddingSizeSmall,
                      ),

                      addressLoaded && addressList.isNotEmpty
                          ? TextButton.icon(
                              onPressed: () {
                                getIt<SplashBloc>().add(
                                  const SplashWebSuggestedLocationSaved(true),
                                );
                                Get.toNamed(
                                  RouteHelper.getAddAddressRoute(
                                    false,
                                    false,
                                    0,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_circle_outline_sharp),
                              label: Text(
                                'add_new_address'.tr,
                                style: robotoMedium.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
