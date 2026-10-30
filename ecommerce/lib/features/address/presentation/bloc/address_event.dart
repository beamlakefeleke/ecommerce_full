import 'package:equatable/equatable.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or refresh) the user's saved address list.
class AddressListRequested extends AddressEvent {
  const AddressListRequested();
}

/// Create a new address. The resulting zone ids are surfaced in the state so
/// checkout can validate them against the store's zone.
class AddressAdded extends AddressEvent {
  final Address address;

  const AddressAdded(this.address);

  @override
  List<Object?> get props => [address];
}

class AddressUpdated extends AddressEvent {
  final Address address;
  final int? id;

  const AddressUpdated({required this.address, required this.id});

  @override
  List<Object?> get props => [address, id];
}

class AddressDeleted extends AddressEvent {
  final int? id;
  final int index;

  const AddressDeleted({required this.id, required this.index});

  @override
  List<Object?> get props => [id, index];
}
