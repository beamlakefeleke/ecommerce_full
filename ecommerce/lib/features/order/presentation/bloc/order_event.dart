part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class RunningOrdersRequested extends OrderEvent {
  final int offset;
  const RunningOrdersRequested(this.offset);
  @override
  List<Object?> get props => [offset];
}

class HistoryOrdersRequested extends OrderEvent {
  final int offset;
  const HistoryOrdersRequested(this.offset);
  @override
  List<Object?> get props => [offset];
}

class OrderDetailsRequested extends OrderEvent {
  final String orderId;
  const OrderDetailsRequested(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

/// Track an order. If [order] is provided, it is used directly (no fetch).
class OrderTrackRequested extends OrderEvent {
  final String? orderId;
  final OrderModel? order;
  final bool fromTracking;
  final String? contactNumber;
  const OrderTrackRequested({
    this.orderId,
    this.order,
    this.fromTracking = false,
    this.contactNumber,
  });
  @override
  List<Object?> get props => [orderId, order, fromTracking, contactNumber];
}

/// Silent re-track used by the details/tracking screen's periodic timer.
class OrderTrackRefreshed extends OrderEvent {
  final String orderId;
  final String? contactNumber;
  const OrderTrackRefreshed({required this.orderId, this.contactNumber});
  @override
  List<Object?> get props => [orderId, contactNumber];
}

class OrderCancelReasonsRequested extends OrderEvent {
  const OrderCancelReasonsRequested();
}

class RefundReasonsRequested extends OrderEvent {
  const RefundReasonsRequested();
}

class OrderCancelled extends OrderEvent {
  final int? orderId;
  final String? reason;
  const OrderCancelled({required this.orderId, this.reason});
  @override
  List<Object?> get props => [orderId, reason];
}

class OrderSwitchedToCod extends OrderEvent {
  final String? orderId;
  const OrderSwitchedToCod(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class RefundRequestSubmitted extends OrderEvent {
  final String note;
  final String? orderId;
  const RefundRequestSubmitted({required this.note, required this.orderId});
  @override
  List<Object?> get props => [note, orderId];
}

// ── pure UI-state events (replace the controller's update() toggles) ────────
class OrderCancelReasonSelected extends OrderEvent {
  final String? reason;
  const OrderCancelReasonSelected(this.reason);
  @override
  List<Object?> get props => [reason];
}

class RefundReasonSelected extends OrderEvent {
  final int index;
  const RefundReasonSelected(this.index);
  @override
  List<Object?> get props => [index];
}

class RefundImagePicked extends OrderEvent {
  final bool remove;
  const RefundImagePicked({this.remove = false});
  @override
  List<Object?> get props => [remove];
}

class OrderListToggled extends OrderEvent {
  const OrderListToggled();
}

class RunningOrderSheetToggled extends OrderEvent {
  const RunningOrderSheetToggled();
}

class OrderExpandedToggled extends OrderEvent {
  final bool expanded;
  const OrderExpandedToggled(this.expanded);
  @override
  List<Object?> get props => [expanded];
}
