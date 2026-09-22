import 'package:fpdart/fpdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecommerce/api/api_client.dart';
import 'package:ecommerce/core/network/failure.dart';
import 'package:ecommerce/features/checkout/domain/models/place_order_body_model.dart';
import 'package:ecommerce/features/payment/domain/models/offline_method_model.dart';

/// Domain contract for checkout operations.
/// All fallible methods return [Either<Failure, T>].
abstract class CheckoutRepositoryNew {
  // ─── Order placement ─────────────────────────────────────────────
  Future<Either<Failure, String>> placeOrder(
    PlaceOrderBodyModel orderBody,
    XFile? orderAttachment,
  );

  Future<Either<Failure, String>> placePrescriptionOrder(
    int? storeId,
    double? distance,
    String address,
    String longitude,
    String latitude,
    String note,
    List<MultipartBody> orderAttachment,
    String dmTips,
    String deliveryInstruction,
  );

  // ─── Distance & charges ──────────────────────────────────────────
  Future<Either<Failure, double>> getDistanceInMeter(
    LatLng origin,
    LatLng destination,
  );

  Future<Either<Failure, double>> getExtraCharge(double? distance);

  // ─── Tips ────────────────────────────────────────────────────────
  Future<Either<Failure, int>> getMostTippedAmount();

  // ─── Offline payment ─────────────────────────────────────────────
  Future<Either<Failure, List<OfflineMethodModel>>> getOfflineMethodList();

  // ─── Local prefs ─────────────────────────────────────────────────
  Future<bool> saveDmTipIndex(String index);
  String getDmTipIndex();
}
