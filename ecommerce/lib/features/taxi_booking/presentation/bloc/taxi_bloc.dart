import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/taxi_usecases.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/taxi_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/taxi_state.dart';

/// Event-driven replacement for the top-rated-vehicles responsibility of the
/// legacy `RiderController`.
///
/// No navigation or snackbars live here; the UI reacts to [TaxiState]. Input
/// is only via `add(Event)`.
class TaxiBloc extends Bloc<TaxiEvent, TaxiState> {
  final GetTopRatedVehiclesUseCase getTopRatedVehicles;

  TaxiBloc({required this.getTopRatedVehicles}) : super(const TaxiState()) {
    on<TopRatedVehiclesRequested>(_onTopRatedVehiclesRequested);
  }

  Future<void> _onTopRatedVehiclesRequested(
    TopRatedVehiclesRequested event,
    Emitter<TaxiState> emit,
  ) async {
    emit(
      state.copyWith(
        topRatedStatus: TopRatedVehiclesStatus.loading,
        clearTopRatedVehicles: event.offset == 1,
      ),
    );
    final result = await getTopRatedVehicles(event.offset);
    result.fold(
      (failure) => emit(
        state.copyWith(
          topRatedStatus: TopRatedVehiclesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (vehicles) => emit(
        state.copyWith(
          topRatedStatus: TopRatedVehiclesStatus.loaded,
          topRatedVehicles: vehicles,
        ),
      ),
    );
  }
}
