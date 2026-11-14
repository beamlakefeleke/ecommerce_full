import 'package:fpdart/fpdart.dart';
import 'package:ecommerce/core/error/failure.dart';
import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction_page.dart';

/// Abstract contract for the loyalty feature. Implemented in the data layer.
/// Every method returns `Either<Failure, T>` — no throwing across the boundary.
abstract class LoyaltyRepository {
  /// One page (10 items) of the user's loyalty-point transactions at [offset].
  Future<Either<Failure, LoyaltyTransactionPage>> getTransactions(int offset);

  /// Convert [point] loyalty points into wallet money. Success carries no
  /// payload — the UI refreshes the list + profile on success.
  Future<Either<Failure, Unit>> pointToWallet(int point);
}
