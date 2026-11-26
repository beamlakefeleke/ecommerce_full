import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/rider_state.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/search/presentation/widgets/custom_check_box_widget.dart';
import 'package:ecommerce/features/taxi_booking/select_map_location/widgets/service_type_card.dart';
import 'dotted_line.dart';
import 'pick_and_destination_address_info.dart';

class AvailableServiceInfo extends StatefulWidget {
  final Vehicles? vehicle;
  const AvailableServiceInfo({super.key, required this.vehicle});

  @override
  State<AvailableServiceInfo> createState() => _AvailableServiceInfoState();
}

class _AvailableServiceInfoState extends State<AvailableServiceInfo> {
  @override
  void initState() {
    super.initState();
    // Seed default trip date/time (legacy RiderController.initSetup).
    final bloc = context.read<RiderBloc>();
    final now = DateTime.now();
    bloc.add(TripDateSet(DateConverter.dateToReadableDate(now)));
    bloc.add(TripTimeSet(DateConverter.convertTimeToTimeDate(now)));
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      context.read<RiderBloc>().add(
        TripDateSet(DateConverter.dateToReadableDate(picked)),
      );
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat:
                getIt<SplashBloc>().state.configModel!.timeformat == '24',
          ),
          child: child!,
        );
      },
    );
    if (time != null && mounted) {
      context.read<RiderBloc>().add(
        TripTimeSet(
          DateConverter.convertTimeToTimeDate(
            DateTime(DateTime.now().year, 1, 1, time.hour, time.minute),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiderBloc, RiderState>(
      builder: (context, riderController) {
        return Container(
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).highlightColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeExtraSmall,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'trip_info'.tr,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                        const SizedBox(),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    ///pick up and destination address
                    SizedBox(
                      height: 90,
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 33,
                                width: 33,
                                alignment: Alignment.center,
                                decoration: riderContainerDecoration,
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(2),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 4,
                                      width: 4,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DottedLine(
                                lineLength: 20,
                                direction: Axis.vertical,
                                dashLength: 3,
                                dashGapLength: 1,
                                dashColor: Theme.of(context).primaryColor,
                              ),
                              Container(
                                height: 33,
                                width: 33,
                                alignment: Alignment.center,
                                decoration: riderContainerDecoration,
                                child: Icon(
                                  Icons.location_on_sharp,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: RideAddressInfo(
                                    title: riderController.fromAddress?.address,
                                    subTitle:
                                        '${riderController.fromAddress?.streetNumber != null ? '${riderController.fromAddress!.streetNumber!}, ' : ''}'
                                        '${riderController.fromAddress?.house ?? ''}',
                                    isInsideCity: true,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: RideAddressInfo(
                                    title: riderController.toAddress?.address,
                                    subTitle:
                                        '${riderController.toAddress?.streetNumber != null ? '${riderController.toAddress!.streetNumber!}, ' : ''}'
                                        '${riderController.toAddress?.house ?? ''}',
                                    isInsideCity: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Divider(color: Theme.of(context).primaryColor),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Row(
                      children: [
                        Container(
                          height: 33,
                          width: 33,
                          alignment: Alignment.center,
                          decoration: riderContainerDecoration,
                          child: Icon(
                            Icons.calendar_month,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'date'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                  Text(
                                    riderController.tripDate ?? 'not set yet',
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: riderController.tripDate != null
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: _pickDate,
                                child: Image.asset(
                                  Images.edit,
                                  width: 16.0,
                                  height: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Row(
                      children: [
                        Container(
                          height: 33,
                          width: 33,
                          alignment: Alignment.center,
                          decoration: riderContainerDecoration,
                          child: Icon(
                            Icons.access_time,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),

                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'time'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  ),
                                  Text(
                                    riderController.tripTime != null
                                        ? DateConverter.convertTimeToTime(
                                            riderController.tripTime!,
                                          )
                                        : 'not set yet',
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: riderController.tripTime != null
                                          ? Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: _pickTime,
                                child: Image.asset(
                                  Images.edit,
                                  width: 16.0,
                                  height: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    ///service card
                    Row(
                      children: [
                        ServiceTypeCard(
                          rentType: '${'hourly'.tr}(hr)',
                          rentPrice: "45",
                          isSelected: riderController.carType == 0,
                          onTap: () => context.read<RiderBloc>().add(
                            const CarTypeSet(0),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        ServiceTypeCard(
                          rentType: '${'distance_wise'.tr}(km)',
                          rentPrice: "35",
                          isSelected: riderController.carType == 1,
                          onTap: () => context.read<RiderBloc>().add(
                            const CarTypeSet(1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraSmall,
                ),
                child: CustomCheckBoxWidget(
                  title: 'return_same_location'.tr,
                  value: riderController.isReturnSameLocation,
                  onClick: () {
                    context.read<RiderBloc>().add(
                      ReturnSameLocationToggled(
                        !riderController.isReturnSameLocation,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                ),
                child: CustomButton(
                  buttonText: 'confirm_and_search_car'.tr,
                  onPressed: () {
                    if (riderController.tripDate == null ||
                        riderController.tripTime == null) {
                      showCustomSnackBar(
                        'please_set_your_rent_date_and_time'.tr,
                      );
                    } else {
                      UserInformationBody taxiBody = UserInformationBody(
                        from: riderController.fromAddress,
                        to: riderController.toAddress,
                        fareCategory: riderController.carType == 0
                            ? 'hourly'
                            : 'per_km',
                        distance: riderController.distance,
                        filterType: 'top_rated',
                        rentTime:
                            '${riderController.tripDate!} ${riderController.tripTime!}',
                        duration: riderController.duration,
                      );
                      if (widget.vehicle == null) {
                        Get.toNamed(
                          RouteHelper.getSelectCarScreenRoute(taxiBody),
                        );
                      } else {
                        Get.toNamed(
                          RouteHelper.getCarDetailsScreen(
                            widget.vehicle!,
                            taxiBody,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            ],
          ),
        );
      },
    );
  }
}
