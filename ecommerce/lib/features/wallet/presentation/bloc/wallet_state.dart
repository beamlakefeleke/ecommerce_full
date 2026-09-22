import 'package:equatable/equatable.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/features/wallet/domain/entities/fund_bonus.dart';
import 'package:ecommerce/features/wallet/domain/entities/wallet_filter_body.dart';

class WalletState extends Equatable {
  final bool isLoading;
  final List<Transaction>? transactionList;
  final List<String> offsetList;
  final int offset;
  final int? popularPageSize;
  final String? digitalPaymentName;
  final bool amountEmpty;
  final List<FundBonus>? fundBonusList;
  final int currentIndex;
  final String type;
  final List<WalletFilterBody> walletFilterList;
  final String? error;
  final String? addFundRedirectUrl;

  const WalletState({
    this.isLoading = false,
    this.transactionList,
    this.offsetList = const [],
    this.offset = 1,
    this.popularPageSize,
    this.digitalPaymentName,
    this.amountEmpty = true,
    this.fundBonusList,
    this.currentIndex = 0,
    this.type = 'all',
    this.walletFilterList = const [],
    this.error,
    this.addFundRedirectUrl,
  });

  WalletState copyWith({
    bool? isLoading,
    List<Transaction>? transactionList,
    List<String>? offsetList,
    int? offset,
    int? popularPageSize,
    String? digitalPaymentName,
    bool? amountEmpty,
    List<FundBonus>? fundBonusList,
    int? currentIndex,
    String? type,
    List<WalletFilterBody>? walletFilterList,
    String? error,
    String? addFundRedirectUrl,
    bool clearAddFundRedirectUrl = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      transactionList: transactionList ?? this.transactionList,
      offsetList: offsetList ?? this.offsetList,
      offset: offset ?? this.offset,
      popularPageSize: popularPageSize ?? this.popularPageSize,
      digitalPaymentName: digitalPaymentName ?? this.digitalPaymentName,
      amountEmpty: amountEmpty ?? this.amountEmpty,
      fundBonusList: fundBonusList ?? this.fundBonusList,
      currentIndex: currentIndex ?? this.currentIndex,
      type: type ?? this.type,
      walletFilterList: walletFilterList ?? this.walletFilterList,
      error: error,
      addFundRedirectUrl: clearAddFundRedirectUrl ? null : (addFundRedirectUrl ?? this.addFundRedirectUrl),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        transactionList,
        offsetList,
        offset,
        popularPageSize,
        digitalPaymentName,
        amountEmpty,
        fundBonusList,
        currentIndex,
        type,
        walletFilterList,
        error,
        addFundRedirectUrl,
      ];
}
