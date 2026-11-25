import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/features/wallet/data/models/wallet_filter_body_model.dart';
import 'package:ecommerce/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_state.dart';

export 'wallet_event.dart';
export 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletTransactionListUseCase getWalletTransactionList;
  final GetWalletBonusListUseCase getWalletBonusList;
  final AddFundToWalletUseCase addFundToWallet;
  final List<String> _offsetList = [];

  WalletBloc({
    required this.getWalletTransactionList,
    required this.getWalletBonusList,
    required this.addFundToWallet,
  }) : super(const WalletState()) {
    on<WalletInitialized>(_onInitialized);
    on<WalletTransactionListRequested>(_onTransactionListRequested);
    on<WalletBonusListRequested>(_onBonusListRequested);
    on<WalletAddFundRequested>(_onAddFundRequested);
    on<WalletFilterTypeChanged>(_onFilterTypeChanged);
    on<WalletCurrentIndexChanged>(_onCurrentIndexChanged);
    on<WalletDigitalPaymentNameChanged>(_onDigitalPaymentNameChanged);
    on<WalletAmountEmptyChanged>(_onAmountEmptyChanged);
    on<WalletBottomLoaderShown>(_onBottomLoaderShown);
    on<WalletOffsetSet>(_onOffsetSet);
  }

  void _onInitialized(WalletInitialized event, Emitter<WalletState> emit) {
    final List<WalletFilterBodyModel> filterList = [];
    for (int i = 0; i < AppConstants.walletTransactionSortingList.length; i++) {
      filterList.add(
        WalletFilterBodyModel.fromJson(
          AppConstants.walletTransactionSortingList[i],
        ),
      );
    }
    emit(state.copyWith(walletFilterList: filterList, type: 'all'));
  }

  Future<void> _onTransactionListRequested(
    WalletTransactionListRequested event,
    Emitter<WalletState> emit,
  ) async {
    if (event.offset == 1 || event.reload) {
      _offsetList.clear();
      emit(state.copyWith(
        offset: 1,
        clearTransactionList: true,
        type: event.walletType,
      ));
    }

    final offsetStr = event.offset.toString();
    if (!_offsetList.contains(offsetStr)) {
      _offsetList.add(offsetStr);
      final result = await getWalletTransactionList(
        TransactionListParams(offset: offsetStr, sortingType: event.walletType),
      );
      result.fold(
        (failure) => emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        )),
        (model) {
          final list = state.transactionList ?? <Transaction>[];
          if (event.offset == 1) {
            list.clear();
          }
          list.addAll(model.data ?? []);
          emit(state.copyWith(
            transactionList: list,
            pageSize: model.totalSize,
            isLoading: false,
          ));
        },
      );
    } else {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> _onBonusListRequested(
    WalletBonusListRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));
    final result = await getWalletBonusList(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: failure.message,
      )),
      (bonuses) => emit(state.copyWith(
        status: WalletStatus.loaded,
        fundBonusList: bonuses,
      )),
    );
  }

  Future<void> _onAddFundRequested(
    WalletAddFundRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(
      actionStatus: WalletActionStatus.addFundInProgress,
      status: WalletStatus.loading,
    ));
    final result = await addFundToWallet(
      AddFundParams(amount: event.amount, paymentMethod: event.paymentMethod),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.error,
        actionStatus: WalletActionStatus.addFundFailure,
        errorMessage: failure.message,
      )),
      (redirectUrl) => emit(state.copyWith(
        status: WalletStatus.loaded,
        actionStatus: WalletActionStatus.addFundSuccess,
        fundRedirectUrl: redirectUrl,
      )),
    );
  }

  void _onFilterTypeChanged(
    WalletFilterTypeChanged event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  void _onCurrentIndexChanged(
    WalletCurrentIndexChanged event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }

  void _onDigitalPaymentNameChanged(
    WalletDigitalPaymentNameChanged event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(digitalPaymentName: event.name));
  }

  void _onAmountEmptyChanged(
    WalletAmountEmptyChanged event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(amountEmpty: event.isEmpty));
  }

  void _onBottomLoaderShown(
    WalletBottomLoaderShown event,
    Emitter<WalletState> emit,
  ) {
    emit(state.copyWith(isLoading: true));
  }

  void _onOffsetSet(WalletOffsetSet event, Emitter<WalletState> emit) {
    emit(state.copyWith(offset: event.offset));
  }
}
