import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:ecommerce/features/checkout/domain/models/distance_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:ecommerce/features/location/controllers/location_controller.dart';
import 'package:ecommerce/features/location/domain/models/zone_response_model.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_parcel_category_usecase.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_parcel_instruction_usecase.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_place_details_usecase.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_video_content_usecase.dart';
import 'package:ecommerce/features/parcel/domain/usecases/get_why_choose_usecase.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_event.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_state.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/helper/address_helper.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:universal_html/html.dart' as html;

class ParcelBloc extends Bloc<ParcelEvent, ParcelState> {
  final GetParcelCategoryUseCase getParcelCategoryUseCase;
  final GetWhyChooseUseCase getWhyChooseUseCase;
  final GetVideoContentUseCase getVideoContentUseCase;
  final GetParcelInstructionUseCase getParcelInstructionUseCase;
  final GetPlaceDetailsUseCase getPlaceDetailsUseCase;
  final CheckoutRepositoryInterface checkoutRepositoryInterface;

  ParcelBloc({
    required this.getParcelCategoryUseCase,
    required this.getWhyChooseUseCase,
    required this.getVideoContentUseCase,
    required this.getParcelInstructionUseCase,
    required this.getPlaceDetailsUseCase,
    required this.checkoutRepositoryInterface,
  }) : super(const ParcelState()) {
    on<GetParcelCategoryListEvent>(_onGetParcelCategoryList);
    on<GetWhyChooseDetailsEvent>(_onGetWhyChooseDetails);
    on<GetVideoContentDetailsEvent>(_onGetVideoContentDetails);
    on<GetParcelInstructionEvent>(_onGetParcelInstruction);
    on<GetOfflineMethodListEvent>(_onGetOfflineMethodList);
    on<GetDmTipMostTappedEvent>(_onGetDmTipMostTapped);
    on<SetPickupAddressEvent>(_onSetPickupAddress);
    on<SetDestinationAddressEvent>(_onSetDestinationAddress);
    on<SetIsPickedUpEvent>(_onSetIsPickedUp);
    on<SetIsSenderEvent>(_onSetIsSender);
    on<SetLocationFromPlaceEvent>(_onSetLocationFromPlace);
    on<GetDistanceEvent>(_onGetDistance);
    on<SetPayerIndexEvent>(_onSetPayerIndex);
    on<SetPaymentIndexEvent>(_onSetPaymentIndex);
    on<ToggleTermsEvent>(_onToggleTerms);
    on<SelectOfflineBankEvent>(_onSelectOfflineBank);
    on<ChangeDigitalPaymentNameEvent>(_onChangeDigitalPaymentName);
    on<SetInstructionSelectedIndexEvent>(_onSetInstructionSelectedIndex);
    on<SetCustomNoteEvent>(_onSetCustomNote);
    on<SetSelectedIndexNoteEvent>(_onSetSelectedIndexNote);
    on<SetSenderAddressIndexEvent>(_onSetSenderAddressIndex);
    on<SetReceiverAddressIndexEvent>(_onSetReceiverAddressIndex);
    on<SetCountryCodeEvent>(_onSetCountryCode);
    on<ShowTipsFieldEvent>(_onShowTipsField);
    on<UpdateTipsEvent>(_onUpdateTips);
    on<ToggleDmTipSaveEvent>(_onToggleDmTipSave);
    on<AddTipsEvent>(_onAddTips);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<SetLoadingEvent>(_onSetLoading);
  }

  Future<void> _onGetParcelCategoryList(
    GetParcelCategoryListEvent event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await getParcelCategoryUseCase();
    result.fold(
      (failure) => null,
      (data) => emit(state.copyWith(parcelCategoryList: data)),
    );
  }

  Future<void> _onGetWhyChooseDetails(
    GetWhyChooseDetailsEvent event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await getWhyChooseUseCase();
    result.fold(
      (failure) => null,
      (data) => emit(state.copyWith(whyChooseDetails: data)),
    );
  }

  Future<void> _onGetVideoContentDetails(
    GetVideoContentDetailsEvent event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await getVideoContentUseCase();
    result.fold(
      (failure) => null,
      (data) => emit(state.copyWith(videoContentDetails: data)),
    );
  }

  Future<void> _onGetParcelInstruction(
    GetParcelInstructionEvent event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await getParcelInstructionUseCase(1);
    result.fold(
      (failure) => null,
      (data) => emit(state.copyWith(parcelInstructionList: data)),
    );
  }

  Future<void> _onGetOfflineMethodList(
    GetOfflineMethodListEvent event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await checkoutRepositoryInterface.getList();
    emit(state.copyWith(offlineMethodList: result));
  }

  Future<void> _onGetDmTipMostTapped(
    GetDmTipMostTappedEvent event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await checkoutRepositoryInterface.getDmTipMostTapped();
    emit(state.copyWith(mostDmTipAmount: result));
  }

  void _onSetPickupAddress(
    SetPickupAddressEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(state.copyWith(pickupAddress: event.address));
  }

  void _onSetDestinationAddress(
    SetDestinationAddressEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(state.copyWith(destinationAddress: event.address));
  }

  void _onSetIsPickedUp(SetIsPickedUpEvent event, Emitter<ParcelState> emit) {
    emit(state.copyWith(isPickedUp: event.isPickedUp));
  }

  void _onSetIsSender(SetIsSenderEvent event, Emitter<ParcelState> emit) {
    emit(state.copyWith(isSender: event.isSender));
  }

  Future<void> _onSetLocationFromPlace(
    SetLocationFromPlaceEvent event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await getPlaceDetailsUseCase(event.placeId ?? '');
    await result.fold((failure) async => null, (placeDetails) async {
      if (placeDetails.status == 'OK') {
        AddressModel address0 = AddressModel(
          address: event.address,
          addressType: 'others',
          latitude: placeDetails.result!.geometry!.location!.lat.toString(),
          longitude: placeDetails.result!.geometry!.location!.lng.toString(),
          contactPersonName:
              AddressHelper.getUserAddressFromSharedPref()!.contactPersonName,
          contactPersonNumber:
              AddressHelper.getUserAddressFromSharedPref()!.contactPersonNumber,
        );
        ZoneResponseModel response0 = await Get.find<LocationController>()
            .getZone(address0.latitude, address0.longitude, false);
        if (response0.isSuccess) {
          bool inZone = false;
          for (int zoneId
              in AddressHelper.getUserAddressFromSharedPref()!.zoneIds!) {
            if (response0.zoneIds.contains(zoneId)) {
              inZone = true;
              break;
            }
          }
          if (inZone) {
            address0.zoneId = response0.zoneIds[0];
            address0.zoneIds = [];
            address0.zoneIds!.addAll(response0.zoneIds);
            address0.zoneData = [];
            address0.zoneData!.addAll(response0.zoneData);
            if (event.isPickedUp) {
              emit(state.copyWith(pickupAddress: address0));
            } else {
              emit(state.copyWith(destinationAddress: address0));
            }
          } else {
            showCustomSnackBar(
              'your_selected_location_is_from_different_zone_store'.tr,
            );
          }
        } else {
          showCustomSnackBar(response0.message);
        }
      }
    });
  }

  Future<void> _onGetDistance(
    GetDistanceEvent event,
    Emitter<ParcelState> emit,
  ) async {
    emit(state.copyWith(distance: -1));
    double? distance = 0;
    double? extraCharge = 0;
    try {
      final response = await Get.find<CheckoutServiceInterface>().getDistanceInMeter(
        LatLng(double.parse(event.pickupAddress.latitude!), double.parse(event.pickupAddress.longitude!)),
        LatLng(double.parse(event.destinationAddress.latitude!), double.parse(event.destinationAddress.longitude!)),
      );
      if (response.statusCode == 200 && response.body['status'] == 'OK') {
        distance = DistanceModel.fromJson(response.body).rows![0].elements![0].distance!.value! / 1000;
      } else {
        distance = Geolocator.distanceBetween(
          double.parse(event.pickupAddress.latitude!), double.parse(event.pickupAddress.longitude!),
          double.parse(event.destinationAddress.latitude!), double.parse(event.destinationAddress.longitude!),
        ) / 1000;
      }
      extraCharge = await Get.find<CheckoutServiceInterface>().getExtraCharge(distance);
    } catch(e) {}
    emit(state.copyWith(distance: distance, extraCharge: extraCharge));
  }

  void _onSetPayerIndex(SetPayerIndexEvent event, Emitter<ParcelState> emit) {
    int paymentIndex = state.paymentIndex;
    if (event.index == 1) {
      paymentIndex = 0;
    }
    emit(state.copyWith(payerIndex: event.index, paymentIndex: paymentIndex));
  }

  void _onSetPaymentIndex(
    SetPaymentIndexEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(state.copyWith(paymentIndex: event.index));
  }

  void _onToggleTerms(ToggleTermsEvent event, Emitter<ParcelState> emit) {
    emit(state.copyWith(acceptTerms: !state.acceptTerms));
  }

  void _onSelectOfflineBank(
    SelectOfflineBankEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(state.copyWith(selectedOfflineBankIndex: event.index));
  }

  void _onChangeDigitalPaymentName(
    ChangeDigitalPaymentNameEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(state.copyWith(digitalPaymentName: event.name));
  }

  void _onSetInstructionSelectedIndex(
    SetInstructionSelectedIndexEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(state.copyWith(instructionselectedIndex: event.index));
  }

  void _onSetCustomNote(SetCustomNoteEvent event, Emitter<ParcelState> emit) {
    emit(state.copyWith(customNote: event.note));
  }

  void _onSetSelectedIndexNote(
    SetSelectedIndexNoteEvent event,
    Emitter<ParcelState> emit,
  ) {
    if (event.index != null) {
      emit(state.copyWith(selectedIndexNote: event.index));
    } else {
      emit(state.copyWith(selectedIndexNote: state.instructionselectedIndex));
    }
  }

  void _onSetSenderAddressIndex(
    SetSenderAddressIndexEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(
      state.copyWith(senderAddressIndex: event.index ?? -1),
    ); // handled correctly in copyWith
  }

  void _onSetReceiverAddressIndex(
    SetReceiverAddressIndexEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(state.copyWith(receiverAddressIndex: event.index ?? -1));
  }

  void _onSetCountryCode(SetCountryCodeEvent event, Emitter<ParcelState> emit) {
    if (event.isSender) {
      emit(state.copyWith(senderCountryCode: event.code));
    } else {
      emit(state.copyWith(receiverCountryCode: event.code));
    }
  }

  void _onShowTipsField(ShowTipsFieldEvent event, Emitter<ParcelState> emit) {
    emit(state.copyWith(canShowTipsField: !state.canShowTipsField));
  }

  void _onUpdateTips(UpdateTipsEvent event, Emitter<ParcelState> emit) {
    double tips = 0;
    if (event.index != 0 && event.index != 5) {
      tips = double.parse(AppConstants.tips[event.index]);
    }
    emit(state.copyWith(selectedTips: event.index, tips: tips));
  }

  void _onToggleDmTipSave(
    ToggleDmTipSaveEvent event,
    Emitter<ParcelState> emit,
  ) {
    emit(state.copyWith(isDmTipSave: !state.isDmTipSave));
  }

  void _onAddTips(AddTipsEvent event, Emitter<ParcelState> emit) {
    emit(state.copyWith(tips: event.tips));
  }

  Future<void> _onPlaceOrder(
    PlaceOrderEvent event,
    Emitter<ParcelState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    String orderID = '';
    Response response = await checkoutRepositoryInterface.placeOrder(
      event.placeOrderBody,
      null,
    );
    emit(state.copyWith(isLoading: false));
    if (response.statusCode == 200) {
      String? message = response.body['message'];
      orderID = response.body['order_id'].toString();
      if (!event.isOfflinePay) {
        _parcelCallback(
          true,
          message,
          orderID,
          event.zoneID,
          event.amount,
          event.maximumCodOrderAmount,
          event.isCashOnDeliveryActive,
          event.placeOrderBody.contactPersonNumber,
          emit,
        );
      }
      if (kDebugMode) {
        print('-------- Order placed successfully $orderID ----------');
      }
    } else {
      if (!event.isOfflinePay) {
        _parcelCallback(
          false,
          response.statusText,
          '-1',
          event.zoneID,
          event.amount,
          event.maximumCodOrderAmount,
          event.isCashOnDeliveryActive,
          event.placeOrderBody.contactPersonNumber,
          emit,
        );
      } else {
        showCustomSnackBar(response.statusText);
      }
    }
  }

  void _onSetLoading(SetLoadingEvent event, Emitter<ParcelState> emit) {
    emit(state.copyWith(isLoading: event.isLoading));
  }

  void _parcelCallback(
    bool isSuccess,
    String? message,
    String orderID,
    int? zoneID,
    double orderAmount,
    double? maxCodAmount,
    bool isCashOnDeliveryActive,
    String? contactNumber,
    Emitter<ParcelState> emit,
  ) {
    if (isSuccess) {
      if (state.isDmTipSave) {
        Get.find<AuthController>().saveDmTipIndex(
          state.selectedTips.toString(),
        );
      }
      getIt<CheckoutBloc>().add(const GuestAddressSet(address: null));
      if (state.paymentIndex == 2) {
        if (GetPlatform.isWeb) {
          Get.find<AuthController>().saveGuestNumber(contactNumber ?? '').then((
            _,
          ) {
            String? hostname = html.window.location.hostname;
            String protocol = html.window.location.protocol;
            String selectedUrl =
                '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&&customer_id=${Get.find<ProfileController>().userInfoModel?.id ?? AuthHelper.getGuestId()}'
                '&payment_method=${state.digitalPaymentName}&payment_platform=web&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
            html.window.open(selectedUrl, "_self");
          });
        } else {
          Get.offNamed(
            RouteHelper.getPaymentRoute(
              orderID,
              Get.find<ProfileController>().userInfoModel?.id ?? 0,
              'parcel',
              orderAmount,
              isCashOnDeliveryActive,
              state.digitalPaymentName,
              guestId: AuthHelper.getGuestId(),
              contactNumber: contactNumber,
            ),
          );
        }
      } else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, contactNumber));
      }
      add(UpdateTipsEvent(0));
    } else {
      showCustomSnackBar(message);
    }
  }
}
