import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction.dart';

enum LoyaltyStatus { initial, loading, loaded, error }

/// Outcome of the point-to-wallet conversion. One-shot: the UI reacts to it via
/// `BlocListener` (snackbar + close dialog) and it resets on the next action.
enum LoyaltyActionStatus { none, inProgress, success, failure }

/// Single immutable state. A status enum is used (not a sealed hierarchy)
/// because the accumulated transaction list must survive across pagination and
/// the convert action (rule 6).
class LoyaltyState extends Equatable {
  final LoyaltyStatus status;

  /// `null` while the first page is still loading (drives the shimmer). An
  /// empty, non-null list means "loaded, no data".
  final List<LoyaltyTransaction>? transactions;

  /// Total number of transactions reported by the server (for page count).
  final int totalSize;

  /// Current 1-based page offset.
  final int offset;

  /// Offsets already requested, so a page is never fetched twice.
  final List<int> loadedOffsets;

  /// True while a subsequent page is being fetched (bottom loader).
  final bool isLoadingMore;

  final LoyaltyActionStatus actionStatus;

  /// User-facing message for the last action / list load error.
  final String? message;

  const LoyaltyState({
    this.status = LoyaltyStatus.initial,
    this.transactions,
    this.totalSize = 0,
    this.offset = 1,
    this.loadedOffsets = const [],
    this.isLoadingMore = false,
    this.actionStatus = LoyaltyActionStatus.none,
    this.message,
  });

  /// Page count derived from the total size (10 items per page).
  int get pageSize => (totalSize / 10).ceil();

  LoyaltyState copyWith({
    LoyaltyStatus? status,
    List<LoyaltyTransaction>? transactions,
    bool resetTransactions = false,
    int? totalSize,
    int? offset,
    List<int>? loadedOffsets,
    bool? isLoadingMore,
    LoyaltyActionStatus? actionStatus,
    String? message,
  }) {
    return LoyaltyState(
      status: status ?? this.status,
      transactions: resetTransactions
          ? null
          : (transactions ?? this.transactions),
      totalSize: totalSize ?? this.totalSize,
      offset: offset ?? this.offset,
      loadedOffsets: loadedOffsets ?? this.loadedOffsets,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      actionStatus: actionStatus ?? this.actionStatus,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    totalSize,
    offset,
    loadedOffsets,
    isLoadingMore,
    actionStatus,
    message,
  ];
}
