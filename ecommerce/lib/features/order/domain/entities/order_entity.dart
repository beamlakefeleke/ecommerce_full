/// Pure Dart entity for a paginated order list response.
class PaginatedOrders {
  final int totalSize;
  final int offset;
  final List<OrderEntity> orders;

  const PaginatedOrders({
    required this.totalSize,
    required this.offset,
    required this.orders,
  });
}

/// Core order entity — no JSON, no Flutter imports.
class OrderEntity {
  final int id;
  final String? orderStatus;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? orderType;
  final double orderAmount;
  final double deliveryCharge;
  final double dmTips;
  final String? moduleType;
  final bool? prescriptionOrder;
  final String? scheduleAt;
  final String? createdAt;

  const OrderEntity({
    required this.id,
    this.orderStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.orderType,
    required this.orderAmount,
    required this.deliveryCharge,
    required this.dmTips,
    this.moduleType,
    this.prescriptionOrder,
    this.scheduleAt,
    this.createdAt,
  });
}
