import 'package:equatable/equatable.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/features/wallet/data/models/fund_bonus_model.dart';
import 'package:ecommerce/features/wallet/data/models/wallet_filter_body_model.dart';

enum WalletStatus { initial, loading, loaded, error }

enum WalletActionStatus { none, addFundInProgress, addFundSuccess, addFundFailure }

class WalletState extends Equatable {
  final WalletStatus status;
  final List<Transaction>? transactionList;
  final List<FundBonusModel>? fundBonusList;
  final bool isLoading;
  final int offset;
  final int? pageSize;
  final String digitalPaymentName;
  final bool amountEmpty;
  final int currentIndex;
  final String type;
  final List<WalletFilterBodyModel> walletFilterList;
  final String? fundRedirectUrl;
  final WalletActionStatus actionStatus;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.transactionList,
    this.fundBonusList,
    this.isLoading = false,
    this.offset = 1,
    this.pageSize,
    this.digitalPaymentName = '',
    this.amountEmpty = false,
    this.currentIndex = 0,
    this.type = 'all',
    this.walletFilterList = const [],
    this.fundRedirectUrl,
    this.actionStatus = WalletActionStatus.none,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    List<Transaction>? transactionList,
    List<FundBonusModel>? fundBonusList,
    bool? isLoading,
    int? offset,
    int? pageSize,
    String? digitalPaymentName,
    bool? amountEmpty,
    int? currentIndex,
    String? type,
    List<WalletFilterBodyModel>? walletFilterList,
    String? fundRedirectUrl,
    WalletActionStatus? actionStatus,
    String? errorMessage,
    bool clearTransactionList = false,
    bool clearFundRedirectUrl = false,
    bool clearError = false,
  }) {
    return WalletState(
      status: status ?? this.status,
      transactionList:
          clearTransactionList ? null : (transactionList ?? this.transactionList),
      fundBonusList: fundBonusList ?? this.fundBonusList,
      isLoading: isLoading ?? this.isLoading,
      offset: offset ?? this.offset,
      pageSize: pageSize ?? this.pageSize,
      digitalPaymentName: digitalPaymentName ?? this.digitalPaymentName,
      amountEmpty: amountEmpty ?? this.amountEmpty,
      currentIndex: currentIndex ?? this.currentIndex,
      type: type ?? this.type,
      walletFilterList: walletFilterList ?? this.walletFilterList,
      fundRedirectUrl:
          clearFundRedirectUrl ? null : (fundRedirectUrl ?? this.fundRedirectUrl),
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactionList,
        fundBonusList,
        isLoading,
        offset,
        pageSize,
        digitalPaymentName,
        amountEmpty,
        currentIndex,
        type,
        walletFilterList,
        fundRedirectUrl,
        actionStatus,
        errorMessage,
      ];
}
