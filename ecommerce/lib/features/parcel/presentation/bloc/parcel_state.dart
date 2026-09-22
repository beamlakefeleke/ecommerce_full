import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_category.dart';
import 'package:ecommerce/features/parcel/domain/entities/parcel_instruction.dart';
import 'package:ecommerce/features/parcel/domain/entities/video_content.dart';
import 'package:ecommerce/features/parcel/domain/entities/why_choose.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';

class ParcelState {
  final List<ParcelCategory>? parcelCategoryList;
  final AddressModel? pickupAddress;
  final AddressModel? destinationAddress;
  final bool isPickedUp;
  final bool isSender;
  final bool isLoading;
  final double distance;
  final List<String> payerTypes;
  final int payerIndex;
  final int paymentIndex;
  final bool acceptTerms;
  final double? extraCharge;
  final String? digitalPaymentName;
  final WhyChoose? whyChooseDetails;
  final VideoContent? videoContentDetails;
  final int selectedOfflineBankIndex;
  final List<ParcelInstruction>? parcelInstructionList;
  final int instructionselectedIndex;
  final String customNote;
  final int? selectedIndexNote;
  final int? senderAddressIndex;
  final int? receiverAddressIndex;
  final String? senderCountryCode;
  final String? receiverCountryCode;
  final List<OfflineMethodModel>? offlineMethodList;
  final int? mostDmTipAmount;
  final double tips;
  final int selectedTips;
  final bool canShowTipsField;
  final bool isDmTipSave;

  const ParcelState({
    this.parcelCategoryList,
    this.pickupAddress,
    this.destinationAddress,
    this.isPickedUp = true,
    this.isSender = true,
    this.isLoading = false,
    this.distance = -1,
    this.payerTypes = const ['sender', 'receiver'],
    this.payerIndex = 0,
    this.paymentIndex = -1,
    this.acceptTerms = true,
    this.extraCharge,
    this.digitalPaymentName,
    this.whyChooseDetails,
    this.videoContentDetails,
    this.selectedOfflineBankIndex = 0,
    this.parcelInstructionList,
    this.instructionselectedIndex = -1,
    this.customNote = '',
    this.selectedIndexNote = -1,
    this.senderAddressIndex = 0,
    this.receiverAddressIndex = 0,
    this.senderCountryCode,
    this.receiverCountryCode,
    this.offlineMethodList,
    this.mostDmTipAmount,
    this.tips = 0.0,
    this.selectedTips = 0,
    this.canShowTipsField = false,
    this.isDmTipSave = false,
  });

  ParcelState copyWith({
    List<ParcelCategory>? parcelCategoryList,
    AddressModel? pickupAddress,
    AddressModel? destinationAddress,
    bool? isPickedUp,
    bool? isSender,
    bool? isLoading,
    double? distance,
    int? payerIndex,
    int? paymentIndex,
    bool? acceptTerms,
    double? extraCharge,
    String? digitalPaymentName,
    WhyChoose? whyChooseDetails,
    VideoContent? videoContentDetails,
    int? selectedOfflineBankIndex,
    List<ParcelInstruction>? parcelInstructionList,
    int? instructionselectedIndex,
    String? customNote,
    int? selectedIndexNote,
    int? senderAddressIndex,
    int? receiverAddressIndex,
    String? senderCountryCode,
    String? receiverCountryCode,
    List<OfflineMethodModel>? offlineMethodList,
    int? mostDmTipAmount,
    double? tips,
    int? selectedTips,
    bool? canShowTipsField,
    bool? isDmTipSave,
  }) {
    return ParcelState(
      parcelCategoryList: parcelCategoryList ?? this.parcelCategoryList,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      isPickedUp: isPickedUp ?? this.isPickedUp,
      isSender: isSender ?? this.isSender,
      isLoading: isLoading ?? this.isLoading,
      distance: distance ?? this.distance,
      payerTypes: this.payerTypes,
      payerIndex: payerIndex ?? this.payerIndex,
      paymentIndex: paymentIndex ?? this.paymentIndex,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      extraCharge: extraCharge ?? this.extraCharge,
      digitalPaymentName: digitalPaymentName ?? this.digitalPaymentName,
      whyChooseDetails: whyChooseDetails ?? this.whyChooseDetails,
      videoContentDetails: videoContentDetails ?? this.videoContentDetails,
      selectedOfflineBankIndex: selectedOfflineBankIndex ?? this.selectedOfflineBankIndex,
      parcelInstructionList: parcelInstructionList ?? this.parcelInstructionList,
      instructionselectedIndex: instructionselectedIndex ?? this.instructionselectedIndex,
      customNote: customNote ?? this.customNote,
      selectedIndexNote: selectedIndexNote != null ? (selectedIndexNote == -1 ? null : selectedIndexNote) : this.selectedIndexNote,
      senderAddressIndex: senderAddressIndex != null ? (senderAddressIndex == -1 ? null : senderAddressIndex) : this.senderAddressIndex,
      receiverAddressIndex: receiverAddressIndex != null ? (receiverAddressIndex == -1 ? null : receiverAddressIndex) : this.receiverAddressIndex,
      senderCountryCode: senderCountryCode ?? this.senderCountryCode,
      receiverCountryCode: receiverCountryCode ?? this.receiverCountryCode,
      offlineMethodList: offlineMethodList ?? this.offlineMethodList,
      mostDmTipAmount: mostDmTipAmount ?? this.mostDmTipAmount,
      tips: tips ?? this.tips,
      selectedTips: selectedTips ?? this.selectedTips,
      canShowTipsField: canShowTipsField ?? this.canShowTipsField,
      isDmTipSave: isDmTipSave ?? this.isDmTipSave,
    );
  }
}
