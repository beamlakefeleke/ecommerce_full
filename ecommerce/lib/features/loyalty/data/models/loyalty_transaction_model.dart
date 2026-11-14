import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction.dart';

/// Data-layer model: converts a single transaction JSON object into the pure
/// [LoyaltyTransaction] entity.
///
/// The server's list response (`total_size` + `data`) is parsed with the
/// shared `common/models/transaction_model.dart` (still used by the unmigrated
/// wallet feature and the shared `HistoryItemWidget`); this model owns the
/// mapping from that wire shape into the loyalty domain entity.
class LoyaltyTransactionModel {
  const LoyaltyTransactionModel._();

  static LoyaltyTransaction fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      userId: json['user_id'],
      transactionId: json['transaction_id'],
      credit: (json['credit'] as num?)?.toDouble(),
      debit: (json['debit'] as num?)?.toDouble(),
      adminBonus: (json['admin_bonus'] as num?)?.toDouble(),
      balance: (json['balance'] as num?)?.toDouble(),
      transactionType: json['transaction_type'],
      reference: json['reference'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
