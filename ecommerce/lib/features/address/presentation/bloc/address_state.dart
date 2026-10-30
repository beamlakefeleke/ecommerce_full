import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';

enum AddressStatus { initial, loading, loaded, error }

/// Outcome of the last mutating action (add/update/delete). One-shot: the UI
/// reacts to it via `BlocListener` and it is cleared on the next event.
enum AddressActionStatus { none, inProgress, success, failure }

/// Single immutable state. A status enum is used (not a sealed hierarchy)
/// because the loaded address list must survive across add/update/delete
/// actions (rule 6).
class AddressState extends Equatable {
  final AddressStatus status;
  final List<Address> addresses;
  final AddressActionStatus actionStatus;

  /// User-facing message for the last action (success or failure).
  final String? actionMessage;

  /// Zone ids returned by the last successful add — checkout validates these.
  final List<int> lastAddedZoneIds;

  /// Error message for a failed list load.
  final String? errorMessage;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.actionStatus = AddressActionStatus.none,
    this.actionMessage,
    this.lastAddedZoneIds = const [],
    this.errorMessage,
  });

  AddressState copyWith({
    AddressStatus? status,
    List<Address>? addresses,
    AddressActionStatus? actionStatus,
    String? actionMessage,
    List<int>? lastAddedZoneIds,
    String? errorMessage,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage,
      lastAddedZoneIds: lastAddedZoneIds ?? this.lastAddedZoneIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    addresses,
    actionStatus,
    actionMessage,
    lastAddedZoneIds,
    errorMessage,
  ];
}
