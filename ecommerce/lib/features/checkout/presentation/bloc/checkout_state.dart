import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/checkout/domain/entities/time_slot.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

class CheckoutState extends Equatable {
  final bool isLoading;
  final Store? store;

  final AddressModel? guestAddress;
  final int? addressIndex;
  final String? countryDialCode;

  final String? orderType;
  final int paymentMethodIndex;
  final String? digitalPaymentName;
  final bool isPartialPay;

  final double tips;
  final int selectedTips;
  final int? mostDmTipAmount;
  final bool isDmTipSave;
  final bool canShowTipsField;

  final List<OfflineMethodModel>? offlineMethodList;
  final int selectedOfflineBankIndex;

  final String preferableTime;
  final int selectedDateSlot;
  final int selectedTimeSlot;
  final List<TimeSlot>? timeSlots;
  final List<TimeSlot>? allTimeSlots;

  final double? distance;
  final double? extraCharge;
  final double viewTotalPrice;

  final XFile? orderAttachment;
  final Uint8List? rawAttachment;
  final List<XFile> pickedPrescriptions;

  final bool acceptTerms;
  final int selectedInstruction;
  final bool isExpanded;
  final bool isExpand;

  /// One-shot result of the last place-order attempt (UI reacts via listener).
  final PlaceOrderResult? placeOrderResult;
  final String? errorMessage;

  const CheckoutState({
    this.isLoading = false,
    this.store,
    this.guestAddress,
    this.addressIndex = 0,
    this.countryDialCode,
    this.orderType = 'delivery',
    this.paymentMethodIndex = -1,
    this.digitalPaymentName,
    this.isPartialPay = false,
    this.tips = 0.0,
    this.selectedTips = 0,
    this.mostDmTipAmount,
    this.isDmTipSave = false,
    this.canShowTipsField = false,
    this.offlineMethodList,
    this.selectedOfflineBankIndex = 0,
    this.preferableTime = '',
    this.selectedDateSlot = 0,
    this.selectedTimeSlot = 0,
    this.timeSlots,
    this.allTimeSlots,
    this.distance,
    this.extraCharge,
    this.viewTotalPrice = 0,
    this.orderAttachment,
    this.rawAttachment,
    this.pickedPrescriptions = const [],
    this.acceptTerms = true,
    this.selectedInstruction = -1,
    this.isExpanded = false,
    this.isExpand = false,
    this.placeOrderResult,
    this.errorMessage,
  });

  CheckoutState copyWith({
    bool? isLoading,
    Store? store,
    AddressModel? guestAddress,
    int? addressIndex,
    String? countryDialCode,
    String? orderType,
    int? paymentMethodIndex,
    String? digitalPaymentName,
    bool? isPartialPay,
    double? tips,
    int? selectedTips,
    int? mostDmTipAmount,
    bool? isDmTipSave,
    bool? canShowTipsField,
    List<OfflineMethodModel>? offlineMethodList,
    int? selectedOfflineBankIndex,
    String? preferableTime,
    int? selectedDateSlot,
    int? selectedTimeSlot,
    List<TimeSlot>? timeSlots,
    List<TimeSlot>? allTimeSlots,
    double? distance,
    double? extraCharge,
    double? viewTotalPrice,
    XFile? orderAttachment,
    Uint8List? rawAttachment,
    List<XFile>? pickedPrescriptions,
    bool? acceptTerms,
    int? selectedInstruction,
    bool? isExpanded,
    bool? isExpand,
    PlaceOrderResult? placeOrderResult,
    String? errorMessage,
    bool clearGuestAddress = false,
    bool clearAttachment = false,
    bool clearResult = false,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      store: store ?? this.store,
      guestAddress: clearGuestAddress
          ? null
          : (guestAddress ?? this.guestAddress),
      addressIndex: addressIndex ?? this.addressIndex,
      countryDialCode: countryDialCode ?? this.countryDialCode,
      orderType: orderType ?? this.orderType,
      paymentMethodIndex: paymentMethodIndex ?? this.paymentMethodIndex,
      digitalPaymentName: digitalPaymentName ?? this.digitalPaymentName,
      isPartialPay: isPartialPay ?? this.isPartialPay,
      tips: tips ?? this.tips,
      selectedTips: selectedTips ?? this.selectedTips,
      mostDmTipAmount: mostDmTipAmount ?? this.mostDmTipAmount,
      isDmTipSave: isDmTipSave ?? this.isDmTipSave,
      canShowTipsField: canShowTipsField ?? this.canShowTipsField,
      offlineMethodList: offlineMethodList ?? this.offlineMethodList,
      selectedOfflineBankIndex:
          selectedOfflineBankIndex ?? this.selectedOfflineBankIndex,
      preferableTime: preferableTime ?? this.preferableTime,
      selectedDateSlot: selectedDateSlot ?? this.selectedDateSlot,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      timeSlots: timeSlots ?? this.timeSlots,
      allTimeSlots: allTimeSlots ?? this.allTimeSlots,
      distance: distance ?? this.distance,
      extraCharge: extraCharge ?? this.extraCharge,
      viewTotalPrice: viewTotalPrice ?? this.viewTotalPrice,
      orderAttachment: clearAttachment
          ? null
          : (orderAttachment ?? this.orderAttachment),
      rawAttachment: clearAttachment
          ? null
          : (rawAttachment ?? this.rawAttachment),
      pickedPrescriptions: pickedPrescriptions ?? this.pickedPrescriptions,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      selectedInstruction: selectedInstruction ?? this.selectedInstruction,
      isExpanded: isExpanded ?? this.isExpanded,
      isExpand: isExpand ?? this.isExpand,
      placeOrderResult: clearResult
          ? null
          : (placeOrderResult ?? this.placeOrderResult),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    store,
    guestAddress,
    addressIndex,
    countryDialCode,
    orderType,
    paymentMethodIndex,
    digitalPaymentName,
    isPartialPay,
    tips,
    selectedTips,
    mostDmTipAmount,
    isDmTipSave,
    canShowTipsField,
    offlineMethodList,
    selectedOfflineBankIndex,
    preferableTime,
    selectedDateSlot,
    selectedTimeSlot,
    timeSlots,
    allTimeSlots,
    distance,
    extraCharge,
    viewTotalPrice,
    orderAttachment,
    rawAttachment,
    pickedPrescriptions,
    acceptTerms,
    selectedInstruction,
    isExpanded,
    isExpand,
    placeOrderResult,
    errorMessage,
  ];
}
