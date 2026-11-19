import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/payment/data/models/offline_method_model.dart';

/// Abstract contract for the payment (offline-payment) feature. Returns
/// `Either<Failure, T>`; raw exceptions never cross this boundary.
abstract class PaymentRepository {
  Future<Either<Failure, List<OfflineMethodModel>>> getOfflineMethodList();

  /// [data] is a JSON-encoded body assembled by the UI from the selected
  /// method's dynamic fields.
  Future<Either<Failure, bool>> saveOfflineInfo(String data);

  Future<Either<Failure, bool>> updateOfflineInfo(String data);
}
