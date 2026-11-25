import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/common/models/module_model.dart';
import 'package:ecommerce/features/auth/domain/models/delivery_man_vehicles_model.dart';
import 'package:ecommerce/features/location/domain/models/zone_data_model.dart';

enum RegistrationStatus { initial, loading, success, error }

class RegistrationState extends Equatable {
  final RegistrationStatus status;
  final String? errorMessage;

  // ── Shared zone/module fields ─────────────────────────────────────────────
  final List<ZoneDataModel>? zoneList;
  final int? selectedZoneIndex;
  final List<int>? zoneIds;
  final List<ModuleModel>? moduleList;
  final int? selectedModuleIndex;
  final String? address;
  final LatLng? location;

  // ── Stepper ───────────────────────────────────────────────────────────────
  final double status_;   // 0.4 = step 1, 0.6 = step 2, 1.0 = done
  final bool showPassView;

  // ── Password checks ───────────────────────────────────────────────────────
  final bool lengthCheck;
  final bool numberCheck;
  final bool uppercaseCheck;
  final bool lowercaseCheck;
  final bool spatialCheck;

  // ── Store images ──────────────────────────────────────────────────────────
  final XFile? pickedLogo;
  final XFile? pickedCover;
  final String storeMinTime;
  final String storeMaxTime;
  final String storeTimeUnit;

  // ── Deliveryman ───────────────────────────────────────────────────────────
  final XFile? pickedDmImage;
  final List<XFile> pickedIdentities;
  final int identityTypeIndex;
  final int dmTypeIndex;
  final List<DeliveryManVehicleModel>? vehicles;
  final List<int?>? vehicleIds;
  final int? vehicleIndex;
  final bool acceptTerms;

  static const List<String> identityTypeList = [
    'passport',
    'driving_license',
    'nid',
  ];
  static const List<String?> dmTypeList = [
    'select_delivery_type',
    'freelancer',
    'salary_based',
  ];

  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.errorMessage,
    this.zoneList,
    this.selectedZoneIndex = 0,
    this.zoneIds,
    this.moduleList,
    this.selectedModuleIndex = -1,
    this.address,
    this.location,
    this.status_ = 0.4,
    this.showPassView = false,
    this.lengthCheck = false,
    this.numberCheck = false,
    this.uppercaseCheck = false,
    this.lowercaseCheck = false,
    this.spatialCheck = false,
    this.pickedLogo,
    this.pickedCover,
    this.storeMinTime = '--',
    this.storeMaxTime = '--',
    this.storeTimeUnit = 'minute',
    this.pickedDmImage,
    this.pickedIdentities = const [],
    this.identityTypeIndex = 0,
    this.dmTypeIndex = 0,
    this.vehicles,
    this.vehicleIds,
    this.vehicleIndex = 0,
    this.acceptTerms = true,
  });

  RegistrationState copyWith({
    RegistrationStatus? status,
    String? errorMessage,
    List<ZoneDataModel>? zoneList,
    int? selectedZoneIndex,
    List<int>? zoneIds,
    List<ModuleModel>? moduleList,
    int? selectedModuleIndex,
    String? address,
    LatLng? location,
    double? status_,
    bool? showPassView,
    bool? lengthCheck,
    bool? numberCheck,
    bool? uppercaseCheck,
    bool? lowercaseCheck,
    bool? spatialCheck,
    XFile? pickedLogo,
    XFile? pickedCover,
    String? storeMinTime,
    String? storeMaxTime,
    String? storeTimeUnit,
    XFile? pickedDmImage,
    List<XFile>? pickedIdentities,
    int? identityTypeIndex,
    int? dmTypeIndex,
    List<DeliveryManVehicleModel>? vehicles,
    List<int?>? vehicleIds,
    int? vehicleIndex,
    bool? acceptTerms,
    bool clearPickedLogo = false,
    bool clearPickedCover = false,
    bool clearPickedDmImage = false,
    bool clearLocation = false,
    bool clearZoneIds = false,
    bool clearModuleList = false,
    bool clearError = false,
  }) {
    return RegistrationState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      zoneList: zoneList ?? this.zoneList,
      selectedZoneIndex: selectedZoneIndex ?? this.selectedZoneIndex,
      zoneIds: clearZoneIds ? null : (zoneIds ?? this.zoneIds),
      moduleList: clearModuleList ? null : (moduleList ?? this.moduleList),
      selectedModuleIndex: selectedModuleIndex ?? this.selectedModuleIndex,
      address: address ?? this.address,
      location: clearLocation ? null : (location ?? this.location),
      status_: status_ ?? this.status_,
      showPassView: showPassView ?? this.showPassView,
      lengthCheck: lengthCheck ?? this.lengthCheck,
      numberCheck: numberCheck ?? this.numberCheck,
      uppercaseCheck: uppercaseCheck ?? this.uppercaseCheck,
      lowercaseCheck: lowercaseCheck ?? this.lowercaseCheck,
      spatialCheck: spatialCheck ?? this.spatialCheck,
      pickedLogo: clearPickedLogo ? null : (pickedLogo ?? this.pickedLogo),
      pickedCover: clearPickedCover ? null : (pickedCover ?? this.pickedCover),
      storeMinTime: storeMinTime ?? this.storeMinTime,
      storeMaxTime: storeMaxTime ?? this.storeMaxTime,
      storeTimeUnit: storeTimeUnit ?? this.storeTimeUnit,
      pickedDmImage:
          clearPickedDmImage ? null : (pickedDmImage ?? this.pickedDmImage),
      pickedIdentities: pickedIdentities ?? this.pickedIdentities,
      identityTypeIndex: identityTypeIndex ?? this.identityTypeIndex,
      dmTypeIndex: dmTypeIndex ?? this.dmTypeIndex,
      vehicles: vehicles ?? this.vehicles,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      vehicleIndex: vehicleIndex ?? this.vehicleIndex,
      acceptTerms: acceptTerms ?? this.acceptTerms,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        zoneList,
        selectedZoneIndex,
        zoneIds,
        moduleList,
        selectedModuleIndex,
        address,
        location?.latitude,
        location?.longitude,
        status_,
        showPassView,
        lengthCheck,
        numberCheck,
        uppercaseCheck,
        lowercaseCheck,
        spatialCheck,
        pickedLogo,
        pickedCover,
        storeMinTime,
        storeMaxTime,
        storeTimeUnit,
        pickedDmImage,
        pickedIdentities,
        identityTypeIndex,
        dmTypeIndex,
        vehicles,
        vehicleIds,
        vehicleIndex,
        acceptTerms,
      ];
}
