import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ecommerce/common/models/transaction_model.dart';
import 'package:ecommerce/features/wallet/domain/entities/fund_bonus.dart';
import 'package:ecommerce/core/di/injection.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ecommerce/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ecommerce/features/wallet/domain/usecases/manage_wallet_token_usecase.dart';

class WalletController extends GetxController implements GetxService {
  final ManageWalletTokenUseCase manageWalletTokenUseCase;

  WalletController({required this.manageWalletTokenUseCase});

  // Backward compatibility getters (these might throw if context is not available when called, 
  // but typically they are only called from UI where BLoC state is accessible).
  // Ideally, widgets should use BlocBuilder directly instead of accessing state through the controller.
  
  BuildContext? get _context => Get.context;
  WalletBloc? get _bloc => _context != null ? BlocProvider.of<WalletBloc>(_context!) : getIt<WalletBloc>();

  @override
  void onInit() {
    super.onInit();
    _bloc?.stream.listen((state) {
      update();
    });
  }

  List<Transaction>? get transactionList => _bloc?.state.transactionList;
  int get offset => _bloc?.state.offset ?? 1;
  int? get popularPageSize => _bloc?.state.popularPageSize;
  bool get isLoading => _bloc?.state.isLoading ?? false;
  String? get digitalPaymentName => _bloc?.state.digitalPaymentName;
  bool get amountEmpty => _bloc?.state.amountEmpty ?? true;
  List<FundBonus>? get fundBonusList => _bloc?.state.fundBonusList;
  int get currentIndex => _bloc?.state.currentIndex ?? 0;
  String get type => _bloc?.state.type ?? 'all';
  List<dynamic> get walletFilterList => _bloc?.state.walletFilterList ?? [];

  void setWalletFilerType(String type, {bool isUpdate = true}) {
    _bloc?.add(SetWalletFilterTypeEvent(type: type));
  }

  void insertFilterList() {
    // Handled in BLoC constructor now
  }

  void changeDigitalPaymentName(String name, {bool isUpdate = true}) {
    _bloc?.add(ChangeDigitalPaymentNameEvent(name: name));
  }

  void isTextFieldEmpty(String value, {bool isUpdate = true}) {
    _bloc?.add(CheckTextFieldEmptyEvent(value: value));
  }

  void setOffset(int offset) {
    // Only used internally by BLoC now, no-op here
  }

  void showBottomLoader() {
    // BLoC handles its own loading state.
  }

  Future<void> getWalletTransactionList(String offset, bool reload, String walletType) async {
    _bloc?.add(GetWalletTransactionsEvent(offset: offset, reload: reload, walletType: walletType));
  }

  Future<void> addFundToWallet(double amount, String paymentMethod) async {
    _bloc?.add(AddFundToWalletEvent(amount: amount, paymentMethod: paymentMethod));
  }

  Future<void> getWalletBonusList({bool isUpdate = true}) async {
    _bloc?.add(GetWalletBonusListEvent(isUpdate: isUpdate));
  }

  void setCurrentIndex(int index, bool notify) {
    _bloc?.add(SetCurrentIndexEvent(index: index));
  }

  void setWalletAccessToken(String accessToken){
    manageWalletTokenUseCase.setWalletAccessToken(accessToken);
  }

  String getWalletAccessToken (){
    return manageWalletTokenUseCase.getWalletAccessToken();
  }
}