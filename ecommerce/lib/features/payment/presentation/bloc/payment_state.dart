import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/payment/data/models/offline_method_model.dart';

enum PaymentStatus { initial, loading, loaded, error }

/// Outcome of the last mutating action (save/update offline info). One-shot:
/// the UI reacts to it via `BlocListener` (navigate / snackbar / close dialog).
enum OfflineInfoActionStatus { none, inProgress, success, failure }

/// Single immutable state. A status enum is used (not a sealed hierarchy)
/// because the loaded method list + selected bank index must survive across
/// the save/update actions (rule 6).
class PaymentState extends Equatable {
  final PaymentStatus status;
  final List<OfflineMethodModel> offlineMethodList;
  final int selectedBankIndex;
  final OfflineInfoActionStatus actionStatus;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.offlineMethodList = const [],
    this.selectedBankIndex = 0,
    this.actionStatus = OfflineInfoActionStatus.none,
    this.errorMessage,
  });

  bool get isLoading => actionStatus == OfflineInfoActionStatus.inProgress;

  PaymentState copyWith({
    PaymentStatus? status,
    List<OfflineMethodModel>? offlineMethodList,
    int? selectedBankIndex,
    OfflineInfoActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      offlineMethodList: offlineMethodList ?? this.offlineMethodList,
      selectedBankIndex: selectedBankIndex ?? this.selectedBankIndex,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    offlineMethodList,
    selectedBankIndex,
    actionStatus,
    errorMessage,
  ];
}
