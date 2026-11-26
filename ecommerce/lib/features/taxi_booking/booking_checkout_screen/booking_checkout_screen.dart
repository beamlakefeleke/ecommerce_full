import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_bloc.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/booking_checkout_state.dart';
import 'package:ecommerce/features/profile/domain/models/user_information_body.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';
import 'package:ecommerce/helper/price_converter.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/util/images.dart';
import 'package:ecommerce/util/styles.dart';
import 'package:ecommerce/common/widgets/custom_app_bar.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/payment_complete_dialog.dart';
import 'package:ecommerce/features/taxi_booking/booking_checkout_screen/widgets/booking_checkout_stepper.dart';
import 'widgets/booking_complete_info.dart';
import 'widgets/booking_details_info.dart';
import 'widgets/select_payment_method.dart';

class BookingCheckoutScreen extends StatelessWidget {
  final Vehicles vehicle;
  final UserInformationBody filterBody;
  const BookingCheckoutScreen({
    super.key,
    required this.vehicle,
    required this.filterBody,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingCheckoutBloc>(
      create: (_) => getIt<BookingCheckoutBloc>(),
      child: _BookingCheckoutView(vehicle: vehicle, filterBody: filterBody),
    );
  }
}

class _BookingCheckoutView extends StatelessWidget {
  final Vehicles vehicle;
  final UserInformationBody filterBody;
  const _BookingCheckoutView({required this.vehicle, required this.filterBody});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'checkout'.tr),
      body: BlocListener<BookingCheckoutBloc, BookingCheckoutState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == TripActionStatus.success) {
            Get.dialog(
              PaymentCompleteDialog(
                icon: Images.completeChecked,
                title: 'booking_payment_is_done_successfully'.tr,
                description: 'to_know_others_information'.tr,
                shortDescription: 'please_call_or_chat_with_car_provider'.tr,
                onYesPressed: () {
                  Get.back();
                  context.read<BookingCheckoutBloc>().add(
                    const CheckoutPageChanged(PageState.complete),
                  );
                },
              ),
            );
          } else if (state.actionStatus == TripActionStatus.failure) {
            showCustomSnackBar(
              state.actionMessage ?? 'something_went_wrong'.tr,
            );
          }
        },
        child: Column(
          children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),

            ///payment status section
            BlocBuilder<BookingCheckoutBloc, BookingCheckoutState>(
              builder: (context, state) {
                return BookingCheckoutStepper(
                  pageState: state.currentPage.name,
                );
              },
            ),

            BlocBuilder<BookingCheckoutBloc, BookingCheckoutState>(
              builder: (context, state) {
                if (state.currentPage == PageState.orderDetails) {
                  return Expanded(
                    child: BookingDetailsInfo(
                      vehicle: vehicle,
                      filterBody: filterBody,
                    ),
                  );
                }
                if (state.currentPage == PageState.payment) {
                  return const SelectPaymentMethod();
                }
                return Expanded(
                  child: BookingCompleteInfo(
                    vehicle: vehicle,
                    filterBody: filterBody,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomSheet: BlocBuilder<BookingCheckoutBloc, BookingCheckoutState>(
        builder: (context, state) {
          double subTotalPrice =
              filterBody.distance! *
              (filterBody.fareCategory == 'hourly'
                  ? vehicle.insidePerHourCharge!
                  : vehicle.insidePerKmCharge!);
          double vatTax = vehicle.provider!.tax!.toDouble();
          double serviceFee = vehicle.provider!.comission!.toDouble();

          double totalPrice =
              (subTotalPrice - state.couponDiscount) + vatTax + serviceFee;
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: kElevationToShadow[4],
            ),
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (state.currentPage == PageState.orderDetails)
                    SizedBox(
                      width: context.width / 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'total'.tr,
                            style: robotoRegular.copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color!.withOpacity(.4),
                            ),
                          ),
                          Text(
                            PriceConverter.convertPrice(totalPrice),
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: !state.isLoading
                        ? CustomButton(
                            width: state.currentPage == PageState.orderDetails
                                ? 140
                                : Get.width,
                            fontSize: Dimensions.fontSizeDefault,
                            onPressed: () {
                              final bloc = context.read<BookingCheckoutBloc>();
                              if (state.currentPage == PageState.payment) {
                                bloc.add(
                                  TripPlaced(
                                    filterBody: filterBody,
                                    vehicle: vehicle,
                                  ),
                                );
                              } else if (state.currentPage ==
                                  PageState.complete) {
                                Get.toNamed(RouteHelper.getOrderStatusScreen());
                              } else {
                                bloc.add(
                                  const CheckoutPageChanged(PageState.payment),
                                );
                              }
                            },
                            buttonText: state.currentPage == PageState.complete
                                ? 'check_order_status'.tr
                                : state.currentPage == PageState.payment
                                ? 'confirm'.tr
                                : 'rent_this_car'.tr,
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
