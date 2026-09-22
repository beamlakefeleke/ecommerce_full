import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/features/order/domain/models/order_model.dart';

sealed class OrderEvent {
  const OrderEvent();
}

// ─── Order lists ────────────────────────────────────────────────────────────

class GetRunningOrdersRequested extends OrderEvent {
  final int offset;
  const GetRunningOrdersRequested({this.offset = 1});
}

class GetHistoryOrdersRequested extends OrderEvent {
  final int offset;
  const GetHistoryOrdersRequested({this.offset = 1});
}

// ─── Order details & tracking ────────────────────────────────────────────────

class GetOrderDetailsRequested extends OrderEvent {
  final String orderID;
  final String? guestId;
  const GetOrderDetailsRequested({required this.orderID, this.guestId});
}

class TrackOrderRequested extends OrderEvent {
  final String orderID;

  /// When [orderModel] is supplied the BLoC skips the API call and uses it directly.
  final OrderModel? orderModel;
  final String? contactNumber;
  final String? guestId;
  const TrackOrderRequested({
    required this.orderID,
    this.orderModel,
    this.contactNumber,
    this.guestId,
  });
}

/// Silent periodic poll — does NOT show a loading indicator.
class TimerTrackOrderRequested extends OrderEvent {
  final String orderID;
  final String? contactNumber;
  final String? guestId;
  const TimerTrackOrderRequested({
    required this.orderID,
    this.contactNumber,
    this.guestId,
  });
}

// ─── Order actions ───────────────────────────────────────────────────────────

class CancelOrderRequested extends OrderEvent {
  final int orderID;
  final String? reason;
  const CancelOrderRequested({required this.orderID, this.reason});
}

class SwitchToCodRequested extends OrderEvent {
  final String orderID;
  const SwitchToCodRequested({required this.orderID});
}

// ─── Refund ──────────────────────────────────────────────────────────────────

class GetRefundReasonsRequested extends OrderEvent {
  const GetRefundReasonsRequested();
}

class GetCancelReasonsRequested extends OrderEvent {
  const GetCancelReasonsRequested();
}

class RefundReasonSelected extends OrderEvent {
  final int index;
  const RefundReasonSelected(this.index);
}

class RefundImagePicked extends OrderEvent {
  /// null = remove current image
  final XFile? image;
  const RefundImagePicked(this.image);
}

class SubmitRefundRequested extends OrderEvent {
  final String note;
  final String orderID;
  const SubmitRefundRequested({required this.note, required this.orderID});
}

// ─── UI helpers ──────────────────────────────────────────────────────────────

class CancelReasonSet extends OrderEvent {
  final String? reason;
  const CancelReasonSet(this.reason);
}

class ShowRunningOrdersToggled extends OrderEvent {
  const ShowRunningOrdersToggled();
}

class ShowOneOrderToggled extends OrderEvent {
  const ShowOneOrderToggled();
}

class OrderExpandedToggled extends OrderEvent {
  final bool isExpanded;
  const OrderExpandedToggled(this.isExpanded);
}
