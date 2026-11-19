import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/payment/domain/usecases/get_offline_method_list_usecase.dart';
import 'package:ecommerce/features/payment/domain/usecases/save_offline_info_usecase.dart';
import 'package:ecommerce/features/payment/domain/usecases/update_offline_info_usecase.dart';
import 'package:ecommerce/features/payment/presentation/bloc/payment_event.dart';
import 'package:ecommerce/features/payment/presentation/bloc/payment_state.dart';

/// Screen-scoped bloc for the offline-payment flow. Holds the fetched method
/// list + selected bank index (survive across the save/update actions) and
/// surfaces action outcomes via [PaymentState.actionStatus]. The dynamic
/// `TextEditingController`/`FocusNode` lists live in the screen/dialog State
/// (rule 4), not here.
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetOfflineMethodListUseCase getOfflineMethodList;
  final SaveOfflineInfoUseCase saveOfflineInfo;
  final UpdateOfflineInfoUseCase updateOfflineInfo;

  PaymentBloc({
    required this.getOfflineMethodList,
    required this.saveOfflineInfo,
    required this.updateOfflineInfo,
  }) : super(const PaymentState()) {
    on<OfflineMethodListRequested>(_onListRequested);
    on<OfflineBankSelected>(_onBankSelected);
    on<OfflineInfoSaved>(_onSaved);
    on<OfflineInfoUpdated>(_onUpdated);
  }

  Future<void> _onListRequested(
    OfflineMethodListRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));
    final result = await getOfflineMethodList(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (list) => emit(
        state.copyWith(status: PaymentStatus.loaded, offlineMethodList: list),
      ),
    );
  }

  void _onBankSelected(OfflineBankSelected event, Emitter<PaymentState> emit) {
    emit(state.copyWith(selectedBankIndex: event.index));
  }

  Future<void> _onSaved(
    OfflineInfoSaved event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(actionStatus: OfflineInfoActionStatus.inProgress));
    final result = await saveOfflineInfo(event.data);
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: OfflineInfoActionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (success) => emit(
        state.copyWith(
          actionStatus: success
              ? OfflineInfoActionStatus.success
              : OfflineInfoActionStatus.failure,
        ),
      ),
    );
  }

  Future<void> _onUpdated(
    OfflineInfoUpdated event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(actionStatus: OfflineInfoActionStatus.inProgress));
    final result = await updateOfflineInfo(event.data);
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: OfflineInfoActionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (success) => emit(
        state.copyWith(
          actionStatus: success
              ? OfflineInfoActionStatus.success
              : OfflineInfoActionStatus.failure,
        ),
      ),
    );
  }
}
