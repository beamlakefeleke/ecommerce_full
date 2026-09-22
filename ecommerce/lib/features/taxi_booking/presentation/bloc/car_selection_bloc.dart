import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_vehicles_list_usecase.dart';
import 'package:ecommerce/features/taxi_booking/domain/usecases/get_brand_list_usecase.dart';
import 'car_selection_event.dart';
import 'car_selection_state.dart';

class CarSelectionBloc extends Bloc<CarSelectionEvent, CarSelectionState> {
  final GetVehiclesListUseCase getVehiclesListUseCase;
  final GetBrandListUseCase getBrandListUseCase;

  CarSelectionBloc({
    required this.getVehiclesListUseCase,
    required this.getBrandListUseCase,
  }) : super(const CarSelectionInitial()) {
    on<ToggleCarFilterEvent>(_onToggleCarFilter);
    on<SetBrandModelEvent>(_onSetBrandModel);
    on<SetSortByEvent>(_onSetSortBy);
    on<SelectPriceRangeEvent>(_onSelectPriceRange);
    on<GetVehiclesListEvent>(_onGetVehiclesList);
    on<GetBrandListEvent>(_onGetBrandList);
  }

  void _onToggleCarFilter(ToggleCarFilterEvent event, Emitter<CarSelectionState> emit) {
    emit(_copyState(isCarFilterActive: !state.isCarFilterActive));
  }

  void _onSetBrandModel(SetBrandModelEvent event, Emitter<CarSelectionState> emit) {
    emit(_copyState(selectedBrand: event.index));
  }

  void _onSetSortBy(SetSortByEvent event, Emitter<CarSelectionState> emit) {
    emit(_copyState(sortByIndex: event.index));
  }

  void _onSelectPriceRange(SelectPriceRangeEvent event, Emitter<CarSelectionState> emit) {
    emit(_copyState(
      selectedPriceRange: event.newRange,
      startingPrice: event.newRange.start * 1000,
      endingPrice: event.newRange.end * 1000,
    ));
  }

  Future<void> _onGetVehiclesList(GetVehiclesListEvent event, Emitter<CarSelectionState> emit) async {
    if (event.offset == 1) {
      emit(_copyState(vehicleModel: null));
    }
    final result = await getVehiclesListUseCase(body: event.body, offset: event.offset);
    result.fold(
      (failure) => emit(CarSelectionError(
        message: failure.message,
        isCarFilterActive: state.isCarFilterActive,
        selectedPriceRange: state.selectedPriceRange,
        startingPrice: state.startingPrice,
        endingPrice: state.endingPrice,
        vehicleModel: state.vehicleModel,
        brandModels: state.brandModels,
        selectedBrand: state.selectedBrand,
        sortByIndex: state.sortByIndex,
      )),
      (vehicleModel) => emit(_copyState(vehicleModel: vehicleModel as dynamic)),
    );
  }

  Future<void> _onGetBrandList(GetBrandListEvent event, Emitter<CarSelectionState> emit) async {
    final result = await getBrandListUseCase();
    result.fold(
      (failure) => emit(CarSelectionError(
        message: failure.message,
        isCarFilterActive: state.isCarFilterActive,
        selectedPriceRange: state.selectedPriceRange,
        startingPrice: state.startingPrice,
        endingPrice: state.endingPrice,
        vehicleModel: state.vehicleModel,
        brandModels: state.brandModels,
        selectedBrand: state.selectedBrand,
        sortByIndex: state.sortByIndex,
      )),
      (brandModels) => emit(_copyState(brandModels: brandModels)),
    );
  }

  CarSelectionState _copyState({
    bool? isCarFilterActive,
    RangeValues? selectedPriceRange,
    double? startingPrice,
    double? endingPrice,
    dynamic vehicleModel,
    dynamic brandModels,
    int? selectedBrand,
    int? sortByIndex,
  }) {
    return CarSelectionUpdated(
      isCarFilterActive: isCarFilterActive ?? state.isCarFilterActive,
      selectedPriceRange: selectedPriceRange ?? state.selectedPriceRange,
      startingPrice: startingPrice ?? state.startingPrice,
      endingPrice: endingPrice ?? state.endingPrice,
      vehicleModel: vehicleModel ?? state.vehicleModel,
      brandModels: brandModels ?? state.brandModels,
      selectedBrand: selectedBrand ?? state.selectedBrand,
      sortByIndex: sortByIndex ?? state.sortByIndex,
    );
  }
}
