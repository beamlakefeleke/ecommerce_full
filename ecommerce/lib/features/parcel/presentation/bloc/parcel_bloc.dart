import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/address/data/models/address_model.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce/features/location/domain/repositories/location_repository.dart';
import 'package:ecommerce/features/parcel/data/models/place_details_model.dart';
import 'package:ecommerce/features/parcel/domain/usecases/parcel_usecases.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_event.dart';
import 'package:ecommerce/features/parcel/presentation/bloc/parcel_state.dart';
import 'package:ecommerce/util/app_constants.dart';

/// Event-driven replacement for the legacy `ParcelController`.
///
/// Fetches parcel-specific data through [ParcelRepository] usecases; delegates
/// offline-methods / dm-tip / distance / place-order to the migrated
/// [CheckoutRepository] (same split the legacy `ParcelService` used); and
/// resolves zones through the migrated [LocationRepository].
///
/// No navigation or snackbars live here — one-shot outcomes surface via
/// [ParcelState.actionStatus] / [ParcelState.actionMessage] and the UI reacts
/// with a `BlocListener` (see `ParcelHelper`). Input is only via `add(Event)`.
class ParcelBloc extends Bloc<ParcelEvent, ParcelState> {
  final GetParcelCategoryUseCase getParcelCategory;
  final GetParcelInstructionUseCase getParcelInstruction;
  final GetWhyChooseDetailsUseCase getWhyChooseDetails;
  final GetVideoContentDetailsUseCase getVideoContentDetails;
  final GetPlaceDetailsUseCase getPlaceDetails;
  final CheckoutRepository checkoutRepository;
  final LocationRepository locationRepository;

  /// The user's saved address zone ids/zoneId, read lazily (the legacy flow
  /// used `AddressHelper.getUserAddressFromSharedPref()`). Injected so the
  /// bloc stays decoupled from the shared-prefs helper.
  final List<int> Function() currentZoneIds;
  final String? Function() currentContactPersonName;
  final String? Function() currentContactPersonNumber;

  ParcelBloc({
    required this.getParcelCategory,
    required this.getParcelInstruction,
    required this.getWhyChooseDetails,
    required this.getVideoContentDetails,
    required this.getPlaceDetails,
    required this.checkoutRepository,
    required this.locationRepository,
    required this.currentZoneIds,
    required this.currentContactPersonName,
    required this.currentContactPersonNumber,
  }) : super(const ParcelState()) {
    on<ParcelCategoryListRequested>(_onCategoryListRequested);
    on<WhyChooseDetailsRequested>(_onWhyChooseRequested);
    on<VideoContentDetailsRequested>(_onVideoContentRequested);
    on<ParcelInstructionRequested>(_onInstructionRequested);
    on<OfflineMethodListRequested>(_onOfflineMethodRequested);
    on<DmTipMostTappedRequested>(_onDmTipRequested);
    on<DistanceRequested>(_onDistanceRequested);
    on<LocationFromPlaceRequested>(_onLocationFromPlaceRequested);
    on<PickupAddressSet>(_onPickupAddressSet);
    on<DestinationAddressSet>(_onDestinationAddressSet);
    on<SenderAddressIndexSet>(_onSenderAddressIndexSet);
    on<ReceiverAddressIndexSet>(_onReceiverAddressIndexSet);
    on<CountryCodeSet>(_onCountryCodeSet);
    on<IsPickedUpToggled>(_onIsPickedUpToggled);
    on<IsSenderToggled>(_onIsSenderToggled);
    on<TermsToggled>(_onTermsToggled);
    on<PayerIndexSet>(_onPayerIndexSet);
    on<PaymentIndexSet>(_onPaymentIndexSet);
    on<DigitalPaymentNameChanged>(_onDigitalPaymentNameChanged);
    on<OfflineBankSelected>(_onOfflineBankSelected);
    on<InstructionSelectedIndexSet>(_onInstructionSelectedIndexSet);
    on<SelectedNoteIndexSet>(_onSelectedNoteIndexSet);
    on<CustomNoteSet>(_onCustomNoteSet);
    on<TipsFieldToggled>(_onTipsFieldToggled);
    on<TipsAmountSet>(_onTipsAmountSet);
    on<DmTipSaveToggled>(_onDmTipSaveToggled);
    on<TipsIndexUpdated>(_onTipsIndexUpdated);
    on<LoaderToggled>(_onLoaderToggled);
    on<ParcelOrderPlaced>(_onOrderPlaced);
  }

  Future<void> _onCategoryListRequested(
    ParcelCategoryListRequested event,
    Emitter<ParcelState> emit,
  ) async {
    emit(state.copyWith(status: ParcelStatus.loading));
    final result = await getParcelCategory(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ParcelStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (list) => emit(
        state.copyWith(
          status: ParcelStatus.loaded,
          parcelCategoryList: list,
        ),
      ),
    );
  }

  Future<void> _onWhyChooseRequested(
    WhyChooseDetailsRequested event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await getWhyChooseDetails(const NoParams());
    result.fold(
      (_) {},
      (details) => emit(state.copyWith(whyChooseDetails: details)),
    );
  }

  Future<void> _onVideoContentRequested(
    VideoContentDetailsRequested event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await getVideoContentDetails(const NoParams());
    result.fold(
      (_) {},
      (details) => emit(state.copyWith(videoContentDetails: details)),
    );
  }

  Future<void> _onInstructionRequested(
    ParcelInstructionRequested event,
    Emitter<ParcelState> emit,
  ) async {
    emit(state.copyWith(clearParcelInstructionList: true));
    final result = await getParcelInstruction(1);
    result.fold(
      (_) {},
      (list) => emit(state.copyWith(parcelInstructionList: list)),
    );
  }

  Future<void> _onOfflineMethodRequested(
    OfflineMethodListRequested event,
    Emitter<ParcelState> emit,
  ) async {
    emit(state.copyWith(clearOfflineMethodList: true));
    final result = await checkoutRepository.getOfflineMethodList();
    result.fold(
      (_) {},
      (list) => emit(state.copyWith(offlineMethodList: list)),
    );
  }

  Future<void> _onDmTipRequested(
    DmTipMostTappedRequested event,
    Emitter<ParcelState> emit,
  ) async {
    final result = await checkoutRepository.getDmTipMostTapped();
    result.fold(
      (_) {},
      (amount) => emit(state.copyWith(mostDmTipAmount: amount)),
    );
  }

  Future<void> _onDistanceRequested(
    DistanceRequested event,
    Emitter<ParcelState> emit,
  ) async {
    emit(state.copyWith(distance: -1));
    final origin = LatLng(
      double.parse(event.pickupAddress.latitude!),
      double.parse(event.pickupAddress.longitude!),
    );
    final destination = LatLng(
      double.parse(event.destinationAddress.latitude!),
      double.parse(event.destinationAddress.longitude!),
    );
    final distanceResult = await checkoutRepository.getDistanceInKm(
      origin,
      destination,
    );
    final double distance = distanceResult.getOrElse((_) => -1);

    final chargeResult = await checkoutRepository.getExtraCharge(distance);
    final double? extraCharge = chargeResult.fold((_) => null, (c) => c);

    emit(state.copyWith(distance: distance, extraCharge: extraCharge));
  }

  Future<void> _onLocationFromPlaceRequested(
    LocationFromPlaceRequested event,
    Emitter<ParcelState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: ParcelActionStatus.inProgress,
        actionMessage: null,
      ),
    );
    final result = await getPlaceDetails(event.placeId);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          actionStatus: ParcelActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (placeDetails) async =>
          _processAddressAndAction(placeDetails, event, emit),
    );
  }

  Future<void> _processAddressAndAction(
    PlaceDetailsModel placeDetails,
    LocationFromPlaceRequested event,
    Emitter<ParcelState> emit,
  ) async {
    if (placeDetails.status != 'OK' || placeDetails.result?.geometry == null) {
      emit(state.copyWith(actionStatus: ParcelActionStatus.none));
      return;
    }

    final AddressModel address = AddressModel(
      address: event.address,
      addressType: 'others',
      latitude: placeDetails.result!.geometry!.location!.lat.toString(),
      longitude: placeDetails.result!.geometry!.location!.lng.toString(),
      contactPersonName: currentContactPersonName(),
      contactPersonNumber: currentContactPersonNumber(),
    );

    final zoneResult = await locationRepository.getZone(
      address.latitude,
      address.longitude,
    );

    await zoneResult.fold(
      (failure) async => emit(
        state.copyWith(
          actionStatus: ParcelActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (zone) async {
        if (!zone.isSuccess) {
          emit(
            state.copyWith(
              actionStatus: ParcelActionStatus.failure,
              actionMessage: zone.message,
            ),
          );
          return;
        }
        bool inZone = false;
        for (final int zoneId in currentZoneIds()) {
          if (zone.zoneIds.contains(zoneId)) {
            inZone = true;
            break;
          }
        }
        if (!inZone) {
          emit(
            state.copyWith(
              actionStatus: ParcelActionStatus.failure,
              actionMessage:
                  'your_selected_location_is_from_different_zone_store',
            ),
          );
          return;
        }
        address.zoneId = zone.zoneIds[0];
        address.zoneIds = [...zone.zoneIds];
        address.zoneData = [...zone.zoneData];
        if (event.isPickedUp) {
          emit(
            state.copyWith(
              pickupAddress: address,
              actionStatus: ParcelActionStatus.success,
            ),
          );
        } else {
          emit(
            state.copyWith(
              destinationAddress: address,
              actionStatus: ParcelActionStatus.success,
            ),
          );
        }
      },
    );
  }

  void _onPickupAddressSet(PickupAddressSet event, Emitter<ParcelState> emit) {
    emit(
      event.address == null
          ? state.copyWith(clearPickupAddress: true)
          : state.copyWith(pickupAddress: event.address),
    );
  }

  void _onDestinationAddressSet(
    DestinationAddressSet event,
    Emitter<ParcelState> emit,
  ) {
    emit(
      event.address == null
          ? state.copyWith(clearDestinationAddress: true)
          : state.copyWith(destinationAddress: event.address),
    );
  }

  void _onSenderAddressIndexSet(
    SenderAddressIndexSet event,
    Emitter<ParcelState> emit,
  ) => emit(state.copyWith(senderAddressIndex: event.index));

  void _onReceiverAddressIndexSet(
    ReceiverAddressIndexSet event,
    Emitter<ParcelState> emit,
  ) => emit(state.copyWith(receiverAddressIndex: event.index));

  void _onCountryCodeSet(CountryCodeSet event, Emitter<ParcelState> emit) {
    emit(
      event.isSender
          ? state.copyWith(senderCountryCode: event.code)
          : state.copyWith(receiverCountryCode: event.code),
    );
  }

  void _onIsPickedUpToggled(
    IsPickedUpToggled event,
    Emitter<ParcelState> emit,
  ) => emit(state.copyWith(isPickedUp: event.isPickedUp));

  void _onIsSenderToggled(IsSenderToggled event, Emitter<ParcelState> emit) =>
      emit(state.copyWith(isSender: event.isSender));

  void _onTermsToggled(TermsToggled event, Emitter<ParcelState> emit) =>
      emit(state.copyWith(acceptTerms: !state.acceptTerms));

  void _onPayerIndexSet(PayerIndexSet event, Emitter<ParcelState> emit) {
    emit(
      state.copyWith(
        payerIndex: event.index,
        // mirrors legacy: selecting "receiver" forces payment index to 0
        paymentIndex: event.index == 1 ? 0 : state.paymentIndex,
      ),
    );
  }

  void _onPaymentIndexSet(PaymentIndexSet event, Emitter<ParcelState> emit) =>
      emit(state.copyWith(paymentIndex: event.index));

  void _onDigitalPaymentNameChanged(
    DigitalPaymentNameChanged event,
    Emitter<ParcelState> emit,
  ) => emit(state.copyWith(digitalPaymentName: event.name));

  void _onOfflineBankSelected(
    OfflineBankSelected event,
    Emitter<ParcelState> emit,
  ) => emit(state.copyWith(selectedOfflineBankIndex: event.index));

  void _onInstructionSelectedIndexSet(
    InstructionSelectedIndexSet event,
    Emitter<ParcelState> emit,
  ) => emit(state.copyWith(instructionSelectedIndex: event.index));

  void _onSelectedNoteIndexSet(
    SelectedNoteIndexSet event,
    Emitter<ParcelState> emit,
  ) {
    // null => commit the currently selected instruction index (legacy behavior)
    emit(
      state.copyWith(
        selectedIndexNote: event.index ?? state.instructionSelectedIndex,
      ),
    );
  }

  void _onCustomNoteSet(CustomNoteSet event, Emitter<ParcelState> emit) {
    // Mirrors legacy setCustomNote: a non-empty value overrides; otherwise the
    // text field's current text is used.
    final String note =
        (event.note != null && event.note!.isNotEmpty)
        ? event.note!
        : event.controllerText;
    emit(state.copyWith(customNote: note));
  }

  void _onTipsFieldToggled(TipsFieldToggled event, Emitter<ParcelState> emit) =>
      emit(state.copyWith(canShowTipsField: !state.canShowTipsField));

  void _onTipsAmountSet(TipsAmountSet event, Emitter<ParcelState> emit) =>
      emit(state.copyWith(tips: event.tips));

  void _onDmTipSaveToggled(DmTipSaveToggled event, Emitter<ParcelState> emit) =>
      emit(state.copyWith(isDmTipSave: !state.isDmTipSave));

  void _onTipsIndexUpdated(TipsIndexUpdated event, Emitter<ParcelState> emit) {
    final int index = event.index;
    final double tips = (index == 0 || index == 5)
        ? 0
        : double.parse(AppConstants.tips[index]);
    emit(state.copyWith(selectedTips: index, tips: tips));
  }

  void _onLoaderToggled(LoaderToggled event, Emitter<ParcelState> emit) =>
      emit(state.copyWith(isLoading: event.isEnable));

  Future<void> _onOrderPlaced(
    ParcelOrderPlaced event,
    Emitter<ParcelState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        actionStatus: ParcelActionStatus.inProgress,
        actionMessage: null,
      ),
    );
    final result = await checkoutRepository.placeOrder(
      event.placeOrderBody,
      null,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: ParcelActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (placeResult) {
        if (placeResult.isSuccess) {
          emit(
            state.copyWith(
              isLoading: false,
              actionStatus: ParcelActionStatus.success,
              actionMessage: placeResult.orderId,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isLoading: false,
              actionStatus: ParcelActionStatus.failure,
              actionMessage: placeResult.message,
            ),
          );
        }
      },
    );
  }
}
