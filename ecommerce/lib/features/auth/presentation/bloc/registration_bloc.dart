import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/auth/domain/models/delivery_man_vehicles_model.dart';
import 'package:ecommerce/features/auth/domain/services/deliveryman_registration_service_interface.dart';
import 'package:ecommerce/features/auth/domain/services/store_registration_service_interface.dart';
import 'package:ecommerce/features/auth/presentation/bloc/registration_event.dart';
import 'package:ecommerce/features/auth/presentation/bloc/registration_state.dart';
import 'package:ecommerce/features/location/domain/entities/zone_response.dart';
import 'package:ecommerce/features/location/domain/repositories/location_repository.dart';
import 'package:ecommerce/features/splash/presentation/bloc/splash_bloc.dart';

export 'registration_event.dart';
export 'registration_state.dart';

/// Single bloc that handles both store and deliveryman registration.
/// Provided screen-scoped via [BlocProvider] at each registration screen.
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final StoreRegistrationServiceInterface storeService;
  final DeliverymanRegistrationServiceInterface dmService;

  RegistrationBloc({
    required this.storeService,
    required this.dmService,
  }) : super(const RegistrationState()) {
    on<RegistrationInitialized>(_onInitialized);
    on<RegistrationPassToggled>(_onPassToggled);
    on<RegistrationPassValidated>(_onPassValidated);
    on<RegistrationZoneIndexSet>(_onZoneIndexSet);
    on<RegistrationLocationSet>(_onLocationSet);
    on<RegistrationModuleIndexSelected>(_onModuleIndexSelected);
    on<RegistrationStatusChanged>(_onStatusChanged);
    on<RegistrationReset>(_onReset);
    // store
    on<RegistrationImagePicked>(_onImagePicked);
    on<RegistrationMinTimeChanged>(_onMinTimeChanged);
    on<RegistrationMaxTimeChanged>(_onMaxTimeChanged);
    on<RegistrationTimeUnitChanged>(_onTimeUnitChanged);
    on<StoreRegistrationSubmitted>(_onStoreSubmitted);
    // deliveryman
    on<DmImagePicked>(_onDmImagePicked);
    on<DmIdentityImageRemoved>(_onDmIdentityImageRemoved);
    on<DmImageRemoved>(_onDmImageRemoved);
    on<DmIdentityTypeIndexSet>(_onDmIdentityTypeIndexSet);
    on<DmTypeIndexSet>(_onDmTypeIndexSet);
    on<DmVehicleIndexSet>(_onDmVehicleIndexSet);
    on<DmTermsToggled>(_onDmTermsToggled);
    on<DeliveryManRegistrationSubmitted>(_onDmSubmitted);
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  Future<void> _onInitialized(
    RegistrationInitialized event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(
      clearPickedLogo: true,
      clearPickedCover: true,
      clearPickedDmImage: true,
      selectedZoneIndex: -1,
      clearZoneIds: true,
      selectedModuleIndex: -1,
      status_: 0.4,
      storeMinTime: '--',
      storeMaxTime: '--',
      storeTimeUnit: 'minute',
      pickedIdentities: [],
      identityTypeIndex: 0,
      dmTypeIndex: 0,
    ));

    // Load zone list
    emit(state.copyWith(status: RegistrationStatus.loading));
    final List zones = event.kind == 'store'
        ? (await storeService.getZoneList() ?? [])
        : (await dmService.getZoneList() ?? []);

    if (zones.isNotEmpty) {
      emit(state.copyWith(
        status: RegistrationStatus.initial,
        zoneList: List.from(zones),
      ));

      // Set default location from splash config
      final config = getIt<SplashBloc>().state.configModel!;
      final defaultLat = double.parse(config.defaultLocation?.lat ?? '0');
      final defaultLng = double.parse(config.defaultLocation?.lng ?? '0');
      add(RegistrationLocationSet(LatLng(defaultLat, defaultLng)));

      // Load modules for first zone
      final moduleZoneId = zones[0].id as int?;
      await _loadModules(moduleZoneId, emit, event.kind);
    } else {
      emit(state.copyWith(status: RegistrationStatus.initial));
    }

    // For deliveryman also load vehicles
    if (event.kind == 'deliveryman') {
      final vehicles = await dmService.getVehicleList() ?? [];
      if (vehicles.isNotEmpty) {
        final vehicleIds = dmService.prepareVehicleIds(
          vehicles.cast<DeliveryManVehicleModel>(),
        );
        emit(state.copyWith(
          vehicles: vehicles.cast<DeliveryManVehicleModel>(),
          vehicleIds: vehicleIds,
        ));
      }
    }
  }

  Future<void> _loadModules(
    int? zoneId,
    Emitter<RegistrationState> emit,
    String kind,
  ) async {
    emit(state.copyWith(clearModuleList: true, selectedModuleIndex: -1));
    final modules = kind == 'store'
        ? await storeService.getModules(zoneId)
        : await dmService.getModules(zoneId);
    if (modules != null && modules.isNotEmpty) {
      emit(state.copyWith(moduleList: modules));
    }
  }

  void _onPassToggled(
    RegistrationPassToggled event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(showPassView: !state.showPassView));
  }

  void _onPassValidated(
    RegistrationPassValidated event,
    Emitter<RegistrationState> emit,
  ) {
    final p = event.password;
    emit(state.copyWith(
      lengthCheck: p.length > 7,
      lowercaseCheck: p.contains(RegExp(r'[a-z]')),
      uppercaseCheck: p.contains(RegExp(r'[A-Z]')),
      spatialCheck: p.contains(RegExp(r'[ .!@#$&*~^%]')),
      numberCheck: p.contains(RegExp(r'[\d+]')),
    ));
  }

  Future<void> _onZoneIndexSet(
    RegistrationZoneIndexSet event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(
      selectedZoneIndex: event.index,
      clearModuleList: true,
      selectedModuleIndex: -1,
    ));
    if (event.index != null &&
        event.index! >= 0 &&
        state.zoneList != null &&
        event.index! < state.zoneList!.length) {
      await _loadModules(state.zoneList![event.index!].id, emit, 'shared');
    }
  }

  Future<void> _onLocationSet(
    RegistrationLocationSet event,
    Emitter<RegistrationState> emit,
  ) async {
    final location = event.location;
    final zoneEither = await getIt<LocationRepository>().getZone(
      location.latitude.toString(),
      location.longitude.toString(),
      handleError: true,
    );
    final ZoneResult response = zoneEither.fold(
      (_) => const ZoneResult(
        isSuccess: false,
        message: null,
        zoneIds: [],
        zoneData: [],
        areaIds: [],
      ),
      (z) => z,
    );
    final geoEither = await getIt<LocationRepository>().getAddressFromGeocode(
      LatLng(location.latitude, location.longitude),
    );
    final address = geoEither.fold((_) => 'Unknown Location Found', (a) => a);

    if (response.isSuccess && response.zoneIds.isNotEmpty) {
      final zoneIds = response.zoneIds;
      final selectedZoneIndex = storeService.prepareSelectedZoneIndex(
        zoneIds,
        state.zoneList,
      );
      emit(state.copyWith(
        location: location,
        address: address,
        zoneIds: zoneIds,
        selectedZoneIndex: selectedZoneIndex,
      ));
    } else {
      emit(state.copyWith(
        clearLocation: true,
        clearZoneIds: true,
        address: address,
      ));
    }
  }

  void _onModuleIndexSelected(
    RegistrationModuleIndexSelected event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(selectedModuleIndex: event.index));
  }

  void _onStatusChanged(
    RegistrationStatusChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(status_: event.value));
  }

  void _onReset(RegistrationReset event, Emitter<RegistrationState> emit) {
    emit(const RegistrationState());
  }

  // ── Store ─────────────────────────────────────────────────────────────────

  Future<void> _onImagePicked(
    RegistrationImagePicked event,
    Emitter<RegistrationState> emit,
  ) async {
    if (event.isRemove) {
      emit(state.copyWith(clearPickedLogo: true, clearPickedCover: true));
      return;
    }
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      if (event.isLogo) {
        emit(state.copyWith(pickedLogo: file));
      } else {
        emit(state.copyWith(pickedCover: file));
      }
    }
  }

  void _onMinTimeChanged(
    RegistrationMinTimeChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(storeMinTime: event.time));
  }

  void _onMaxTimeChanged(
    RegistrationMaxTimeChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(storeMaxTime: event.time));
  }

  void _onTimeUnitChanged(
    RegistrationTimeUnitChanged event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(storeTimeUnit: event.unit));
  }

  Future<void> _onStoreSubmitted(
    StoreRegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(status: RegistrationStatus.loading));
    await storeService.registerStore(
      event.storeBody,
      state.pickedLogo,
      state.pickedCover,
    );
    emit(state.copyWith(status: RegistrationStatus.success));
  }

  // ── Deliveryman ───────────────────────────────────────────────────────────

  Future<void> _onDmImagePicked(
    DmImagePicked event,
    Emitter<RegistrationState> emit,
  ) async {
    if (event.isRemove) {
      emit(state.copyWith(
        clearPickedDmImage: true,
        pickedIdentities: [],
      ));
      return;
    }
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      if (event.isPhoto) {
        emit(state.copyWith(pickedDmImage: file));
      } else {
        emit(state.copyWith(
          pickedIdentities: [...state.pickedIdentities, file],
        ));
      }
    }
  }

  void _onDmIdentityImageRemoved(
    DmIdentityImageRemoved event,
    Emitter<RegistrationState> emit,
  ) {
    final updated = List<XFile>.from(state.pickedIdentities)
      ..removeAt(event.index);
    emit(state.copyWith(pickedIdentities: updated));
  }

  void _onDmImageRemoved(
    DmImageRemoved event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(clearPickedDmImage: true));
  }

  void _onDmIdentityTypeIndexSet(
    DmIdentityTypeIndexSet event,
    Emitter<RegistrationState> emit,
  ) {
    int index = 0;
    for (int i = 0; i < RegistrationState.identityTypeList.length; i++) {
      if (RegistrationState.identityTypeList[i] == event.identityType) {
        index = i;
        break;
      }
    }
    emit(state.copyWith(identityTypeIndex: index));
  }

  void _onDmTypeIndexSet(
    DmTypeIndexSet event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(dmTypeIndex: event.dmType));
  }

  void _onDmVehicleIndexSet(
    DmVehicleIndexSet event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(vehicleIndex: event.index));
  }

  void _onDmTermsToggled(
    DmTermsToggled event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(acceptTerms: !state.acceptTerms));
  }

  Future<void> _onDmSubmitted(
    DeliveryManRegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(state.copyWith(status: RegistrationStatus.loading));
    final multiParts = dmService.prepareMultipart(
      state.pickedDmImage,
      state.pickedIdentities,
    );
    await dmService.registerDeliveryMan(event.deliveryManBody, multiParts);
    emit(state.copyWith(status: RegistrationStatus.success));
  }
}
