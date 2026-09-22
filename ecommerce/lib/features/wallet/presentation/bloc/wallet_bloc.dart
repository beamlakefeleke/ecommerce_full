import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/util/app_constants.dart';
import 'package:ecommerce/features/wallet/domain/models/wallet_filter_body_model.dart';
import 'package:ecommerce/features/wallet/domain/usecases/get_wallet_transactions_usecase.dart';
import 'package:ecommerce/features/wallet/domain/usecases/add_fund_to_wallet_usecase.dart';
import 'package:ecommerce/features/wallet/domain/usecases/get_wallet_bonus_usecase.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:ecommerce/helper/route_helper.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:universal_html/html.dart' as html;

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletTransactionsUseCase getWalletTransactionsUseCase;
  final AddFundToWalletUseCase addFundToWalletUseCase;
  final GetWalletBonusUseCase getWalletBonusUseCase;

  WalletBloc({
    required this.getWalletTransactionsUseCase,
    required this.addFundToWalletUseCase,
    required this.getWalletBonusUseCase,
  }) : super(WalletState(
    walletFilterList: AppConstants.walletTransactionSortingList
        .map((e) => WalletFilterBodyModel.fromJson(e))
        .toList(),
  )) {
    on<GetWalletTransactionsEvent>(_onGetWalletTransactions);
    on<AddFundToWalletEvent>(_onAddFundToWallet);
    on<GetWalletBonusListEvent>(_onGetWalletBonusList);
    on<SetWalletFilterTypeEvent>(_onSetWalletFilterType);
    on<ChangeDigitalPaymentNameEvent>(_onChangeDigitalPaymentName);
    on<CheckTextFieldEmptyEvent>(_onCheckTextFieldEmpty);
    on<SetCurrentIndexEvent>(_onSetCurrentIndex);
  }

  Future<void> _onGetWalletTransactions(GetWalletTransactionsEvent event, Emitter<WalletState> emit) async {
    List<String> currentOffsetList = List.from(state.offsetList);
    List<dynamic> currentTransactions = state.transactionList != null ? List.from(state.transactionList!) : [];
    
    if (event.offset == '1' || event.reload) {
      currentOffsetList = [];
      currentTransactions = [];
      emit(state.copyWith(offset: 1, offsetList: [], transactionList: null));
    }

    if (!currentOffsetList.contains(event.offset)) {
      currentOffsetList.add(event.offset);
      
      final result = await getWalletTransactionsUseCase(offset: event.offset, walletType: event.walletType);
      
      result.fold(
        (failure) {
          emit(state.copyWith(error: failure.message, isLoading: false));
        },
        (transactionModel) {
          if (event.offset == '1') {
            currentTransactions = [];
          }
          currentTransactions.addAll(transactionModel.data!);
          emit(state.copyWith(
            transactionList: currentTransactions.cast(),
            popularPageSize: transactionModel.totalSize,
            offsetList: currentOffsetList,
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

  Future<void> _onAddFundToWallet(AddFundToWalletEvent event, Emitter<WalletState> emit) async {
    emit(state.copyWith(isLoading: true, clearAddFundRedirectUrl: true));
    
    final result = await addFundToWalletUseCase(amount: event.amount, paymentMethod: event.paymentMethod);
    
    result.fold(
      (failure) {
        emit(state.copyWith(error: failure.message, isLoading: false));
      },
      (redirectUrl) {
        emit(state.copyWith(isLoading: false, addFundRedirectUrl: redirectUrl));
        Get.back(); // legacy navigation hook
        if (GetPlatform.isWeb) {
          html.window.open(redirectUrl, "_self");
        } else {
          Get.toNamed(RouteHelper.getPaymentRoute('0', 0, '', 0, false, '', addFundUrl: redirectUrl, guestId: ''));
        }
      },
    );
  }

  Future<void> _onGetWalletBonusList(GetWalletBonusListEvent event, Emitter<WalletState> emit) async {
    if (event.isUpdate) {
      emit(state.copyWith(isLoading: true));
    }

    final result = await getWalletBonusUseCase();

    result.fold(
      (failure) {
        emit(state.copyWith(error: failure.message, isLoading: false));
      },
      (bonuses) {
        emit(state.copyWith(
          fundBonusList: bonuses,
          isLoading: false,
        ));
      },
    );
  }

  void _onSetWalletFilterType(SetWalletFilterTypeEvent event, Emitter<WalletState> emit) {
    emit(state.copyWith(type: event.type));
  }

  void _onChangeDigitalPaymentName(ChangeDigitalPaymentNameEvent event, Emitter<WalletState> emit) {
    emit(state.copyWith(digitalPaymentName: event.name));
  }

  void _onCheckTextFieldEmpty(CheckTextFieldEmptyEvent event, Emitter<WalletState> emit) {
    emit(state.copyWith(amountEmpty: event.value.isEmpty));
  }

  void _onSetCurrentIndex(SetCurrentIndexEvent event, Emitter<WalletState> emit) {
    emit(state.copyWith(currentIndex: event.index));
  }
}
