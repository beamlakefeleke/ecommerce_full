import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/widgets/custom_snackbar.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_cancel_reasons_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_history_orders_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_order_details_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_refund_reasons_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/get_running_orders_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/submit_refund_request_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/switch_to_cod_usecase.dart';
import 'package:ecommerce/features/order/domain/usecases/track_order_usecase.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_state.dart';
import 'package:ecommerce/helper/auth_helper.dart';
import 'package:ecommerce/helper/route_helper.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetRunningOrdersUseCase _getRunningOrders;
  final GetHistoryOrdersUseCase _getHistoryOrders;
  final GetOrderDetailsUseCase _getOrderDetails;
  final TrackOrderUseCase _trackOrder;
  final CancelOrderUseCase _cancelOrder;
  final SwitchToCodUseCase _switchToCod;
  final GetRefundReasonsUseCase _getRefundReasons;
  final GetCancelReasonsUseCase _getCancelReasons;
  final SubmitRefundRequestUseCase _submitRefund;

  OrderBloc({
    required GetRunningOrdersUseCase getRunningOrdersUseCase,
    required GetHistoryOrdersUseCase getHistoryOrdersUseCase,
    required GetOrderDetailsUseCase getOrderDetailsUseCase,
    required TrackOrderUseCase trackOrderUseCase,
    required CancelOrderUseCase cancelOrderUseCase,
    required SwitchToCodUseCase switchToCodUseCase,
    required GetRefundReasonsUseCase getRefundReasonsUseCase,
    required GetCancelReasonsUseCase getCancelReasonsUseCase,
    required SubmitRefundRequestUseCase submitRefundRequestUseCase,
  }) : _getRunningOrders = getRunningOrdersUseCase,
       _getHistoryOrders = getHistoryOrdersUseCase,
       _getOrderDetails = getOrderDetailsUseCase,
       _trackOrder = trackOrderUseCase,
       _cancelOrder = cancelOrderUseCase,
       _switchToCod = switchToCodUseCase,
       _getRefundReasons = getRefundReasonsUseCase,
       _getCancelReasons = getCancelReasonsUseCase,
       _submitRefund = submitRefundRequestUseCase,
       super(const OrderState()) {
    on<GetRunningOrdersRequested>(_onGetRunningOrders);
    on<GetHistoryOrdersRequested>(_onGetHistoryOrders);
    on<GetOrderDetailsRequested>(_onGetOrderDetails);
    on<TrackOrderRequested>(_onTrackOrder);
    on<TimerTrackOrderRequested>(_onTimerTrackOrder);
    on<CancelOrderRequested>(_onCancelOrder);
    on<SwitchToCodRequested>(_onSwitchToCod);
    on<GetRefundReasonsRequested>(_onGetRefundReasons);
    on<GetCancelReasonsRequested>(_onGetCancelReasons);
    on<RefundReasonSelected>(_onRefundReasonSelected);
    on<RefundImagePicked>(_onRefundImagePicked);
    on<SubmitRefundRequested>(_onSubmitRefund);
    on<CancelReasonSet>(_onCancelReasonSet);
    on<ShowRunningOrdersToggled>(_onShowRunningOrdersToggled);
    on<ShowOneOrderToggled>(_onShowOneOrderToggled);
    on<OrderExpandedToggled>(_onOrderExpandedToggled);
  }

  // ─── Order lists ──────────────────────────────────────────────────────────

  Future<void> _onGetRunningOrders(
    GetRunningOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    if (event.offset == 1) {
      emit(
        state.copyWith(
          runningStatus: OrderStatus.loading,
          runningOrderModel: null,
        ),
      );
    }
    final result = await _getRunningOrders(event.offset);
    result.fold(
      (failure) => emit(
        state.copyWith(
          runningStatus: OrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (model) {
        if (event.offset == 1) {
          emit(
            state.copyWith(
              runningStatus: OrderStatus.success,
              runningOrderModel: model,
            ),
          );
        } else {
          // append for pagination
          final existing = state.runningOrderModel;
          final merged = PaginatedOrderModel(
            totalSize: model.totalSize,
            limit: model.limit,
            offset: model.offset,
            orders: [...(existing?.orders ?? []), ...(model.orders ?? [])],
          );
          emit(
            state.copyWith(
              runningStatus: OrderStatus.success,
              runningOrderModel: merged,
            ),
          );
        }
      },
    );
  }

  Future<void> _onGetHistoryOrders(
    GetHistoryOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    if (event.offset == 1) {
      emit(
        state.copyWith(
          historyStatus: OrderStatus.loading,
          historyOrderModel: null,
        ),
      );
    }
    final result = await _getHistoryOrders(event.offset);
    result.fold(
      (failure) => emit(
        state.copyWith(
          historyStatus: OrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (model) {
        if (event.offset == 1) {
          emit(
            state.copyWith(
              historyStatus: OrderStatus.success,
              historyOrderModel: model,
            ),
          );
        } else {
          final existing = state.historyOrderModel;
          final merged = PaginatedOrderModel(
            totalSize: model.totalSize,
            limit: model.limit,
            offset: model.offset,
            orders: [...(existing?.orders ?? []), ...(model.orders ?? [])],
          );
          emit(
            state.copyWith(
              historyStatus: OrderStatus.success,
              historyOrderModel: merged,
            ),
          );
        }
      },
    );
  }

  // ─── Details & tracking ───────────────────────────────────────────────────

  Future<void> _onGetOrderDetails(
    GetOrderDetailsRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        detailsStatus: OrderStatus.loading,
        orderDetails: null,
        showCancelled: false,
      ),
    );

    // Skip API for parcel / prescription orders — empty list is correct
    final track = state.trackModel;
    if (track != null &&
        (track.orderType == 'parcel' || (track.prescriptionOrder ?? false))) {
      emit(
        state.copyWith(detailsStatus: OrderStatus.success, orderDetails: []),
      );
      return;
    }

    final result = await _getOrderDetails(
      event.orderID,
      event.guestId ??
          (AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId()),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailsStatus: OrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (details) => emit(
        state.copyWith(
          detailsStatus: OrderStatus.success,
          orderDetails: details,
        ),
      ),
    );
  }

  Future<void> _onTrackOrder(
    TrackOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    // If model is already provided (from list), use it directly — no API call
    if (event.orderModel != null) {
      emit(
        state.copyWith(
          trackModel: event.orderModel,
          trackStatus: OrderStatus.success,
          showCancelled: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        trackStatus: OrderStatus.loading,
        trackModel: null,
        showCancelled: false,
      ),
    );

    final guestId =
        event.guestId ??
        (AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());

    final result = await _trackOrder(
      event.orderID,
      guestId,
      contactNumber: event.contactNumber,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          trackStatus: OrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (order) => emit(
        state.copyWith(trackStatus: OrderStatus.success, trackModel: order),
      ),
    );
  }

  /// Silent periodic poll — never shows loading, never clears trackModel.
  Future<void> _onTimerTrackOrder(
    TimerTrackOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    final guestId =
        event.guestId ??
        (AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());

    final result = await _trackOrder(
      event.orderID,
      guestId,
      contactNumber: event.contactNumber,
    );
    result.fold(
      (_) {},
      (order) => emit(state.copyWith(trackModel: order, showCancelled: false)),
    );
  }

  // ─── Order actions ────────────────────────────────────────────────────────

  Future<void> _onCancelOrder(
    CancelOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(actionStatus: OrderActionStatus.loading));

    final result = await _cancelOrder(event.orderID.toString(), event.reason);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            actionStatus: OrderActionStatus.failure,
            errorMessage: failure.message,
          ),
        );
        showCustomSnackBar(failure.message);
      },
      (_) {
        // Remove order from running list
        final orders = List<OrderModel>.from(
          state.runningOrderModel?.orders ?? [],
        )..removeWhere((o) => o.id == event.orderID);

        final updated = state.runningOrderModel != null
            ? PaginatedOrderModel(
                totalSize: orders.length,
                limit: state.runningOrderModel!.limit,
                offset: state.runningOrderModel!.offset,
                orders: orders,
              )
            : null;

        emit(
          state.copyWith(
            actionStatus: OrderActionStatus.success,
            runningOrderModel: updated,
            showCancelled: true,
          ),
        );

        if (Get.isDialogOpen ?? false) Get.back();
      },
    );
  }

  Future<void> _onSwitchToCod(
    SwitchToCodRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(actionStatus: OrderActionStatus.loading));
    final result = await _switchToCod(event.orderID);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            actionStatus: OrderActionStatus.failure,
            errorMessage: failure.message,
          ),
        );
        showCustomSnackBar(failure.message);
      },
      (_) {
        emit(state.copyWith(actionStatus: OrderActionStatus.success));
        Get.offAllNamed(RouteHelper.getInitialRoute());
      },
    );
  }

  // ─── Refund ───────────────────────────────────────────────────────────────

  Future<void> _onGetRefundReasons(
    GetRefundReasonsRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(refundReasons: null, selectedReasonIndex: 0));
    final result = await _getRefundReasons();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (reasons) => emit(state.copyWith(refundReasons: reasons)),
    );
  }

  Future<void> _onGetCancelReasons(
    GetCancelReasonsRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(cancelReasons: null));
    final result = await _getCancelReasons();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (reasons) => emit(state.copyWith(cancelReasons: reasons)),
    );
  }

  void _onRefundReasonSelected(
    RefundReasonSelected event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(selectedReasonIndex: event.index));
  }

  void _onRefundImagePicked(RefundImagePicked event, Emitter<OrderState> emit) {
    if (event.image == null) {
      emit(state.copyWith(clearRefundImage: true));
    } else {
      emit(state.copyWith(refundImage: event.image));
    }
  }

  Future<void> _onSubmitRefund(
    SubmitRefundRequested event,
    Emitter<OrderState> emit,
  ) async {
    if (state.selectedReasonIndex == 0) {
      showCustomSnackBar('please_select_reason'.tr);
      return;
    }

    emit(state.copyWith(actionStatus: OrderActionStatus.loading));

    final body = <String, String>{
      'customer_reason': state.refundReasons![state.selectedReasonIndex]!,
      'order_id': event.orderID,
      'customer_note': event.note,
    };

    final result = await _submitRefund(body, state.refundImage);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            actionStatus: OrderActionStatus.failure,
            errorMessage: failure.message,
          ),
        );
        showCustomSnackBar(failure.message);
      },
      (_) {
        emit(state.copyWith(actionStatus: OrderActionStatus.success));
        Get.offAllNamed(RouteHelper.getInitialRoute());
      },
    );
  }

  // ─── UI helpers ───────────────────────────────────────────────────────────

  void _onCancelReasonSet(CancelReasonSet event, Emitter<OrderState> emit) {
    emit(state.copyWith(cancelReason: event.reason));
  }

  void _onShowRunningOrdersToggled(
    ShowRunningOrdersToggled event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(showBottomSheet: !state.showBottomSheet));
  }

  void _onShowOneOrderToggled(
    ShowOneOrderToggled event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(showOneOrder: !state.showOneOrder));
  }

  void _onOrderExpandedToggled(
    OrderExpandedToggled event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(isExpanded: event.isExpanded));
  }

  // ─── Compatibility accessors (for legacy shim) ────────────────────────────

  /// Mirrors the old controller's [showCancelled] getter.
  bool get showCancelled => state.showCancelled;

  /// Mirrors the old controller's [isLoading] getter.
  bool get isLoading =>
      state.trackStatus == OrderStatus.loading ||
      state.detailsStatus == OrderStatus.loading ||
      state.actionStatus == OrderActionStatus.loading;

  /// Pick a refund image using the device gallery.
  Future<void> pickRefundImage(bool isRemove) async {
    if (isRemove) {
      add(const RefundImagePicked(null));
    } else {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      add(RefundImagePicked(image));
    }
  }
}
