import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/loyalty/domain/entities/loyalty_transaction.dart';
import 'package:ecommerce/features/loyalty/domain/usecases/convert_point_to_wallet_usecase.dart';
import 'package:ecommerce/features/loyalty/domain/usecases/get_loyalty_transactions_usecase.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_event.dart';
import 'package:ecommerce/features/loyalty/presentation/bloc/loyalty_state.dart';

class LoyaltyBloc extends Bloc<LoyaltyEvent, LoyaltyState> {
  final GetLoyaltyTransactionsUseCase getTransactions;
  final ConvertPointToWalletUseCase convertPointToWallet;

  LoyaltyBloc({
    required this.getTransactions,
    required this.convertPointToWallet,
  }) : super(const LoyaltyState()) {
    on<LoyaltyTransactionsRequested>(_onTransactionsRequested);
    on<LoyaltyPointConverted>(_onPointConverted);
  }

  Future<void> _onTransactionsRequested(
    LoyaltyTransactionsRequested event,
    Emitter<LoyaltyState> emit,
  ) async {
    final bool isFirstPage = event.offset == 1 || event.reload;

    // Reset accumulated list + bookkeeping when (re)starting from page 1.
    if (isFirstPage) {
      emit(
        state.copyWith(
          status: LoyaltyStatus.loading,
          resetTransactions: true,
          offset: 1,
          loadedOffsets: const [],
          isLoadingMore: false,
        ),
      );
    } else {
      // Subsequent page: show the bottom loader while it fetches.
      emit(state.copyWith(isLoadingMore: true));
    }

    // Never fetch the same offset twice (mirrors the legacy offset guard).
    if (state.loadedOffsets.contains(event.offset)) {
      if (state.isLoadingMore) {
        emit(state.copyWith(isLoadingMore: false));
      }
      return;
    }

    final loadedOffsets = List<int>.from(state.loadedOffsets)
      ..add(event.offset);
    emit(state.copyWith(loadedOffsets: loadedOffsets));

    final result = await getTransactions(
      GetLoyaltyTransactionsParams(event.offset),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LoyaltyStatus.error,
          isLoadingMore: false,
          message: failure.message,
        ),
      ),
      (page) {
        final merged = <LoyaltyTransaction>[
          if (!isFirstPage && state.transactions != null)
            ...state.transactions!,
          ...page.transactions,
        ];
        emit(
          state.copyWith(
            status: LoyaltyStatus.loaded,
            transactions: merged,
            totalSize: page.totalSize,
            offset: event.offset,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onPointConverted(
    LoyaltyPointConverted event,
    Emitter<LoyaltyState> emit,
  ) async {
    emit(state.copyWith(actionStatus: LoyaltyActionStatus.inProgress));
    final result = await convertPointToWallet(
      ConvertPointToWalletParams(event.point),
    );
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          actionStatus: LoyaltyActionStatus.failure,
          message: failure.message,
        ),
      ),
      (_) async {
        emit(state.copyWith(actionStatus: LoyaltyActionStatus.success));
        // Refresh the transaction list from page 1 after a successful convert.
        add(const LoyaltyTransactionsRequested(offset: 1, reload: true));
      },
    );
  }
}
