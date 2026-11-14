part of 'order_bloc.dart';

/// Which mutating action produced the current [OrderActionStatus].
enum OrderActionType {
  none,
  cancel,
  switchToCod,
  refundSubmit,
}

/// One-shot outcome of a mutating action (cancel / switch-to-COD / refund).
/// The UI reacts via `BlocListener` and it resets on the next action.
enum OrderActionStatus { none, inProgress, success, failure }

/// Single immutable state for the whole order feature. A status/flag shape is
/// used (not a sealed hierarchy) because the loaded lists, tracked order and
/// details must survive across the many independent actions (rule 6).
class OrderState extends Equatable {
  // ── loaded data ────────────────────────────────────────────────────────
  final PaginatedOrderModel? runningOrderModel;
  final PaginatedOrderModel? historyOrderModel;
  final List<OrderDetailsModel>? orderDetails;
  final OrderModel? trackModel;

  /// Outcome of the last `trackOrder` (success/message) for the UI to inspect.
  final ResponseModel? responseModel;

  // ── refund / cancel reasons ─────────────────────────────────────────────
  final List<CancellationData>? orderCancelReasons;
  final List<String?>? refundReasons;
  final int selectedReasonIndex;
  final XFile? refundImage;
  final String? cancelReason;

  // ── transient flags ──────────────────────────────────────────────────────
  final bool isLoading;
  final bool showCancelled;
  final bool showBottomSheet;
  final bool showOneOrder;
  final bool isExpanded;

  // ── one-shot action outcome ───────────────────────────────────────────────
  final OrderActionStatus actionStatus;
  final OrderActionType actionType;
  final String? actionMessage;

  const OrderState({
    this.runningOrderModel,
    this.historyOrderModel,
    this.orderDetails,
    this.trackModel,
    this.responseModel,
    this.orderCancelReasons,
    this.refundReasons,
    this.selectedReasonIndex = 0,
    this.refundImage,
    this.cancelReason,
    this.isLoading = false,
    this.showCancelled = false,
    this.showBottomSheet = true,
    this.showOneOrder = true,
    this.isExpanded = false,
    this.actionStatus = OrderActionStatus.none,
    this.actionType = OrderActionType.none,
    this.actionMessage,
  });

  OrderState copyWith({
    PaginatedOrderModel? runningOrderModel,
    bool resetRunning = false,
    PaginatedOrderModel? historyOrderModel,
    bool resetHistory = false,
    List<OrderDetailsModel>? orderDetails,
    bool resetOrderDetails = false,
    OrderModel? trackModel,
    bool resetTrackModel = false,
    ResponseModel? responseModel,
    List<CancellationData>? orderCancelReasons,
    bool resetCancelReasons = false,
    List<String?>? refundReasons,
    bool resetRefundReasons = false,
    int? selectedReasonIndex,
    XFile? refundImage,
    bool resetRefundImage = false,
    String? cancelReason,
    bool? isLoading,
    bool? showCancelled,
    bool? showBottomSheet,
    bool? showOneOrder,
    bool? isExpanded,
    OrderActionStatus? actionStatus,
    OrderActionType? actionType,
    String? actionMessage,
  }) {
    return OrderState(
      runningOrderModel: resetRunning
          ? null
          : (runningOrderModel ?? this.runningOrderModel),
      historyOrderModel: resetHistory
          ? null
          : (historyOrderModel ?? this.historyOrderModel),
      orderDetails: resetOrderDetails
          ? null
          : (orderDetails ?? this.orderDetails),
      trackModel: resetTrackModel ? null : (trackModel ?? this.trackModel),
      responseModel: responseModel ?? this.responseModel,
      orderCancelReasons: resetCancelReasons
          ? null
          : (orderCancelReasons ?? this.orderCancelReasons),
      refundReasons: resetRefundReasons
          ? null
          : (refundReasons ?? this.refundReasons),
      selectedReasonIndex: selectedReasonIndex ?? this.selectedReasonIndex,
      refundImage: resetRefundImage ? null : (refundImage ?? this.refundImage),
      cancelReason: cancelReason ?? this.cancelReason,
      isLoading: isLoading ?? this.isLoading,
      showCancelled: showCancelled ?? this.showCancelled,
      showBottomSheet: showBottomSheet ?? this.showBottomSheet,
      showOneOrder: showOneOrder ?? this.showOneOrder,
      isExpanded: isExpanded ?? this.isExpanded,
      actionStatus: actionStatus ?? this.actionStatus,
      actionType: actionType ?? this.actionType,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    runningOrderModel,
    historyOrderModel,
    orderDetails,
    trackModel,
    responseModel,
    orderCancelReasons,
    refundReasons,
    selectedReasonIndex,
    refundImage,
    cancelReason,
    isLoading,
    showCancelled,
    showBottomSheet,
    showOneOrder,
    isExpanded,
    actionStatus,
    actionType,
    actionMessage,
  ];
}
