import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_category_model.dart';
import 'package:ecommerce/features/parcel/data/models/parcel_instruction_model.dart';
import 'package:ecommerce/features/parcel/data/models/video_content_model.dart';
import 'package:ecommerce/features/parcel/data/models/why_choose_model.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';

/// Load status for the parcel category list (parcel landing).
enum ParcelStatus { initial, loading, loaded, error }

/// Outcome of the last one-shot action (place-order, place-details zone
/// resolution). The UI reacts via `BlocListener`/`BlocConsumer`; it is reset
/// on the next event.
enum ParcelActionStatus { none, inProgress, success, failure }

/// Single immutable state for the whole parcel flow. Mirrors every field the
/// legacy `ParcelController` exposed. Uses status enums (not a sealed
/// hierarchy) because the loaded category list and all the selection state
/// must survive across the many toggles/actions (rule 6).
class ParcelState extends Equatable {
  // ── category list ──────────────────────────────────────────────────────
  final ParcelStatus status;
  final List<ParcelCategoryModel> parcelCategoryList;
  final String? errorMessage;

  // ── pickup / destination addresses ───────────────────────────────────────
  final AddressModel? pickupAddress;
  final AddressModel? destinationAddress;
  final bool? isPickedUp;
  final bool isSender;

  // ── sender / receiver address selection ──────────────────────────────────
  final int? senderAddressIndex;
  final int? receiverAddressIndex;
  final String? senderCountryCode;
  final String? receiverCountryCode;

  // ── pricing / distance ───────────────────────────────────────────────────
  final double? distance;
  final double? extraCharge;

  // ── payer / payment ──────────────────────────────────────────────────────
  final int payerIndex;
  final int paymentIndex;
  final bool acceptTerms;
  final String? digitalPaymentName;
  final int selectedOfflineBankIndex;
  final List<OfflineMethodModel>? offlineMethodList;

  // ── landing banners ──────────────────────────────────────────────────────
  final WhyChooseModel? whyChooseDetails;
  final VideoContentModel? videoContentDetails;

  // ── delivery instruction / note ──────────────────────────────────────────
  final List<Data>? parcelInstructionList;
  final int instructionSelectedIndex;
  final String customNote;
  final int selectedIndexNote;

  // ── dm tips ───────────────────────────────────────────────────────────────
  final int? mostDmTipAmount;
  final double tips;
  final int selectedTips;
  final bool canShowTipsField;
  final bool isDmTipSave;

  // ── loading / actions ─────────────────────────────────────────────────────
  final bool isLoading;
  final ParcelActionStatus actionStatus;
  final String? actionMessage;

  const ParcelState({
    this.status = ParcelStatus.initial,
    this.parcelCategoryList = const [],
    this.errorMessage,
    this.pickupAddress,
    this.destinationAddress,
    this.isPickedUp = true,
    this.isSender = true,
    this.senderAddressIndex = 0,
    this.receiverAddressIndex = 0,
    this.senderCountryCode,
    this.receiverCountryCode,
    this.distance = -1,
    this.extraCharge,
    this.payerIndex = 0,
    this.paymentIndex = -1,
    this.acceptTerms = true,
    this.digitalPaymentName,
    this.selectedOfflineBankIndex = 0,
    this.offlineMethodList,
    this.whyChooseDetails,
    this.videoContentDetails,
    this.parcelInstructionList,
    this.instructionSelectedIndex = -1,
    this.customNote = '',
    this.selectedIndexNote = -1,
    this.mostDmTipAmount,
    this.tips = 0.0,
    this.selectedTips = 0,
    this.canShowTipsField = false,
    this.isDmTipSave = false,
    this.isLoading = false,
    this.actionStatus = ParcelActionStatus.none,
    this.actionMessage,
  });

  ParcelState copyWith({
    ParcelStatus? status,
    List<ParcelCategoryModel>? parcelCategoryList,
    String? errorMessage,
    AddressModel? pickupAddress,
    bool clearPickupAddress = false,
    AddressModel? destinationAddress,
    bool clearDestinationAddress = false,
    bool? isPickedUp,
    bool? isSender,
    int? senderAddressIndex,
    int? receiverAddressIndex,
    String? senderCountryCode,
    String? receiverCountryCode,
    double? distance,
    double? extraCharge,
    bool clearExtraCharge = false,
    int? payerIndex,
    int? paymentIndex,
    bool? acceptTerms,
    String? digitalPaymentName,
    bool clearDigitalPaymentName = false,
    int? selectedOfflineBankIndex,
    List<OfflineMethodModel>? offlineMethodList,
    bool clearOfflineMethodList = false,
    WhyChooseModel? whyChooseDetails,
    VideoContentModel? videoContentDetails,
    List<Data>? parcelInstructionList,
    bool clearParcelInstructionList = false,
    int? instructionSelectedIndex,
    String? customNote,
    int? selectedIndexNote,
    int? mostDmTipAmount,
    double? tips,
    int? selectedTips,
    bool? canShowTipsField,
    bool? isDmTipSave,
    bool? isLoading,
    ParcelActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return ParcelState(
      status: status ?? this.status,
      parcelCategoryList: parcelCategoryList ?? this.parcelCategoryList,
      errorMessage: errorMessage,
      pickupAddress: clearPickupAddress
          ? null
          : (pickupAddress ?? this.pickupAddress),
      destinationAddress: clearDestinationAddress
          ? null
          : (destinationAddress ?? this.destinationAddress),
      isPickedUp: isPickedUp ?? this.isPickedUp,
      isSender: isSender ?? this.isSender,
      senderAddressIndex: senderAddressIndex ?? this.senderAddressIndex,
      receiverAddressIndex: receiverAddressIndex ?? this.receiverAddressIndex,
      senderCountryCode: senderCountryCode ?? this.senderCountryCode,
      receiverCountryCode: receiverCountryCode ?? this.receiverCountryCode,
      distance: distance ?? this.distance,
      extraCharge: clearExtraCharge ? null : (extraCharge ?? this.extraCharge),
      payerIndex: payerIndex ?? this.payerIndex,
      paymentIndex: paymentIndex ?? this.paymentIndex,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      digitalPaymentName: clearDigitalPaymentName
          ? null
          : (digitalPaymentName ?? this.digitalPaymentName),
      selectedOfflineBankIndex:
          selectedOfflineBankIndex ?? this.selectedOfflineBankIndex,
      offlineMethodList: clearOfflineMethodList
          ? null
          : (offlineMethodList ?? this.offlineMethodList),
      whyChooseDetails: whyChooseDetails ?? this.whyChooseDetails,
      videoContentDetails: videoContentDetails ?? this.videoContentDetails,
      parcelInstructionList: clearParcelInstructionList
          ? null
          : (parcelInstructionList ?? this.parcelInstructionList),
      instructionSelectedIndex:
          instructionSelectedIndex ?? this.instructionSelectedIndex,
      customNote: customNote ?? this.customNote,
      selectedIndexNote: selectedIndexNote ?? this.selectedIndexNote,
      mostDmTipAmount: mostDmTipAmount ?? this.mostDmTipAmount,
      tips: tips ?? this.tips,
      selectedTips: selectedTips ?? this.selectedTips,
      canShowTipsField: canShowTipsField ?? this.canShowTipsField,
      isDmTipSave: isDmTipSave ?? this.isDmTipSave,
      isLoading: isLoading ?? this.isLoading,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
    );
  }

  /// The payer type list (static, mirrors the legacy controller).
  List<String> get payerTypes => const ['sender', 'receiver'];

  @override
  List<Object?> get props => [
    status,
    parcelCategoryList,
    errorMessage,
    pickupAddress,
    destinationAddress,
    isPickedUp,
    isSender,
    senderAddressIndex,
    receiverAddressIndex,
    senderCountryCode,
    receiverCountryCode,
    distance,
    extraCharge,
    payerIndex,
    paymentIndex,
    acceptTerms,
    digitalPaymentName,
    selectedOfflineBankIndex,
    offlineMethodList,
    whyChooseDetails,
    videoContentDetails,
    parcelInstructionList,
    instructionSelectedIndex,
    customNote,
    selectedIndexNote,
    mostDmTipAmount,
    tips,
    selectedTips,
    canShowTipsField,
    isDmTipSave,
    isLoading,
    actionStatus,
    actionMessage,
  ];
}
