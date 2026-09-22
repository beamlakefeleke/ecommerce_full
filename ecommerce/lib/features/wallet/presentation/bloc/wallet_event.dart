import 'package:equatable/equatable.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class GetWalletTransactionsEvent extends WalletEvent {
  final String offset;
  final String walletType;
  final bool reload;

  const GetWalletTransactionsEvent({required this.offset, required this.walletType, this.reload = false});

  @override
  List<Object?> get props => [offset, walletType, reload];
}

class AddFundToWalletEvent extends WalletEvent {
  final double amount;
  final String paymentMethod;

  const AddFundToWalletEvent({required this.amount, required this.paymentMethod});

  @override
  List<Object?> get props => [amount, paymentMethod];
}

class GetWalletBonusListEvent extends WalletEvent {
  final bool isUpdate;

  const GetWalletBonusListEvent({this.isUpdate = true});

  @override
  List<Object?> get props => [isUpdate];
}

class SetWalletFilterTypeEvent extends WalletEvent {
  final String type;

  const SetWalletFilterTypeEvent({required this.type});

  @override
  List<Object?> get props => [type];
}

class ChangeDigitalPaymentNameEvent extends WalletEvent {
  final String name;

  const ChangeDigitalPaymentNameEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class CheckTextFieldEmptyEvent extends WalletEvent {
  final String value;

  const CheckTextFieldEmptyEvent({required this.value});

  @override
  List<Object?> get props => [value];
}

class SetCurrentIndexEvent extends WalletEvent {
  final int index;

  const SetCurrentIndexEvent({required this.index});

  @override
  List<Object?> get props => [index];
}
