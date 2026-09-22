import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';

enum OrderStatus { initial, loading, success, failure }

enum OrderActionStatus { idle, loading, success, failure }

class OrderState extends Equatable {
  // ─── Order lists ────────────────────────────────────────────────────
  final PaginatedOrderModel? runningOrderModel;
  final PaginatedOrderModel? historyOrderModel;
  final OrderStatus runningStatus;
  final OrderStatus historyStatus;

  // ─── Details & tracking ─────────────────────────────────────────────
  final List<OrderDetailsModel>? orderDetails;
  final OrderModel? trackModel;
  final OrderStatus detailsStatus;
  final OrderStatus trackStatus;

  // ─── Actions (cancel / COD switch / refund submit) ───────────────────
  final OrderActionStatus actionStatus;
  final bool showCancelled;

  // ─── Refund ──────────────────────────────────────────────────────────
  final List<String?>? refundReasons;
  final List<CancellationData>? cancelReasons;
  final int selectedReasonIndex;
  final XFile? refundImage;

  // ─── UI helpers ──────────────────────────────────────────────────────
  final String? cancelReason;
  final bool showBottomSheet;
  final bool showOneOrder;
  final bool isExpanded;

  // ─── Error ───────────────────────────────────────────────────────────
  final String? errorMessage;

  const OrderState({
    this.runningOrderModel,
    this.historyOrderModel,
    this.runningStatus = OrderStatus.initial,
    this.historyStatus = OrderStatus.initial,
    this.orderDetails,
    this.trackModel,
    this.detailsStatus = OrderStatus.initial,
    this.trackStatus = OrderStatus.initial,
    this.actionStatus = OrderActionStatus.idle,
    this.showCancelled = false,
    this.refundReasons,
    this.cancelReasons,
    this.selectedReasonIndex = 0,
    this.refundImage,
    this.cancelReason,
    this.showBottomSheet = true,
    this.showOneOrder = true,
    this.isExpanded = false,
    this.errorMessage,
  });

  OrderState copyWith({
    PaginatedOrderModel? runningOrderModel,
    PaginatedOrderModel? historyOrderModel,
    OrderStatus? runningStatus,
    OrderStatus? historyStatus,
    List<OrderDetailsModel>? orderDetails,
    OrderModel? trackModel,
    OrderStatus? detailsStatus,
    OrderStatus? trackStatus,
    OrderActionStatus? actionStatus,
    bool? showCancelled,
    List<String?>? refundReasons,
    List<CancellationData>? cancelReasons,
    int? selectedReasonIndex,
    XFile? refundImage,
    bool clearRefundImage = false,
    String? cancelReason,
    bool? showBottomSheet,
    bool? showOneOrder,
    bool? isExpanded,
    String? errorMessage,
  }) {
    return OrderState(
      runningOrderModel: runningOrderModel ?? this.runningOrderModel,
      historyOrderModel: historyOrderModel ?? this.historyOrderModel,
      runningStatus: runningStatus ?? this.runningStatus,
      historyStatus: historyStatus ?? this.historyStatus,
      orderDetails: orderDetails ?? this.orderDetails,
      trackModel: trackModel ?? this.trackModel,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      trackStatus: trackStatus ?? this.trackStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      showCancelled: showCancelled ?? this.showCancelled,
      refundReasons: refundReasons ?? this.refundReasons,
      cancelReasons: cancelReasons ?? this.cancelReasons,
      selectedReasonIndex: selectedReasonIndex ?? this.selectedReasonIndex,
      refundImage: clearRefundImage ? null : (refundImage ?? this.refundImage),
      cancelReason: cancelReason ?? this.cancelReason,
      showBottomSheet: showBottomSheet ?? this.showBottomSheet,
      showOneOrder: showOneOrder ?? this.showOneOrder,
      isExpanded: isExpanded ?? this.isExpanded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    runningOrderModel,
    historyOrderModel,
    runningStatus,
    historyStatus,
    orderDetails,
    trackModel,
    detailsStatus,
    trackStatus,
    actionStatus,
    showCancelled,
    refundReasons,
    cancelReasons,
    selectedReasonIndex,
    refundImage,
    cancelReason,
    showBottomSheet,
    showOneOrder,
    isExpanded,
    errorMessage,
  ];
}
