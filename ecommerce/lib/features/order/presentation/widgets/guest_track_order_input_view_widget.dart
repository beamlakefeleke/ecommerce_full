import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce/features/language/presentation/bloc/language_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_state.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:ecommerce/helper/custom_validator.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/dimensions.dart';
import 'package:ecommerce/common/widgets/custom_button.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/common/widgets/custom_text_field.dart';
import 'package:ecommerce/common/widgets/footer_view.dart';

class GuestTrackOrderInputViewWidget extends StatefulWidget {
  const GuestTrackOrderInputViewWidget({super.key});

  @override
  State<GuestTrackOrderInputViewWidget> createState() =>
      _GuestTrackOrderInputViewWidgetState();
}

class _GuestTrackOrderInputViewWidgetState
    extends State<GuestTrackOrderInputViewWidget> {
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final FocusNode _orderFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  String? _countryDialCode;

  // Captured track args, used by the BlocListener to navigate on success.
  String? _pendingOrderId;
  String? _pendingNumber;

  @override
  void initState() {
    super.initState();

    _countryDialCode = getIt<AuthRepository>().getUserCountryCode().isNotEmpty
        ? getIt<AuthRepository>().getUserCountryCode()
        : CountryCode.fromCountryCode(
            getIt<SplashBloc>().state.configModel!.country!,
          ).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.isDesktop(context)
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(
              horizontal: Dimensions.radiusExtraLarge,
              vertical: Dimensions.paddingSizeLarge,
            ),
      child: Center(
        child: SingleChildScrollView(
          child: FooterView(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                children: [
                  SizedBox(
                    height: ResponsiveHelper.isDesktop(context) ? 100 : 0,
                  ),

                  CustomTextField(
                    titleText: 'order_id'.tr,
                    hintText: '',
                    controller: _orderIdController,
                    focusNode: _orderFocus,
                    nextFocus: _phoneFocus,
                    inputType: TextInputType.number,
                    showTitle: ResponsiveHelper.isDesktop(context),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  CustomTextField(
                    titleText: 'enter_phone_number'.tr,
                    hintText: '',
                    controller: _phoneNumberController,
                    focusNode: _phoneFocus,
                    inputType: TextInputType.phone,
                    inputAction: TextInputAction.done,
                    isPhone: true,
                    showTitle: ResponsiveHelper.isDesktop(context),
                    onCountryChanged: (CountryCode countryCode) {
                      _countryDialCode = countryCode.dialCode;
                    },
                    countryDialCode:
                        _countryDialCode ??
                        context.read<LanguageBloc>().state.locale.countryCode,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  BlocConsumer<OrderBloc, OrderState>(
                    listenWhen: (previous, current) =>
                        previous.responseModel != current.responseModel,
                    listener: (context, state) {
                      if (state.responseModel != null &&
                          state.responseModel!.isSuccess &&
                          _pendingOrderId != null) {
                        Get.toNamed(
                          RouteHelper.getGuestTrackOrderScreen(
                            _pendingOrderId!,
                            _pendingNumber!,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return CustomButton(
                        buttonText: 'track_order'.tr,
                        isLoading: state.isLoading,
                        width: ResponsiveHelper.isDesktop(context)
                            ? 300
                            : double.infinity,
                        onPressed: () async {
                          String phone = _phoneNumberController.text.trim();
                          String orderId = _orderIdController.text.trim();
                          String numberWithCountryCode =
                              _countryDialCode! + phone;
                          PhoneValid phoneValid =
                              await CustomValidator.isPhoneValid(
                                numberWithCountryCode,
                              );
                          numberWithCountryCode = phoneValid.phone;

                          if (orderId.isEmpty) {
                            showCustomSnackBar('please_enter_order_id'.tr);
                          } else if (phone.isEmpty) {
                            showCustomSnackBar('enter_phone_number'.tr);
                          } else if (!phoneValid.isValid) {
                            showCustomSnackBar('invalid_phone_number'.tr);
                          } else {
                            _pendingOrderId = orderId;
                            _pendingNumber = numberWithCountryCode;
                            if (context.mounted) {
                              context.read<OrderBloc>().add(
                                OrderTrackRequested(
                                  orderId: orderId,
                                  contactNumber: numberWithCountryCode,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
