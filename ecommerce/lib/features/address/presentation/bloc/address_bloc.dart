import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:ecommerce/features/address/domain/usecases/add_address_usecase.dart';
import 'package:ecommerce/features/address/domain/usecases/delete_address_usecase.dart';
import 'package:ecommerce/features/address/domain/usecases/get_addresses_usecase.dart';
import 'package:ecommerce/features/address/domain/usecases/update_address_usecase.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_event.dart';
import 'package:ecommerce/features/address/presentation/bloc/address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddressesUseCase getAddresses;
  final AddAddressUseCase addAddress;
  final UpdateAddressUseCase updateAddress;
  final DeleteAddressUseCase deleteAddress;

  AddressBloc({
    required this.getAddresses,
    required this.addAddress,
    required this.updateAddress,
    required this.deleteAddress,
  }) : super(const AddressState()) {
    on<AddressListRequested>(_onListRequested);
    on<AddressAdded>(_onAdded);
    on<AddressUpdated>(_onUpdated);
    on<AddressDeleted>(_onDeleted);
  }

  Future<void> _onListRequested(
    AddressListRequested event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(status: AddressStatus.loading));
    final result = await getAddresses(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AddressStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (addresses) => emit(
        state.copyWith(status: AddressStatus.loaded, addresses: addresses),
      ),
    );
  }

  Future<void> _onAdded(AddressAdded event, Emitter<AddressState> emit) async {
    emit(state.copyWith(actionStatus: AddressActionStatus.inProgress));
    final result = await addAddress(event.address);
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          actionStatus: AddressActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (zoneIds) async {
        emit(
          state.copyWith(
            actionStatus: AddressActionStatus.success,
            lastAddedZoneIds: zoneIds,
          ),
        );
        await _reload(emit);
      },
    );
  }

  Future<void> _onUpdated(
    AddressUpdated event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(actionStatus: AddressActionStatus.inProgress));
    final result = await updateAddress(
      UpdateAddressParams(address: event.address, id: event.id),
    );
    await result.fold(
      (failure) async => emit(
        state.copyWith(
          actionStatus: AddressActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (message) async {
        emit(
          state.copyWith(
            actionStatus: AddressActionStatus.success,
            actionMessage: message,
          ),
        );
        await _reload(emit);
      },
    );
  }

  Future<void> _onDeleted(
    AddressDeleted event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(actionStatus: AddressActionStatus.inProgress));
    final result = await deleteAddress(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: AddressActionStatus.failure,
          actionMessage: failure.message,
        ),
      ),
      (message) {
        final updated = List<Address>.from(state.addresses);
        if (event.index >= 0 && event.index < updated.length) {
          updated.removeAt(event.index);
        }
        emit(
          state.copyWith(
            actionStatus: AddressActionStatus.success,
            actionMessage: message,
            addresses: updated,
          ),
        );
      },
    );
  }

  Future<void> _reload(Emitter<AddressState> emit) async {
    final result = await getAddresses(const NoParams());
    result.fold(
      (_) {},
      (addresses) => emit(state.copyWith(addresses: addresses)),
    );
  }
}
