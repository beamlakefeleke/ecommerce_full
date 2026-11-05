import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' as getx;
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/checkout/domain/entities/time_slot.dart';
import 'package:ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_distance_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_dm_tip_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_extra_charge_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_offline_methods_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/place_prescription_order_usecase.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/helper/network_info.dart';
import 'package:ecommerce/util/app_constants.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository repository;
  final GetOfflineMethodsUseCase getOfflineMethods;
  final GetDmTipMostTappedUseCase getDmTipMostTapped;
  final GetExtraChargeUseCase getExtraCharge;
  final GetDistanceUseCase getDistance;
  final PlaceOrderUseCase placeOrder;
  final PlacePrescriptionOrderUseCase placePrescriptionOrder;

  CheckoutBloc({
    required this.repository,
    required this.getOfflineMethods,
    required this.getDmTipMostTapped,
    required this.getExtraCharge,
    required this.getDistance,
    required this.placeOrder,
    required this.placePrescriptionOrder,
  }) : super(const CheckoutState()) {
    on<CheckoutPrevDataCleared>(_onPrevDataCleared);
    on<CheckoutTimeSlotInitialized>(_onTimeSlotInitialized);
    on<CheckoutOrderTypeChanged>(
      (e, emit) => emit(state.copyWith(orderType: e.orderType)),
    );
    on<CheckoutPaymentMethodSet>(
      (e, emit) => emit(state.copyWith(paymentMethodIndex: e.index)),
    );
    on<CheckoutDigitalPaymentNameChanged>(
      (e, emit) => emit(state.copyWith(digitalPaymentName: e.name)),
    );
    on<CheckoutPartialPaymentToggled>(
      (e, emit) => emit(state.copyWith(isPartialPay: !state.isPartialPay)),
    );
    on<CheckoutAddressIndexSet>(
      (e, emit) => emit(state.copyWith(addressIndex: e.index)),
    );
    on<CheckoutGuestAddressSet>(
      (e, emit) => emit(
        e.address == null
            ? state.copyWith(clearGuestAddress: true)
            : state.copyWith(guestAddress: e.address),
      ),
    );
    on<CheckoutPreferableTimeSet>(
      (e, emit) => emit(state.copyWith(preferableTime: e.time)),
    );
    on<CheckoutTipsFieldToggled>(
      (e, emit) =>
          emit(state.copyWith(canShowTipsField: !state.canShowTipsField)),
    );
    on<CheckoutDmTipSaveToggled>(
      (e, emit) => emit(state.copyWith(isDmTipSave: !state.isDmTipSave)),
    );
    on<CheckoutTipsAmountChanged>(
      (e, emit) => emit(state.copyWith(tips: e.tips)),
    );
    on<CheckoutOfflineBankSelected>(
      (e, emit) => emit(state.copyWith(selectedOfflineBankIndex: e.index)),
    );
    on<CheckoutExpandToggled>(
      (e, emit) => emit(state.copyWith(isExpand: !state.isExpand)),
    );
    on<CheckoutExpandedUpdated>(
      (e, emit) => emit(state.copyWith(isExpanded: e.status)),
    );
    on<CheckoutTotalAmountSet>(
      (e, emit) => emit(state.copyWith(viewTotalPrice: e.amount)),
    );
    on<CheckoutCountryDialCodeChanged>(
      (e, emit) => emit(state.copyWith(countryDialCode: e.dialCode)),
    );
    on<CheckoutTimeSlotUpdated>(
      (e, emit) => emit(state.copyWith(selectedTimeSlot: e.index)),
    );
    on<CheckoutInstructionSet>(_onInstructionSet);
    on<CheckoutTipsIndexUpdated>(_onTipsIndexUpdated);
    on<CheckoutDmTipMostTappedRequested>(_onDmTipMostTapped);
    on<CheckoutOfflineMethodsRequested>(_onOfflineMethods);
    on<CheckoutDistanceRequested>(_onDistanceRequested);
    on<CheckoutAttachmentPicked>(_onAttachmentPicked);
    on<CheckoutPrescriptionImagePicked>(_onPrescriptionImagePicked);
    on<CheckoutPrescriptionImageRemoved>(_onPrescriptionImageRemoved);
    on<CheckoutDateSlotUpdated>(_onDateSlotUpdated);
    on<CheckoutOrderPlaced>(_onOrderPlaced);
    on<CheckoutPrescriptionOrderPlaced>(_onPrescriptionOrderPlaced);
  }

  SplashController get _splash => getx.Get.find<SplashController>();

  void _onPrevDataCleared(
    CheckoutPrevDataCleared event,
    Emitter<CheckoutState> emit,
  ) {
    emit(
      state.copyWith(
        addressIndex: 0,
        acceptTerms: true,
        paymentMethodIndex: -1,
        selectedDateSlot: 0,
        selectedTimeSlot: 0,
        distance: null,
        clearAttachment: true,
      ),
    );
  }

  void _onTimeSlotInitialized(
    CheckoutTimeSlotInitialized event,
    Emitter<CheckoutState> emit,
  ) {
    final duration = _splash.configModel!.scheduleOrderSlotDuration!;
    final slots = repository.initializeTimeSlot(event.store, duration);
    final all = repository.initializeTimeSlot(event.store, duration);
    final validated = repository.validateTimeSlot(
      all,
      0,
      event.store.orderPlaceToScheduleInterval,
      _splash.configModel!.moduleConfig!.module!.orderPlaceToScheduleInterval!,
    );
    emit(
      state.copyWith(
        store: event.store,
        timeSlots: validated.isNotEmpty ? validated : slots,
        allTimeSlots: all,
      ),
    );
  }

  void _onInstructionSet(
    CheckoutInstructionSet event,
    Emitter<CheckoutState> emit,
  ) {
    emit(
      state.copyWith(
        selectedInstruction: state.selectedInstruction == event.index
            ? -1
            : event.index,
      ),
    );
  }

  void _onTipsIndexUpdated(
    CheckoutTipsIndexUpdated event,
    Emitter<CheckoutState> emit,
  ) {
    final double tips = (event.index == 0 || event.index == 5)
        ? 0
        : double.parse(AppConstants.tips[event.index]);
    emit(state.copyWith(selectedTips: event.index, tips: tips));
  }

  Future<void> _onDmTipMostTapped(
    CheckoutDmTipMostTappedRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    final result = await getDmTipMostTapped(const NoParams());
    result.fold(
      (_) {},
      (amount) => emit(state.copyWith(mostDmTipAmount: amount)),
    );
  }

  Future<void> _onOfflineMethods(
    CheckoutOfflineMethodsRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    final result = await getOfflineMethods(const NoParams());
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (list) => emit(state.copyWith(offlineMethodList: list)),
    );
  }

  Future<void> _onDistanceRequested(
    CheckoutDistanceRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(distance: -1));
    final result = await getDistance(
      GetDistanceParams(
        origin: event.origin,
        destination: event.destination,
        isDuration: event.isDuration,
      ),
    );
    await result.fold(
      (f) async => emit(state.copyWith(errorMessage: f.message)),
      (distance) async {
        double? extra = state.extraCharge;
        if (!event.fromDashboard) {
          final extraResult = await getExtraCharge(distance);
          extra = extraResult.getOrElse((_) => 0);
        }
        emit(state.copyWith(distance: distance, extraCharge: extra));
      },
    );
  }

  Future<void> _onAttachmentPicked(
    CheckoutAttachmentPicked event,
    Emitter<CheckoutState> emit,
  ) async {
    XFile? attachment = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (attachment != null) {
      attachment = await NetworkInfo.compressImage(attachment);
      final raw = await attachment.readAsBytes();
      emit(state.copyWith(orderAttachment: attachment, rawAttachment: raw));
    }
  }

  Future<void> _onPrescriptionImagePicked(
    CheckoutPrescriptionImagePicked event,
    Emitter<CheckoutState> emit,
  ) async {
    if (event.isRemove) {
      emit(state.copyWith(pickedPrescriptions: []));
      return;
    }
    final XFile? xFile = await ImagePicker().pickImage(
      source: event.isCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50,
    );
    if (xFile != null) {
      emit(
        state.copyWith(
          pickedPrescriptions: [...state.pickedPrescriptions, xFile],
        ),
      );
    }
  }

  void _onPrescriptionImageRemoved(
    CheckoutPrescriptionImageRemoved event,
    Emitter<CheckoutState> emit,
  ) {
    final updated = List<XFile>.from(state.pickedPrescriptions)
      ..removeAt(event.index);
    emit(state.copyWith(pickedPrescriptions: updated));
  }

  void _onDateSlotUpdated(
    CheckoutDateSlotUpdated event,
    Emitter<CheckoutState> emit,
  ) {
    List<TimeSlot> timeSlots = state.timeSlots ?? [];
    if (state.allTimeSlots != null) {
      timeSlots = repository.validateTimeSlot(
        state.allTimeSlots!,
        event.index,
        event.interval,
        _splash
            .configModel!
            .moduleConfig!
            .module!
            .orderPlaceToScheduleInterval!,
      );
    }
    emit(state.copyWith(selectedDateSlot: event.index, timeSlots: timeSlots));
  }

  Future<void> _onOrderPlaced(
    CheckoutOrderPlaced event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearResult: true));
    final result = await placeOrder(
      PlaceOrderParams(
        body: event.body,
        orderAttachment: state.orderAttachment,
      ),
    );
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, errorMessage: f.message)),
      (r) => emit(
        state.copyWith(
          isLoading: false,
          placeOrderResult: r,
          clearAttachment: r.isSuccess,
        ),
      ),
    );
  }

  Future<void> _onPrescriptionOrderPlaced(
    CheckoutPrescriptionOrderPlaced event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearResult: true));
    final result = await placePrescriptionOrder(
      PlacePrescriptionOrderParams(
        storeId: event.storeId,
        distance: event.distance,
        address: event.address,
        longitude: event.longitude,
        latitude: event.latitude,
        note: event.note,
        orderAttachment: event.orderAttachment,
        dmTips: event.dmTips,
        deliveryInstruction: event.deliveryInstruction,
      ),
    );
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, errorMessage: f.message)),
      (r) => emit(
        state.copyWith(
          isLoading: false,
          placeOrderResult: r,
          clearAttachment: r.isSuccess,
        ),
      ),
    );
  }
}
