import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/checkout/data/models/place_order_body_model.dart';
import 'package:ecommerce/features/checkout/domain/entities/time_slot.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';
import 'package:ecommerce/features/store/domain/models/store_model.dart';

/// Result of placing an order.
class PlaceOrderResult {
  final bool isSuccess;
  final String? message;
  final String orderId;

  const PlaceOrderResult({
    required this.isSuccess,
    this.message,
    this.orderId = '-1',
  });
}

/// Abstract contract for the checkout feature.
abstract class CheckoutRepository {
  Future<Either<Failure, List<OfflineMethodModel>>> getOfflineMethodList();
  Future<Either<Failure, int>> getDmTipMostTapped();
  Future<Either<Failure, double>> getExtraCharge(double? distance);

  /// Returns distance in KM (or duration in hours when [isDuration]); falls
  /// back to a geolocator straight-line distance when the API fails.
  Future<Either<Failure, double>> getDistanceInKm(
    LatLng origin,
    LatLng destination, {
    bool isDuration = false,
  });

  Future<Either<Failure, PlaceOrderResult>> placeOrder(
    PlaceOrderBodyModel body,
    XFile? orderAttachment,
  );

  Future<Either<Failure, PlaceOrderResult>> placePrescriptionOrder({
    required int? storeId,
    required double? distance,
    required String address,
    required String longitude,
    required String latitude,
    required String note,
    required List<XFile> orderAttachment,
    required String dmTips,
    required String deliveryInstruction,
  });

  // local prefs (synchronous, no failure)
  String getSharedPrefDmTipIndex();
  Future<bool> saveSharedPrefDmTipIndex(String index);

  // pure slot computation (no IO, no failure)
  List<TimeSlot> initializeTimeSlot(
    Store store,
    int? scheduleOrderSlotDuration,
  );
  List<TimeSlot> validateTimeSlot(
    List<TimeSlot> slots,
    int dateIndex,
    int? interval,
    bool orderPlaceToScheduleInterval,
  );
}
