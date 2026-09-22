import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:ecommerce/features/cart/presentation/bloc/cart_event.dart';
import 'package:ecommerce/features/checkout/domain/models/timeslote_model.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_distance_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_extra_charge_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_most_tipped_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/get_offline_methods_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/place_order_usecase.dart';
import 'package:ecommerce/features/checkout/domain/usecases/place_prescription_order_usecase.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:ecommerce/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:ecommerce/features/home/screens/home_screen.dart';
import 'package:ecommerce/features/order/controllers/order_controller.dart';
import 'package:ecommerce/features/profile/controllers/profile_controller.dart';
import 'package:ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/date_converter.dart';
import 'package:ecommerce/helper/network_info.dart';
import 'package:ecommerce/helper/responsive_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:universal_html/html.dart' as html;

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final PlaceOrderUseCase _placeOrder;
  final PlacePrescriptionOrderUseCase _placePrescriptionOrder;
  final GetDistanceUseCase _getDistance;
  final GetExtraChargeUseCase _getExtraCharge;
  final GetMostTippedUseCase _getMostTipped;
  final GetOfflineMethodsUseCase _getOfflineMethods;

  CheckoutBloc({
    required PlaceOrderUseCase placeOrderUseCase,
    required PlacePrescriptionOrderUseCase placePrescriptionOrderUseCase,
    required GetDistanceUseCase getDistanceUseCase,
    required GetExtraChargeUseCase getExtraChargeUseCase,
    required GetMostTippedUseCase getMostTippedUseCase,
    required GetOfflineMethodsUseCase getOfflineMethodsUseCase,
  }) : _placeOrder = placeOrderUseCase,
       _placePrescriptionOrder = placePrescriptionOrderUseCase,
       _getDistance = getDistanceUseCase,
       _getExtraCharge = getExtraChargeUseCase,
       _getMostTipped = getMostTippedUseCase,
       _getOfflineMethods = getOfflineMethodsUseCase,
       super(const CheckoutState()) {
    on<CheckoutInitialised>(_onInitialised);
    on<TimeSlotsInitialised>(_onTimeSlotsInitialised);
    on<DateSlotSelected>(_onDateSlotSelected);
    on<TimeSlotSelected>(_onTimeSlotSelected);
    on<DistanceCalculated>(_onDistanceCalculated);
    on<MostTippedAmountFetched>(_onMostTippedFetched);
    on<TipUpdated>(_onTipUpdated);
    on<CustomTipSet>(_onCustomTipSet);
    on<TipsFieldToggled>(_onTipsFieldToggled);
    on<DmTipSaveToggled>(_onDmTipSaveToggled);
    on<OfflineMethodListFetched>(_onOfflineMethodsFetched);
    on<OfflineBankSelected>(_onOfflineBankSelected);
    on<PaymentMethodSet>(_onPaymentMethodSet);
    on<DigitalPaymentNameChanged>(_onDigitalPaymentNameChanged);
    on<OrderTypeSet>(_onOrderTypeSet);
    on<PartialPaymentToggled>(_onPartialPaymentToggled);
    on<AddressIndexSet>(_onAddressIndexSet);
    on<GuestAddressSet>(_onGuestAddressSet);
    on<PrescriptionImagePicked>(_onPrescriptionImagePicked);
    on<PrescriptionImageRemoved>(_onPrescriptionImageRemoved);
    on<OrderAttachmentPicked>(_onOrderAttachmentPicked);
    on<OrderPlaced>(_onOrderPlaced);
    on<PrescriptionOrderPlaced>(_onPrescriptionOrderPlaced);
    on<AcceptTermsToggled>(_onAcceptTermsToggled);
    on<InstructionSelected>(_onInstructionSelected);
    on<ExpandToggled>(_onExpandToggled);
    on<PreferableTimeSet>(_onPreferableTimeSet);
    on<TotalAmountSet>(_onTotalAmountSet);
    on<CheckoutCleared>(_onCheckoutCleared);
  }

  // ─── Initialisation ──────────────────────────────────────────────────────

  Future<void> _onInitialised(
    CheckoutInitialised event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.loading));
    // MostTipped is fire-and-forget — don't block on it
    _getMostTipped().then((result) {
      result.fold((_) {}, (amount) => add(MostTippedAmountFetched()));
    });
  }

  Future<void> _onTimeSlotsInitialised(
    TimeSlotsInitialised event,
    Emitter<CheckoutState> emit,
  ) async {
    final slots = _buildTimeSlots(event.store, event.scheduleSlotDuration);
    final validated = _filterSlots(
      slots,
      0,
      event.store.orderPlaceToScheduleInterval,
    );
    emit(
      state.copyWith(
        status: CheckoutStatus.success,
        store: event.store,
        timeSlots: validated,
        allTimeSlots: slots,
      ),
    );
  }

  // ─── Time slots ──────────────────────────────────────────────────────────

  void _onDateSlotSelected(
    DateSlotSelected event,
    Emitter<CheckoutState> emit,
  ) {
    final validated = _filterSlots(
      state.allTimeSlots ?? [],
      event.index,
      event.interval,
    );
    emit(state.copyWith(selectedDateSlot: event.index, timeSlots: validated));
  }

  void _onTimeSlotSelected(
    TimeSlotSelected event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(selectedTimeSlot: event.index));
  }

  // ─── Distance & charges ──────────────────────────────────────────────────

  Future<void> _onDistanceCalculated(
    DistanceCalculated event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(distance: -1, extraCharge: null));

    final distResult = await _getDistance(event.origin, event.destination);
    final distance = distResult.fold((_) => 25.0, (d) => d);

    final chargeResult = await _getExtraCharge(distance);
    final charge = chargeResult.fold((_) => 0.0, (c) => c);

    emit(state.copyWith(distance: distance, extraCharge: charge));
  }

  // ─── Tips ────────────────────────────────────────────────────────────────

  Future<void> _onMostTippedFetched(
    MostTippedAmountFetched event,
    Emitter<CheckoutState> emit,
  ) async {
    final result = await _getMostTipped();
    result.fold(
      (_) {},
      (amount) => emit(state.copyWith(mostDmTipAmount: amount)),
    );
  }

  void _onTipUpdated(TipUpdated event, Emitter<CheckoutState> emit) {
    double tips = 0;
    if (event.tipIndex != 0 && event.tipIndex != 5) {
      tips = double.parse(AppConstants.tips[event.tipIndex]);
    }
    emit(state.copyWith(selectedTips: event.tipIndex, tips: tips));
  }

  void _onCustomTipSet(CustomTipSet event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(tips: event.amount));
  }

  void _onTipsFieldToggled(
    TipsFieldToggled event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(canShowTipsField: !state.canShowTipsField));
  }

  void _onDmTipSaveToggled(
    DmTipSaveToggled event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(isDmTipSave: !state.isDmTipSave));
  }

  // ─── Offline payment ─────────────────────────────────────────────────────

  Future<void> _onOfflineMethodsFetched(
    OfflineMethodListFetched event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(offlineMethodList: null));
    final result = await _getOfflineMethods();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (list) => emit(state.copyWith(offlineMethodList: list)),
    );
  }

  void _onOfflineBankSelected(
    OfflineBankSelected event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(selectedOfflineBankIndex: event.index));
  }

  // ─── Payment & order type ─────────────────────────────────────────────────

  void _onPaymentMethodSet(
    PaymentMethodSet event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(paymentMethodIndex: event.index));
  }

  void _onDigitalPaymentNameChanged(
    DigitalPaymentNameChanged event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(digitalPaymentName: event.name));
  }

  void _onOrderTypeSet(OrderTypeSet event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(orderType: event.type));
  }

  void _onPartialPaymentToggled(
    PartialPaymentToggled event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(isPartialPay: !state.isPartialPay));
  }

  // ─── Address ─────────────────────────────────────────────────────────────

  void _onAddressIndexSet(AddressIndexSet event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(addressIndex: event.index));
  }

  void _onGuestAddressSet(GuestAddressSet event, Emitter<CheckoutState> emit) {
    if (event.address == null) {
      emit(state.copyWith(clearGuestAddress: true));
    } else {
      emit(state.copyWith(guestAddress: event.address));
    }
  }

  // ─── Attachments ─────────────────────────────────────────────────────────

  Future<void> _onPrescriptionImagePicked(
    PrescriptionImagePicked event,
    Emitter<CheckoutState> emit,
  ) async {
    if (event.isRemove) {
      emit(state.copyWith(pickedPrescriptions: []));
      return;
    }
    if (event.image != null) {
      final updated = List<XFile>.from(state.pickedPrescriptions)
        ..add(event.image!);
      emit(state.copyWith(pickedPrescriptions: updated));
    }
  }

  void _onPrescriptionImageRemoved(
    PrescriptionImageRemoved event,
    Emitter<CheckoutState> emit,
  ) {
    final updated = List<XFile>.from(state.pickedPrescriptions)
      ..removeAt(event.index);
    emit(state.copyWith(pickedPrescriptions: updated));
  }

  Future<void> _onOrderAttachmentPicked(
    OrderAttachmentPicked event,
    Emitter<CheckoutState> emit,
  ) async {
    XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked != null) {
      picked = await NetworkInfo.compressImage(picked);
      emit(state.copyWith(orderAttachment: picked));
    }
  }

  // ─── Order placement ─────────────────────────────────────────────────────

  Future<void> _onOrderPlaced(
    OrderPlaced event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(orderStatus: CheckoutStatus.loading));

    final result = await _placeOrder(
      event.placeOrderBody,
      state.orderAttachment,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            orderStatus: CheckoutStatus.failure,
            errorMessage: failure.message,
          ),
        );
        if (!event.isOfflinePay) {
          showCustomSnackBar(failure.message);
        } else {
          showCustomSnackBar(failure.message);
        }
      },
      (orderID) {
        if (kDebugMode) {
          print('-------- Order placed successfully $orderID ----------');
        }
        emit(
          state.copyWith(
            orderStatus: CheckoutStatus.success,
            placedOrderId: orderID,
            clearOrderAttachment: true,
          ),
        );
        if (!event.isOfflinePay) {
          _handleOrderSuccess(
            orderID: orderID,
            zoneId: event.zoneId,
            amount: event.amount,
            maximumCodOrderAmount: event.maximumCodOrderAmount,
            fromCart: event.fromCart,
            isCashOnDeliveryActive: event.isCashOnDeliveryActive,
            contactNumber: event.placeOrderBody.contactPersonNumber,
          );
        } else {
          getIt<CartBloc>().add(ClearCartEvent());
        }
      },
    );
  }

  Future<void> _onPrescriptionOrderPlaced(
    PrescriptionOrderPlaced event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(orderStatus: CheckoutStatus.loading));

    final multiparts = event.attachments
        .map((f) => MultipartBody('order_attachment[]', f))
        .toList();

    final result = await _placePrescriptionOrder(
      storeId: event.storeId,
      distance: event.distance,
      address: event.address,
      longitude: event.longitude,
      latitude: event.latitude,
      note: event.note,
      attachments: multiparts,
      dmTips: event.dmTips,
      deliveryInstruction: event.deliveryInstruction,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            orderStatus: CheckoutStatus.failure,
            errorMessage: failure.message,
          ),
        );
        showCustomSnackBar(failure.message);
      },
      (orderID) {
        if (kDebugMode) {
          print('-------- Prescription order placed $orderID ----------');
        }
        emit(
          state.copyWith(
            orderStatus: CheckoutStatus.success,
            placedOrderId: orderID,
            clearOrderAttachment: true,
          ),
        );
        _handleOrderSuccess(
          orderID: orderID,
          zoneId: event.zoneId,
          amount: event.orderAmount,
          maximumCodOrderAmount: event.maxCodAmount,
          fromCart: event.fromCart,
          isCashOnDeliveryActive: event.isCashOnDeliveryActive,
          contactNumber: null,
        );
      },
    );
  }

  // ─── Post-order navigation callback ──────────────────────────────────────

  void _handleOrderSuccess({
    required String orderID,
    required int? zoneId,
    required double amount,
    required double? maximumCodOrderAmount,
    required bool fromCart,
    required bool isCashOnDeliveryActive,
    required String? contactNumber,
  }) {
    if (fromCart) {
      getIt<CartBloc>().add(ClearCartEvent());
    }
    add(const GuestAddressSet(address: null));

    if (!Get.find<OrderController>().showBottomSheet) {
      Get.find<OrderController>().showRunningOrders(canUpdate: false);
    }

    if (state.isDmTipSave) {
      getIt<CheckoutBloc>()
          .state; // access self — tip save handled via DI in shim
    }

    HomeScreen.loadData(true);

    // Digital payment path (index == 2)
    if (state.paymentMethodIndex == 2) {
      if (GetPlatform.isWeb) {
        final String? hostname = html.window.location.hostname;
        final String protocol = html.window.location.protocol;
        final customerId =
            Get.find<ProfileController>().userInfoModel?.id ??
            AuthHelper.getGuestId();
        final selectedUrl =
            '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID'
            '&&customer_id=$customerId'
            '&payment_method=${state.digitalPaymentName}'
            '&payment_platform=web'
            '&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
        html.window.open(selectedUrl, '_self');
      } else {
        Get.offNamed(
          RouteHelper.getPaymentRoute(
            orderID,
            Get.find<ProfileController>().userInfoModel?.id ?? 0,
            state.orderType,
            amount,
            isCashOnDeliveryActive,
            state.digitalPaymentName,
            guestId: AuthHelper.getGuestId(),
            contactNumber: contactNumber,
          ),
        );
      }
    } else {
      // Loyalty point calculation — earning point save handled in shim
      if (AuthHelper.isLoggedIn()) {
        try {
          Get.find<ProfileController>().userInfoModel;
        } catch (_) {}
      }

      if (ResponsiveHelper.isDesktop(Get.context) && AuthHelper.isLoggedIn()) {
        Get.offNamed(RouteHelper.getInitialRoute());
        // Desktop shows order success dialog via route helper after delay
        Future.delayed(
          const Duration(seconds: 2),
          () => Get.offNamed(
            RouteHelper.getOrderSuccessRoute(orderID, contactNumber),
          ),
        );
      } else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, contactNumber));
      }
    }

    add(const CheckoutCleared());
  }

  // ─── UI helpers ───────────────────────────────────────────────────────────

  void _onAcceptTermsToggled(
    AcceptTermsToggled event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(acceptTerms: !state.acceptTerms));
  }

  void _onInstructionSelected(
    InstructionSelected event,
    Emitter<CheckoutState> emit,
  ) {
    final next = state.selectedInstruction == event.index ? -1 : event.index;
    emit(state.copyWith(selectedInstruction: next));
  }

  void _onExpandToggled(ExpandToggled event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(isExpand: !state.isExpand));
  }

  void _onPreferableTimeSet(
    PreferableTimeSet event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(preferableTime: event.time));
  }

  void _onTotalAmountSet(TotalAmountSet event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(viewTotalPrice: event.amount));
  }

  void _onCheckoutCleared(CheckoutCleared event, Emitter<CheckoutState> emit) {
    emit(state.cleared());
  }

  // ─── Pure helpers (no side effects) ──────────────────────────────────────

  /// Build time slots from store schedule.
  List<TimeSlotModel> _buildTimeSlots(Store store, int slotDuration) {
    final slots = <TimeSlotModel>[];
    final now = DateTime.now();

    for (final schedule in store.schedules ?? <Schedules>[]) {
      final open = DateTime(
        now.year,
        now.month,
        now.day,
        DateConverter.convertStringTimeToDate(schedule.openingTime!).hour,
        DateConverter.convertStringTimeToDate(schedule.openingTime!).minute,
      );
      final close = DateTime(
        now.year,
        now.month,
        now.day,
        DateConverter.convertStringTimeToDate(schedule.closingTime!).hour,
        DateConverter.convertStringTimeToDate(schedule.closingTime!).minute,
      );

      final minutes = close.difference(open).isNegative
          ? open.difference(close).inMinutes
          : close.difference(open).inMinutes;

      if (minutes > slotDuration) {
        var time = open;
        while (time.isBefore(close)) {
          final start = time;
          var end = start.add(Duration(minutes: slotDuration));
          if (end.isAfter(close)) end = close;
          slots.add(
            TimeSlotModel(day: schedule.day, startTime: start, endTime: end),
          );
          time = time.add(Duration(minutes: slotDuration));
        }
      } else {
        slots.add(
          TimeSlotModel(day: schedule.day, startTime: open, endTime: close),
        );
      }
    }
    return slots;
  }

  /// Filter time slots for a given day index.
  List<TimeSlotModel> _filterSlots(
    List<TimeSlotModel> slots,
    int dateIndex,
    int? interval,
  ) {
    var now = DateTime.now();
    final useInterval =
        Get.find<SplashController>()
            .configModel
            ?.moduleConfig
            ?.module
            ?.orderPlaceToScheduleInterval ??
        false;
    if (useInterval && interval != null) {
      now = now.add(Duration(minutes: interval));
    }

    int day = dateIndex == 0
        ? DateTime.now().weekday
        : DateTime.now().add(const Duration(days: 1)).weekday;
    if (day == 7) day = 0;

    return slots
        .where(
          (s) =>
              s.day == day && (dateIndex == 0 ? s.endTime!.isAfter(now) : true),
        )
        .toList();
  }

  // ─── Compatibility accessors (for legacy shim) ────────────────────────────

  bool get isLoading => state.orderStatus == CheckoutStatus.loading;
}
