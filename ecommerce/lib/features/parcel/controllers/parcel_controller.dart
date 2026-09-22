import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_category.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_instruction.dart';
import 'package:ecommerce/features/parcel/domain/entities/video_content.dart';
import 'package:ecommerce/features/parcel/domain/entities/why_choose.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_bloc.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_event.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';

class ParcelController extends GetxController implements GetxService {
  BuildContext? get _context => Get.context;
  ParcelBloc? get _bloc => _context != null ? BlocProvider.of<ParcelBloc>(_context!) : getIt<ParcelBloc>();

  @override
  void onInit() {
    super.onInit();
    _bloc?.stream.listen((state) {
      update();
    });
  }

  List<ParcelCategory>? get parcelCategoryList => _bloc?.state.parcelCategoryList;
  AddressModel? get pickupAddress => _bloc?.state.pickupAddress;
  AddressModel? get destinationAddress => _bloc?.state.destinationAddress;
  bool? get isPickedUp => _bloc?.state.isPickedUp;
  bool get isSender => _bloc?.state.isSender ?? true;
  bool get isLoading => _bloc?.state.isLoading ?? false;
  double? get distance => _bloc?.state.distance;
  List<String> get payerTypes => _bloc?.state.payerTypes ?? ['sender', 'receiver'];
  int get payerIndex => _bloc?.state.payerIndex ?? 0;
  int get paymentIndex => _bloc?.state.paymentIndex ?? -1;
  bool get acceptTerms => _bloc?.state.acceptTerms ?? true;
  double? get extraCharge => _bloc?.state.extraCharge;
  String? get digitalPaymentName => _bloc?.state.digitalPaymentName;
  WhyChoose? get whyChooseDetails => _bloc?.state.whyChooseDetails;
  VideoContent? get videoContentDetails => _bloc?.state.videoContentDetails;
  int get selectedOfflineBankIndex => _bloc?.state.selectedOfflineBankIndex ?? 0;
  List<ParcelInstruction>? get parcelInstructionList => _bloc?.state.parcelInstructionList;
  int get instructionselectedIndex => _bloc?.state.instructionselectedIndex ?? -1;
  
  final TextEditingController _customNoteController = TextEditingController();
  TextEditingController get customNoteController {
    if (_bloc?.state.customNote != null) {
      _customNoteController.text = _bloc!.state.customNote;
    }
    return _customNoteController;
  }
  String? get customNote => _bloc?.state.customNote;
  
  int? get selectedIndexNote => _bloc?.state.selectedIndexNote;
  int? get senderAddressIndex => _bloc?.state.senderAddressIndex;
  int? get receiverAddressIndex => _bloc?.state.receiverAddressIndex;
  String? get senderCountryCode => _bloc?.state.senderCountryCode;
  String? get receiverCountryCode => _bloc?.state.receiverCountryCode;
  List<OfflineMethodModel>? get offlineMethodList => _bloc?.state.offlineMethodList;
  int? get mostDmTipAmount => _bloc?.state.mostDmTipAmount;
  double get tips => _bloc?.state.tips ?? 0.0;
  int get selectedTips => _bloc?.state.selectedTips ?? 0;
  bool get canShowTipsField => _bloc?.state.canShowTipsField ?? false;
  bool get isDmTipSave => _bloc?.state.isDmTipSave ?? false;

  void showTipsField() => _bloc?.add(ShowTipsFieldEvent());
  Future<void> addTips(double tips) async => _bloc?.add(AddTipsEvent(tips));
  void toggleDmTipSave() => _bloc?.add(ToggleDmTipSaveEvent());
  void setCountryCode(String code, bool isSender) => _bloc?.add(SetCountryCodeEvent(code: code, isSender: isSender));
  void setSenderAddressIndex(int? index, {bool canUpdate = true}) => _bloc?.add(SetSenderAddressIndexEvent(index));
  void setReceiverAddressIndex(int? index, {bool canUpdate = true}) => _bloc?.add(SetReceiverAddressIndexEvent(index));
  void selectOfflineBank(int index) => _bloc?.add(SelectOfflineBankEvent(index));
  void changeDigitalPaymentName(String name) => _bloc?.add(ChangeDigitalPaymentNameEvent(name));
  void toggleTerms() => _bloc?.add(ToggleTermsEvent());
  
  Future<void> getParcelCategoryList() async => _bloc?.add(GetParcelCategoryListEvent());
  void setPickupAddress(AddressModel? addressModel, bool notify) => _bloc?.add(SetPickupAddressEvent(addressModel));
  void setDestinationAddress(AddressModel? addressModel, {bool notify = true}) => _bloc?.add(SetDestinationAddressEvent(addressModel));
  void setLocationFromPlace(String? placeID, String? address, bool? isPickedUp) => _bloc?.add(SetLocationFromPlaceEvent(placeId: placeID, address: address, isPickedUp: isPickedUp ?? true));
  Future<void> getWhyChooseDetails() async => _bloc?.add(GetWhyChooseDetailsEvent());
  Future<void> getVideoContentDetails() async => _bloc?.add(GetVideoContentDetailsEvent());
  void setIsPickedUp(bool? isPickedUp, bool notify) => _bloc?.add(SetIsPickedUpEvent(isPickedUp ?? true));
  void setIsSender(bool sender, bool notify) => _bloc?.add(SetIsSenderEvent(sender));
  
  void getDistance(AddressModel pickedUpAddress, AddressModel destinationAddress) {
    _bloc?.add(GetDistanceEvent(pickupAddress: pickedUpAddress, destinationAddress: destinationAddress));
  }
  
  void setPayerIndex(int index, bool notify) => _bloc?.add(SetPayerIndexEvent(index));
  void setPaymentIndex(int index, bool notify) => _bloc?.add(SetPaymentIndexEvent(index));
  void startLoader(bool isEnable, {bool canUpdate = true}) => _bloc?.add(SetLoadingEvent(isEnable));
  Future<void> getParcelInstruction() async => _bloc?.add(GetParcelInstructionEvent());
  void setInstructionselectedIndex(int index, {bool notify = true}) => _bloc?.add(SetInstructionSelectedIndexEvent(index));
  
  void setCustomNoteController(String customNote, {bool notify = true}) {
    _customNoteController.text = customNote;
    _bloc?.add(SetCustomNoteEvent(customNote));
  }
  
  void setCustomNote(String? customNoteText) {
    if (customNoteText != null && customNoteText.isNotEmpty) {
      _bloc?.add(SetCustomNoteEvent(customNoteText));
    } else {
      _bloc?.add(SetCustomNoteEvent(_customNoteController.text));
    }
  }
  
  void setselectedIndex(int? index) => _bloc?.add(SetSelectedIndexNoteEvent(index));
  Future<void> getOfflineMethodList() async => _bloc?.add(GetOfflineMethodListEvent());
  Future<void> getDmTipMostTapped() async => _bloc?.add(GetDmTipMostTappedEvent());
  void updateTips(int index, {bool notify = true}) => _bloc?.add(UpdateTipsEvent(index));
  
  Future<String> placeOrder(PlaceOrderBodyModel placeOrderBody, int? zoneID, double amount, double? maximumCodOrderAmount, bool fromCart, bool isCashOnDeliveryActive, {bool forParcel = false, bool isOfflinePay = false}) async {
    _bloc?.add(PlaceOrderEvent(
      placeOrderBody: placeOrderBody,
      zoneID: zoneID,
      amount: amount,
      maximumCodOrderAmount: maximumCodOrderAmount,
      fromCart: fromCart,
      isCashOnDeliveryActive: isCashOnDeliveryActive,
      forParcel: forParcel,
      isOfflinePay: isOfflinePay,
    ));
    return '';
  }
}