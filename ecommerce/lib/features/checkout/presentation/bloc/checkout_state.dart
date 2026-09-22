import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/checkout/domain/models/timeslote_model.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';

enum CheckoutStatus { initial, loading, success, failure }

class CheckoutState extends Equatable {
  // ─── Status ──────────────────────────────────────────────────────────
  final CheckoutStatus status;
  final CheckoutStatus orderStatus;
  final String? errorMessage;

  // ─── Store ───────────────────────────────────────────────────────────
  final Store? store;

  // ─── Time slots ──────────────────────────────────────────────────────
  final List<TimeSlotModel>? timeSlots;
  final List<TimeSlotModel>? allTimeSlots;
  final int selectedDateSlot;
  final int selectedTimeSlot;

  // ─── Distance & charges ──────────────────────────────────────────────
  final double? distance;
  final double? extraCharge;

  // ─── Tips ────────────────────────────────────────────────────────────
  final int? mostDmTipAmount;
  final double tips;
  final int selectedTips;
  final bool isDmTipSave;
  final bool canShowTipsField;

  // ─── Payment ─────────────────────────────────────────────────────────
  final int paymentMethodIndex;
  final String? digitalPaymentName;
  final bool isPartialPay;
  final List<OfflineMethodModel>? offlineMethodList;
  final int selectedOfflineBankIndex;

  // ─── Order type ───────────────────────────────────────────────────────
  final String? orderType;

  // ─── Address ─────────────────────────────────────────────────────────
  final int? addressIndex;
  final AddressModel? guestAddress;

  // ─── Attachments ─────────────────────────────────────────────────────
  final List<XFile> pickedPrescriptions;
  final XFile? orderAttachment;

  // ─── UI helpers ──────────────────────────────────────────────────────
  final bool acceptTerms;
  final String preferableTime;
  final int selectedInstruction;
  final bool isExpanded;
  final bool isExpand;
  final double viewTotalPrice;

  // ─── Placed order ────────────────────────────────────────────────────
  final String? placedOrderId;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.orderStatus = CheckoutStatus.initial,
    this.errorMessage,
    this.store,
    this.timeSlots,
    this.allTimeSlots,
    this.selectedDateSlot = 0,
    this.selectedTimeSlot = 0,
    this.distance,
    this.extraCharge,
    this.mostDmTipAmount,
    this.tips = 0.0,
    this.selectedTips = 0,
    this.isDmTipSave = false,
    this.canShowTipsField = false,
    this.paymentMethodIndex = -1,
    this.digitalPaymentName,
    this.isPartialPay = false,
    this.offlineMethodList,
    this.selectedOfflineBankIndex = 0,
    this.orderType = 'delivery',
    this.addressIndex = 0,
    this.guestAddress,
    this.pickedPrescriptions = const [],
    this.orderAttachment,
    this.acceptTerms = true,
    this.preferableTime = '',
    this.selectedInstruction = -1,
    this.isExpanded = false,
    this.isExpand = false,
    this.viewTotalPrice = 0,
    this.placedOrderId,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    CheckoutStatus? orderStatus,
    String? errorMessage,
    Store? store,
    List<TimeSlotModel>? timeSlots,
    List<TimeSlotModel>? allTimeSlots,
    int? selectedDateSlot,
    int? selectedTimeSlot,
    double? distance,
    double? extraCharge,
    int? mostDmTipAmount,
    double? tips,
    int? selectedTips,
    bool? isDmTipSave,
    bool? canShowTipsField,
    int? paymentMethodIndex,
    String? digitalPaymentName,
    bool? isPartialPay,
    List<OfflineMethodModel>? offlineMethodList,
    int? selectedOfflineBankIndex,
    String? orderType,
    int? addressIndex,
    AddressModel? guestAddress,
    bool clearGuestAddress = false,
    List<XFile>? pickedPrescriptions,
    XFile? orderAttachment,
    bool clearOrderAttachment = false,
    bool? acceptTerms,
    String? preferableTime,
    int? selectedInstruction,
    bool? isExpanded,
    bool? isExpand,
    double? viewTotalPrice,
    String? placedOrderId,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      orderStatus: orderStatus ?? this.orderStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      store: store ?? this.store,
      timeSlots: timeSlots ?? this.timeSlots,
      allTimeSlots: allTimeSlots ?? this.allTimeSlots,
      selectedDateSlot: selectedDateSlot ?? this.selectedDateSlot,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      distance: distance ?? this.distance,
      extraCharge: extraCharge ?? this.extraCharge,
      mostDmTipAmount: mostDmTipAmount ?? this.mostDmTipAmount,
      tips: tips ?? this.tips,
      selectedTips: selectedTips ?? this.selectedTips,
      isDmTipSave: isDmTipSave ?? this.isDmTipSave,
      canShowTipsField: canShowTipsField ?? this.canShowTipsField,
      paymentMethodIndex: paymentMethodIndex ?? this.paymentMethodIndex,
      digitalPaymentName: digitalPaymentName ?? this.digitalPaymentName,
      isPartialPay: isPartialPay ?? this.isPartialPay,
      offlineMethodList: offlineMethodList ?? this.offlineMethodList,
      selectedOfflineBankIndex:
          selectedOfflineBankIndex ?? this.selectedOfflineBankIndex,
      orderType: orderType ?? this.orderType,
      addressIndex: addressIndex ?? this.addressIndex,
      guestAddress: clearGuestAddress
          ? null
          : (guestAddress ?? this.guestAddress),
      pickedPrescriptions: pickedPrescriptions ?? this.pickedPrescriptions,
      orderAttachment: clearOrderAttachment
          ? null
          : (orderAttachment ?? this.orderAttachment),
      acceptTerms: acceptTerms ?? this.acceptTerms,
      preferableTime: preferableTime ?? this.preferableTime,
      selectedInstruction: selectedInstruction ?? this.selectedInstruction,
      isExpanded: isExpanded ?? this.isExpanded,
      isExpand: isExpand ?? this.isExpand,
      viewTotalPrice: viewTotalPrice ?? this.viewTotalPrice,
      placedOrderId: placedOrderId ?? this.placedOrderId,
    );
  }

  /// Fresh state — keeps only what was loaded at startup (tips index from prefs).
  CheckoutState cleared() =>
      CheckoutState(selectedTips: selectedTips, tips: tips);

  @override
  List<Object?> get props => [
    status,
    orderStatus,
    errorMessage,
    store,
    timeSlots,
    allTimeSlots,
    selectedDateSlot,
    selectedTimeSlot,
    distance,
    extraCharge,
    mostDmTipAmount,
    tips,
    selectedTips,
    isDmTipSave,
    canShowTipsField,
    paymentMethodIndex,
    digitalPaymentName,
    isPartialPay,
    offlineMethodList,
    selectedOfflineBankIndex,
    orderType,
    addressIndex,
    guestAddress,
    pickedPrescriptions,
    orderAttachment,
    acceptTerms,
    preferableTime,
    selectedInstruction,
    isExpanded,
    isExpand,
    viewTotalPrice,
    placedOrderId,
  ];
}
