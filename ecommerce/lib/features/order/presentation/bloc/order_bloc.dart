import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/usecases/order_usecases.dart';
import 'package:ecommerce/helper/auth_helper.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetRunningOrdersUseCase getRunningOrders;
  final GetHistoryOrdersUseCase getHistoryOrders;
  final GetOrderDetailsUseCase getOrderDetails;
  final TrackOrderUseCase trackOrder;
  final GetCancelReasonsUseCase getCancelReasons;
  final GetRefundReasonsUseCase getRefundReasons;
  final SubmitRefundRequestUseCase submitRefundRequest;
  final CancelOrderUseCase cancelOrder;
  final SwitchToCodUseCase switchToCod;

  OrderBloc({
    required this.getRunningOrders,
    required this.getHistoryOrders,
    required this.getOrderDetails,
    required this.trackOrder,
    required this.getCancelReasons,
    required this.getRefundReasons,
    required this.submitRefundRequest,
    required this.cancelOrder,
    required this.switchToCod,
  }) : super(const OrderState()) {
    on<RunningOrdersRequested>(_onRunningRequested);
    on<HistoryOrdersRequested>(_onHistoryRequested);
    on<OrderDetailsRequested>(_onDetailsRequested);
    on<OrderTrackRequested>(_onTrackRequested);
    on<OrderTrackRefreshed>(_onTrackRefreshed);
    on<OrderCancelReasonsRequested>(_onCancelReasonsRequested);
    on<RefundReasonsRequested>(_onRefundReasonsRequested);
    on<OrderCancelled>(_onCancelled);
    on<OrderSwitchedToCod>(_onSwitchedToCod);
    on<RefundRequestSubmitted>(_onRefundSubmitted);
    on<OrderCancelReasonSelected>(_onCancelReasonSelected);
    on<RefundReasonSelected>(_onRefundReasonSelected);
    on<RefundImagePicked>(_onRefundImagePicked);
    on<OrderListToggled>(_onListToggled);
    on<RunningOrderSheetToggled>(_onSheetToggled);
    on<OrderExpandedToggled>(_onExpandedToggled);
  }

  String? get _guestId =>
      AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId();

  /// Builds a fresh [PaginatedOrderModel] by appending [next] to [previous]
  /// (or returning the first page as-is). A new instance so Equatable rebuilds.
  PaginatedOrderModel _mergePage(
    PaginatedOrderModel? previous,
    PaginatedOrderModel next,
  ) {
    if (previous == null) return next;
    return PaginatedOrderModel(
      totalSize: next.totalSize,
      limit: next.limit,
      offset: next.offset,
      orders: [...?previous.orders, ...?next.orders],
    );
  }

  Future<void> _onRunningRequested(
    RunningOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    if (event.offset == 1) {
      emit(state.copyWith(resetRunning: true));
    }
    final result = await getRunningOrders(event.offset);
    result.fold((_) {}, (model) {
      emit(
        state.copyWith(
          runningOrderModel: _mergePage(
            event.offset == 1 ? null : state.runningOrderModel,
            model,
          ),
        ),
      );
    });
  }

  Future<void> _onHistoryRequested(
    HistoryOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    if (event.offset == 1) {
      emit(state.copyWith(resetHistory: true));
    }
    final result = await getHistoryOrders(event.offset);
    result.fold((_) {}, (model) {
      emit(
        state.copyWith(
          historyOrderModel: _mergePage(
            event.offset == 1 ? null : state.historyOrderModel,
            model,
          ),
        ),
      );
    });
  }

  Future<void> _onDetailsRequested(
    OrderDetailsRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        resetOrderDetails: true,
        isLoading: true,
        showCancelled: false,
      ),
    );

    final track = state.trackModel;
    if (track != null &&
        (track.orderType == 'parcel' || track.prescriptionOrder == true)) {
      emit(state.copyWith(isLoading: false, orderDetails: const []));
      return;
    }

    final result = await getOrderDetails(
      OrderDetailsParams(orderId: event.orderId, guestId: _guestId),
    );
    result.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (list) => emit(state.copyWith(isLoading: false, orderDetails: list)),
    );
  }

  Future<void> _onTrackRequested(
    OrderTrackRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        resetTrackModel: true,
        showCancelled: false,
        orderDetails: event.fromTracking ? state.orderDetails : null,
        resetOrderDetails: !event.fromTracking,
      ),
    );

    if (event.order != null) {
      emit(
        state.copyWith(
          trackModel: event.order,
          responseModel: ResponseModel(true, 'Successful'),
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true));
    final result = await trackOrder(
      TrackOrderParams(
        orderId: event.orderId,
        guestId: _guestId,
        contactNumber: event.contactNumber,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          responseModel: ResponseModel(false, failure.message),
        ),
      ),
      (order) => emit(
        state.copyWith(
          isLoading: false,
          trackModel: order,
          responseModel: ResponseModel(true, 'Successful'),
        ),
      ),
    );
  }

  Future<void> _onTrackRefreshed(
    OrderTrackRefreshed event,
    Emitter<OrderState> emit,
  ) async {
    final result = await trackOrder(
      TrackOrderParams(
        orderId: event.orderId,
        guestId: _guestId,
        contactNumber: event.contactNumber,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(responseModel: ResponseModel(false, failure.message)),
      ),
      (order) => emit(
        state.copyWith(
          trackModel: order,
          responseModel: ResponseModel(true, 'Successful'),
        ),
      ),
    );
  }

  Future<void> _onCancelReasonsRequested(
    OrderCancelReasonsRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(resetCancelReasons: true));
    final result = await getCancelReasons(const NoParams());
    result.fold(
      (_) {},
      (reasons) => emit(state.copyWith(orderCancelReasons: reasons)),
    );
  }

  Future<void> _onRefundReasonsRequested(
    RefundReasonsRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(selectedReasonIndex: 0, resetRefundReasons: true));
    final result = await getRefundReasons(const NoParams());
    result.fold(
      (_) {},
      (reasons) => emit(state.copyWith(refundReasons: reasons)),
    );
  }

  Future<void> _onCancelled(
    OrderCancelled event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        actionStatus: OrderActionStatus.inProgress,
        actionType: OrderActionType.cancel,
      ),
    );
    final result = await cancelOrder(
      CancelOrderParams(
        orderId: event.orderId.toString(),
        reason: event.reason,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: OrderActionStatus.failure,
          actionType: OrderActionType.cancel,
          actionMessage: failure.message,
        ),
      ),
      (message) {
        // Remove the cancelled order from the running list in place.
        final running = state.runningOrderModel;
        if (running != null) {
          running.orders!.removeWhere((o) => o.id == event.orderId);
        }
        emit(
          state.copyWith(
            isLoading: false,
            showCancelled: true,
            runningOrderModel: running,
            actionStatus: OrderActionStatus.success,
            actionType: OrderActionType.cancel,
            actionMessage: message,
          ),
        );
      },
    );
  }

  Future<void> _onSwitchedToCod(
    OrderSwitchedToCod event,
    Emitter<OrderState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        actionStatus: OrderActionStatus.inProgress,
        actionType: OrderActionType.switchToCod,
      ),
    );
    final result = await switchToCod(event.orderId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: OrderActionStatus.failure,
          actionType: OrderActionType.switchToCod,
          actionMessage: failure.message,
        ),
      ),
      (message) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: OrderActionStatus.success,
          actionType: OrderActionType.switchToCod,
          actionMessage: message,
        ),
      ),
    );
  }

  Future<void> _onRefundSubmitted(
    RefundRequestSubmitted event,
    Emitter<OrderState> emit,
  ) async {
    // Reason 0 is the 'select_an_option' placeholder.
    if (state.selectedReasonIndex == 0) {
      emit(
        state.copyWith(
          actionStatus: OrderActionStatus.failure,
          actionType: OrderActionType.refundSubmit,
          actionMessage: 'please_select_reason',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoading: true,
        actionStatus: OrderActionStatus.inProgress,
        actionType: OrderActionType.refundSubmit,
      ),
    );
    final body = <String, String>{
      'customer_reason': state.refundReasons![state.selectedReasonIndex]!,
      'order_id': event.orderId!,
      'customer_note': event.note,
    };
    final result = await submitRefundRequest(
      SubmitRefundParams(body: body, image: state.refundImage),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: OrderActionStatus.failure,
          actionType: OrderActionType.refundSubmit,
          actionMessage: failure.message,
        ),
      ),
      (message) => emit(
        state.copyWith(
          isLoading: false,
          actionStatus: OrderActionStatus.success,
          actionType: OrderActionType.refundSubmit,
          actionMessage: message,
        ),
      ),
    );
  }

  void _onCancelReasonSelected(
    OrderCancelReasonSelected event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(cancelReason: event.reason));
  }

  void _onRefundReasonSelected(
    RefundReasonSelected event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(selectedReasonIndex: event.index));
  }

  Future<void> _onRefundImagePicked(
    RefundImagePicked event,
    Emitter<OrderState> emit,
  ) async {
    if (event.remove) {
      emit(state.copyWith(resetRefundImage: true));
      return;
    }
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      emit(state.copyWith(refundImage: picked));
    }
  }

  void _onListToggled(OrderListToggled event, Emitter<OrderState> emit) {
    emit(state.copyWith(showOneOrder: !state.showOneOrder));
  }

  void _onSheetToggled(
    RunningOrderSheetToggled event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(showBottomSheet: !state.showBottomSheet));
  }

  void _onExpandedToggled(
    OrderExpandedToggled event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(isExpanded: event.expanded));
  }
}
