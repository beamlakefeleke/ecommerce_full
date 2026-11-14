import 'package:equatable/equatable.dart';

sealed class LoyaltyEvent extends Equatable {
  const LoyaltyEvent();

  @override
  List<Object?> get props => [];
}

/// Load a page of loyalty transactions. [offset] is 1-based. When [reload] is
/// true (or offset == 1) the accumulated list + offset bookkeeping are reset
/// before fetching the first page.
class LoyaltyTransactionsRequested extends LoyaltyEvent {
  final int offset;
  final bool reload;

  const LoyaltyTransactionsRequested({this.offset = 1, this.reload = false});

  @override
  List<Object?> get props => [offset, reload];
}

/// Convert [point] loyalty points into wallet money.
class LoyaltyPointConverted extends LoyaltyEvent {
  final int point;

  const LoyaltyPointConverted(this.point);

  @override
  List<Object?> get props => [point];
}
