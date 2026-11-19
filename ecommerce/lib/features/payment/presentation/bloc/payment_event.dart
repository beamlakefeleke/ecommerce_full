import 'package:equatable/equatable.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or refresh) the list of offline payment methods.
class OfflineMethodListRequested extends PaymentEvent {
  const OfflineMethodListRequested();
}

/// Select the offline bank at [index] (page-view / grid tap).
class OfflineBankSelected extends PaymentEvent {
  final int index;

  const OfflineBankSelected(this.index);

  @override
  List<Object?> get props => [index];
}

/// Save the offline payment info for a freshly placed order. [data] is the
/// JSON-encoded body assembled by the UI from the selected method's fields.
class OfflineInfoSaved extends PaymentEvent {
  final String data;

  const OfflineInfoSaved(this.data);

  @override
  List<Object?> get props => [data];
}

/// Update the offline payment info of an existing order.
class OfflineInfoUpdated extends PaymentEvent {
  final String data;

  const OfflineInfoUpdated(this.data);

  @override
  List<Object?> get props => [data];
}
