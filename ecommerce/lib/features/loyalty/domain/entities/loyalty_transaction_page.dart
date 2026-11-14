import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction.dart';

/// One page of loyalty-point transactions plus the total count, used by the
/// bloc to drive pagination (10 per page).
class LoyaltyTransactionPage extends Equatable {
  final List<LoyaltyTransaction> transactions;
  final int totalSize;

  const LoyaltyTransactionPage({
    this.transactions = const [],
    this.totalSize = 0,
  });

  @override
  List<Object?> get props => [transactions, totalSize];
}
