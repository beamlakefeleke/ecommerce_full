import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/features/taxi_booking/models/brand_model.dart';
import 'package:ecommerce/features/taxi_booking/models/vehicle_model.dart';

/// Load status for the filterable vehicles list.
enum VehiclesStatus { initial, loading, loaded, error }

/// Immutable state for the select-car screen (replaces the legacy
/// `CarSelectionController`). Holds the vehicle list, brand list and the
/// filter-panel selection; the list and filters must survive across toggles,
/// so this uses a status enum rather than a sealed hierarchy.
class CarSelectionState extends Equatable {
  final VehiclesStatus vehiclesStatus;
  final VehicleModel? vehicleModel;
  final String? errorMessage;

  final List<BrandModel> brandModels;

  // filter panel
  final bool isCarFilterActive;
  final RangeValues selectedPriceRange;
  final double startingPrice;
  final double endingPrice;
  final int selectedBrand;
  final int sortByIndex;

  const CarSelectionState({
    this.vehiclesStatus = VehiclesStatus.initial,
    this.vehicleModel,
    this.errorMessage,
    this.brandModels = const [],
    this.isCarFilterActive = false,
    this.selectedPriceRange = const RangeValues(0.2, 2.0),
    this.startingPrice = 0.0,
    this.endingPrice = 2000.0,
    this.selectedBrand = 0,
    this.sortByIndex = 0,
  });

  CarSelectionState copyWith({
    VehiclesStatus? vehiclesStatus,
    VehicleModel? vehicleModel,
    bool clearVehicleModel = false,
    String? errorMessage,
    List<BrandModel>? brandModels,
    bool? isCarFilterActive,
    RangeValues? selectedPriceRange,
    double? startingPrice,
    double? endingPrice,
    int? selectedBrand,
    int? sortByIndex,
  }) {
    return CarSelectionState(
      vehiclesStatus: vehiclesStatus ?? this.vehiclesStatus,
      vehicleModel: clearVehicleModel
          ? null
          : (vehicleModel ?? this.vehicleModel),
      errorMessage: errorMessage,
      brandModels: brandModels ?? this.brandModels,
      isCarFilterActive: isCarFilterActive ?? this.isCarFilterActive,
      selectedPriceRange: selectedPriceRange ?? this.selectedPriceRange,
      startingPrice: startingPrice ?? this.startingPrice,
      endingPrice: endingPrice ?? this.endingPrice,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      sortByIndex: sortByIndex ?? this.sortByIndex,
    );
  }

  @override
  List<Object?> get props => [
    vehiclesStatus,
    vehicleModel,
    errorMessage,
    brandModels,
    isCarFilterActive,
    selectedPriceRange,
    startingPrice,
    endingPrice,
    selectedBrand,
    sortByIndex,
  ];
}
