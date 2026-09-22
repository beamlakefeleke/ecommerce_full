import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/common/models/response_model.dart';
import 'package:ecommerce/features/order/domain/models/order_cancellation_body.dart';
import 'package:ecommerce/features/order/domain/models/order_details_model.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';
import 'package:ecommerce/features/order/domain/services/order_service_interface.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:ecommerce/features/order/presentation/bloc/order_state.dart';
import 'package:ecommerce/core/di/injection.dart';

/// Thin GetX adapter — delegates all logic to [OrderBloc].
///
/// Kept so that non-migrated screens (order_details_screen, order_tracking_screen,
/// refund_request_screen) keep compiling while incremental migration continues.
/// Remove once all consumers use BLoC directly.
class OrderController extends GetxController implements GetxService {
  // ignore: unused_field
  final OrderServiceInterface orderServiceInterface;

  OrderController({required this.orderServiceInterface});

  OrderBloc get _bloc => getIt<OrderBloc>();
  OrderState get _state => _bloc.state;

  // ─── Getters (proxy into BLoC state) ─────────────────────────────────────

  PaginatedOrderModel? get runningOrderModel => _state.runningOrderModel;
  PaginatedOrderModel? get historyOrderModel => _state.historyOrderModel;
  List<OrderDetailsModel>? get orderDetails => _state.orderDetails;
  OrderModel? get trackModel => _state.trackModel;
  bool get isLoading => _bloc.isLoading;
  bool get showCancelled => _state.showCancelled;
  bool get showBottomSheet => _state.showBottomSheet;
  bool get showOneOrder => _state.showOneOrder;
  List<String?>? get refundReasons => _state.refundReasons;
  int get selectedReasonIndex => _state.selectedReasonIndex;
  XFile? get refundImage => _state.refundImage;
  String? get cancelReason => _state.cancelReason;
  List<CancellationData>? get orderCancelReasons => _state.cancelReasons;
  bool get isExpanded => _state.isExpanded;

  // ─── Methods (forward to BLoC events) ────────────────────────────────────

  void expandedUpdate(bool status) {
    _bloc.add(OrderExpandedToggled(status));
    update();
  }

  void setOrderCancelReason(String? reason) {
    _bloc.add(CancelReasonSet(reason));
    update();
  }

  void selectReason(int index, {bool isUpdate = true}) {
    _bloc.add(RefundReasonSelected(index));
    if (isUpdate) update();
  }

  void showOrders() {
    _bloc.add(const ShowOneOrderToggled());
    update();
  }

  void showRunningOrders({bool canUpdate = true}) {
    _bloc.add(const ShowRunningOrdersToggled());
    if (canUpdate) update();
  }

  void pickRefundImage(bool isRemove) async {
    await _bloc.pickRefundImage(isRemove);
    update();
  }

  Future<void> getOrderCancelReasons() async {
    _bloc.add(const GetCancelReasonsRequested());
    // Rebuild GetX listeners after BLoC emits
    await Future.delayed(Duration.zero);
    update();
  }

  Future<void> getRefundReasons() async {
    _bloc.add(const GetRefundReasonsRequested());
    await Future.delayed(Duration.zero);
    update();
  }

  Future<void> submitRefundRequest(String note, String? orderId) async {
    _bloc.add(SubmitRefundRequested(note: note, orderID: orderId ?? ''));
    await Future.delayed(Duration.zero);
    update();
  }

  Future<void> getRunningOrders(int offset, {bool isUpdate = false}) async {
    _bloc.add(GetRunningOrdersRequested(offset: offset));
    await Future.delayed(Duration.zero);
    update();
  }

  Future<void> getHistoryOrders(int offset, {bool isUpdate = false}) async {
    _bloc.add(GetHistoryOrdersRequested(offset: offset));
    await Future.delayed(Duration.zero);
    update();
  }

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID) async {
    _bloc.add(GetOrderDetailsRequested(orderID: orderID));
    await Future.delayed(Duration.zero);
    update();
    return _state.orderDetails;
  }

  Future<ResponseModel?> trackOrder(
    String? orderID,
    OrderModel? orderModel,
    bool fromTracking, {
    String? contactNumber,
    bool? fromGuestInput = false,
  }) async {
    _bloc.add(
      TrackOrderRequested(
        orderID: orderID ?? '',
        orderModel: orderModel,
        contactNumber: contactNumber,
      ),
    );
    await Future.delayed(Duration.zero);
    update();
    final ok = _state.trackStatus == OrderStatus.success;
    return ResponseModel(
      ok,
      ok ? 'successful' : (_state.errorMessage ?? 'failed'),
    );
  }

  Future<ResponseModel?> timerTrackOrder(
    String orderID, {
    String? contactNumber,
  }) async {
    _bloc.add(
      TimerTrackOrderRequested(orderID: orderID, contactNumber: contactNumber),
    );
    await Future.delayed(Duration.zero);
    update();
    return ResponseModel(true, 'successful');
  }

  Future<bool> cancelOrder(int? orderID, String? cancelReason) async {
    _bloc.add(
      CancelOrderRequested(orderID: orderID ?? 0, reason: cancelReason),
    );
    await Future.delayed(Duration.zero);
    update();
    return _state.actionStatus == OrderActionStatus.success;
  }

  Future<bool> switchToCOD(String? orderID) async {
    _bloc.add(SwitchToCodRequested(orderID: orderID ?? ''));
    await Future.delayed(Duration.zero);
    update();
    return _state.actionStatus == OrderActionStatus.success;
  }

  void paymentRedirect({
    required String url,
    required bool canRedirect,
    required String? contactNumber,
    required Function onClose,
    required String? addFundUrl,
    required String orderID,
  }) {
    orderServiceInterface.paymentRedirect(
      url: url,
      canRedirect: canRedirect,
      contactNumber: contactNumber,
      onClose: onClose,
      addFundUrl: addFundUrl,
      orderID: orderID,
    );
  }
}
