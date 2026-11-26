import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/core/usecase/usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/taxi_usecases.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_event.dart';
import 'package:ecommerce/features/taxi_booking/presentation/bloc/car_selection_state.dart';

/// Event-driven replacement for the legacy `CarSelectionController`.
///
/// Holds the select-car screen's vehicle list, brand list and filter-panel
/// state. No navigation or snackbars live here; the UI reacts to
/// [CarSelectionState].
class CarSelectionBloc extends Bloc<CarSelectionEvent, CarSelectionState> {
  final GetVehiclesUseCase getVehicles;
  final GetBrandListUseCase getBrandList;

  CarSelectionBloc({required this.getVehicles, required this.getBrandList})
    : super(const CarSelectionState()) {
    on<VehiclesRequested>(_onVehiclesRequested);
    on<BrandListRequested>(_onBrandListRequested);
    on<CarFilterToggled>(_onCarFilterToggled);
    on<BrandSelected>(_onBrandSelected);
    on<SortBySelected>(_onSortBySelected);
    on<PriceRangeSelected>(_onPriceRangeSelected);
  }

  Future<void> _onVehiclesRequested(
    VehiclesRequested event,
    Emitter<CarSelectionState> emit,
  ) async {
    emit(
      state.copyWith(
        vehiclesStatus: VehiclesStatus.loading,
        clearVehicleModel: event.offset == 1,
      ),
    );
    final result = await getVehicles(
      VehiclesParams(body: event.body, offset: event.offset),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          vehiclesStatus: VehiclesStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (vehicles) => emit(
        state.copyWith(
          vehiclesStatus: VehiclesStatus.loaded,
          vehicleModel: vehicles,
        ),
      ),
    );
  }

  Future<void> _onBrandListRequested(
    BrandListRequested event,
    Emitter<CarSelectionState> emit,
  ) async {
    final result = await getBrandList(const NoParams());
    result.fold(
      (_) {},
      (brands) => emit(state.copyWith(brandModels: brands)),
    );
  }

  void _onCarFilterToggled(
    CarFilterToggled event,
    Emitter<CarSelectionState> emit,
  ) => emit(state.copyWith(isCarFilterActive: !state.isCarFilterActive));

  void _onBrandSelected(BrandSelected event, Emitter<CarSelectionState> emit) =>
      emit(state.copyWith(selectedBrand: event.index));

  void _onSortBySelected(
    SortBySelected event,
    Emitter<CarSelectionState> emit,
  ) => emit(state.copyWith(sortByIndex: event.index));

  void _onPriceRangeSelected(
    PriceRangeSelected event,
    Emitter<CarSelectionState> emit,
  ) {
    emit(
      state.copyWith(
        selectedPriceRange: event.range,
        startingPrice: event.range.start * 1000,
        endingPrice: event.range.end * 1000,
      ),
    );
  }
}
