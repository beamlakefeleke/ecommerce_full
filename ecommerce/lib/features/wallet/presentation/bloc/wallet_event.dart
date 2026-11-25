import 'package:equatable/equatable.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class WalletTransactionListRequested extends WalletEvent {
  final int offset;
  final bool reload;
  final String walletType;
  const WalletTransactionListRequested({
    required this.offset,
    this.reload = false,
    required this.walletType,
  });

  @override
  List<Object?> get props => [offset, reload, walletType];
}

class WalletBonusListRequested extends WalletEvent {
  const WalletBonusListRequested();
}

class WalletAddFundRequested extends WalletEvent {
  final double amount;
  final String paymentMethod;
  const WalletAddFundRequested({
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [amount, paymentMethod];
}

class WalletFilterTypeChanged extends WalletEvent {
  final String type;
  const WalletFilterTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

class WalletCurrentIndexChanged extends WalletEvent {
  final int index;
  const WalletCurrentIndexChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class WalletDigitalPaymentNameChanged extends WalletEvent {
  final String name;
  const WalletDigitalPaymentNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class WalletAmountEmptyChanged extends WalletEvent {
  final bool isEmpty;
  const WalletAmountEmptyChanged(this.isEmpty);

  @override
  List<Object?> get props => [isEmpty];
}

class WalletBottomLoaderShown extends WalletEvent {
  const WalletBottomLoaderShown();
}

class WalletOffsetSet extends WalletEvent {
  final int offset;
  const WalletOffsetSet(this.offset);

  @override
  List<Object?> get props => [offset];
}

class WalletInitialized extends WalletEvent {
  const WalletInitialized();
}
