import 'package:equatable/equatable.dart';

/// Pure business entity for a single loyalty-point transaction.
///
/// No JSON, no Flutter, no data-layer imports (rule 1). The shared wire model
/// `common/models/transaction_model.dart` (still consumed by the unmigrated
/// wallet feature and the shared `HistoryItemWidget`) is converted into this
/// entity inside the data layer via `LoyaltyTransactionModel`.
class LoyaltyTransaction extends Equatable {
  final int? userId;
  final String? transactionId;
  final double? credit;
  final double? debit;
  final double? adminBonus;
  final double? balance;
  final String? transactionType;
  final String? reference;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LoyaltyTransaction({
    this.userId,
    this.transactionId,
    this.credit,
    this.debit,
    this.adminBonus,
    this.balance,
    this.transactionType,
    this.reference,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    transactionId,
    credit,
    debit,
    adminBonus,
    balance,
    transactionType,
    reference,
    createdAt,
    updatedAt,
  ];
}
